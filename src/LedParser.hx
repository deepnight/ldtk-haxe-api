#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class LedParser {
	public macro static function parse(filePath:String) {
		// Read file
		timer("read");
		var raw =
			try sys.io.File.read(filePath, false).readAll().toString()
			catch(e:Dynamic) {
				error("File not found "+filePath);
				return null;
			}

		timer("json");
		var json : Dynamic =
			try haxe.Json.parse(raw)
			catch(e:Dynamic) {
				error("Couldn't parse JSON "+filePath);
				return null;
			}

		timer("macro");

		var p = Context.currentPos();

		// Create project object
		var projectFields = makeObjectFields(json, [
			"name",
			"dataVersion",
			"defaultPivotX",
			"defaultPivotY",
			"bgColor",
		]);

		// Add levels
		var levelsJson : Array<Dynamic> = cast json.levels;
		var levels : Array<{ id:String, e:Expr }> = [];
		for(json in levelsJson) {
			var levelFields = makeObjectFields(json, [
				"identifier",
				"uid",
				"pxWid",
				"pxHei",
			]);
			levels.push({
				id: json.identifier,
				e: { expr:EObjectDecl(levelFields), pos:p }
			});

			// Add layer instances
			var layersJson : Array<Dynamic> = cast json.layerInstances;
			var layers : Array<{ id:String, e:Expr }> = [];
			for(json in layersJson) {
				var cWid : Int = json.__cWid;
				var cHei : Int = json.__cHei;
				// trace(json.__identifier+" : "+json.__type);
				var layerFields = makeObjectFields(json, [
					"pxOffsetX",
					"pxOffsetY",
				]);

				// Misc fields
				layerFields.push({ field: "cWid", expr: macro $v{cWid} });

				switch( json.__type ) {
					case "IntGrid":
						// startTimer();
						// Build IntGrid layer
						var intGrid : Array<Dynamic> = json.intGrid;
						var grid : Array<Array<Int>> = [];
						for(cx in 0...cWid) {
							grid[cx] = [];
							for(cy in 0...cHei)
								grid[cx][cy] = -1;
						}
						for(ig in intGrid) {
							var cx = coordIdToX( ig.coordId, cWid );
							var cy = coordIdToY( ig.coordId, cWid );
							grid[cx][cy] = ig.v;
						}

						// Build grid expr
						var lines : Array<Expr> = [];
						for( cx in 0...cWid) {
							var cols = [];
							for( cy in 0...cHei) {
								// trace(cx);
								cols.push( macro $v{grid[cx][cy]} );
							}
							// trace(cols);
							lines.push({
								expr: EArrayDecl(cols),
								pos: p,
							});
							// lines.push( macro $a{cols} );
						}
						layerFields.push({
							field: "intGrid",
							expr: {
								expr: EArrayDecl(lines),
								pos:p,
							},
						});
						// endTimer();


					case _:
						// warning('Unsupported layer type ${json.__type} ("${json.__identifier}")');
				}
				// TODO add layer content

				layers.push({
					id: json.__identifier,
					e: { expr:EObjectDecl(layerFields), pos:p },
				});
			}
			levelFields.push({
				field: "layers",
				expr: { expr:EObjectDecl(layers.map( function(l) return { field:l.id, expr:l.e, quotes:null })), pos:p },
			});
		}


		// Levels array access
		projectFields.push({
			field: "levels_arr",
			expr: { expr:EArrayDecl(levels.map( function(l) return l.e )), pos:p },
		});
		// Levels ID access
		projectFields.push({
			field: "levels",
			expr: { expr:EObjectDecl(levels.map( function(l) return { field:l.id, expr:l.e, quotes:null })), pos:p },
		});


		// var test = [ [ 5 ] ];
		// var e = macro $v{test};
		// trace(e.expr);


		var out = { expr: EObjectDecl(projectFields), pos:p }
		timer();
		return out;
	}


	#if macro
	static var hexColorReg = ~/^#([0-9abcdefABCDEF]{6})$/g;

	// Turn selected fields from an object in macro ObjectFields
	static function makeObjectFields(json:Dynamic, fields:Array<String>) : Array<ObjectField> {
		var objFields : Array<ObjectField> = [];
		for(field in fields) {
			var v : Dynamic = Reflect.field(json,field);

			var e = switch Type.typeof(v) {
				case TInt: EConst(CInt( Std.string(v) ));

				case TFloat: EConst(CFloat( Std.string(v) ));

				case TClass(String):
					var v = Std.downcast(v,String);
					if( hexColorReg.match(v) )
						EConst(CInt( parseColor(v) ));
					else
						EConst(CString( v ));

				case _:
					error("Unsupported type "+Type.typeof(v)+" ("+field+")");
					return null;
			}

			if( e!=null ) {
				// trace(field+" => "+e);
				objFields.push({ field:field, expr:{ expr:e, pos:Context.currentPos() } });
			}
		}

		return objFields;
	}


	static inline function error(msg:Dynamic, ?p:Position) {
		Context.fatalError( Std.string(msg), p==null ? Context.currentPos() : p );
	}

	static inline function warning(msg:Dynamic, ?p:Position) {
		Context.warning( Std.string(msg), p==null ? Context.currentPos() : p );
	}

	static inline function parseColor(hex:String) : String {
		return "0x"+hex.substr(1,999);
	}

	static inline function coordIdToX(coordId:Int, cWid:Int) {
		return coordId - Std.int( coordId / cWid ) * cWid;
	}

	static inline function coordIdToY(coordId:Int, cWid:Int) {
		return Std.int( coordId / cWid );
	}


	// Debug timer
	static var _t = -1.;
	static var _timerName = "";
	static inline function timer(?name="") {
		#if debug
		if( _t>=0 )
			trace( Std.int( ( haxe.Timer.stamp()-_t ) * 1000 ) / 1000  + "s " + _timerName );
		_timerName = name;
		_t = haxe.Timer.stamp();
		#end
	}
	#end
}

