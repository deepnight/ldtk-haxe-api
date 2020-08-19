package led;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
#end

import led.ApiTypes;

class Macros {

	public static function buildTypes(projectFilePath:String) {
		#if !macro
		throw "This can only be called in a macro";
		#else

		// Read project file
		timer("read");
		var fileContent =
			try sys.io.File.read(projectFilePath).readAll().toString()
			catch(e:Dynamic) error("Couldn't read "+projectFilePath);

		// Init stuff
		timer("init");
		var pos = Context.currentPos();
		var curMod = Context.getLocalModule().split(".");
		var modName = curMod.pop();
		var types = new Array<haxe.macro.Expr.TypeDefinition>();
		var projectFields : Array<Field> = [];

		// Read JSON
		timer("json");
		var json : ProjectJson = haxe.Json.parse(fileContent);


		// Build layers access
		timer("types");
		var layers : Array<ObjectField> = [];
		for(l in json.defs.layers) {
			layers.push({
				field: l.identifier,
				expr: macro 0,
			});
		}
		projectFields.push({
			name: "layers",
			kind: FVar(null, { expr:EObjectDecl(layers), pos:pos }),
			pos: pos,
			access: [ APublic ],
		});


		// Build levels access
		var levels : Array<ObjectField> = json.levels.map( function(levelJson) {
			return {
				field: levelJson.identifier,
				expr: macro null,
				quotes: null,
			}
		});
		projectFields.push({
			name: "levels",
			kind: FVar(null, { expr:EObjectDecl(levels), pos:pos }),
			pos: pos,
			access: [ APublic ],
		});


		// Create project extended class
		timer("class");
		var projectType : TypePath = { pack: ["led"], name:"Project" }
		types.push({
			pos : pos,
			name : modName,
			pack : curMod,
			kind : TDClass(projectType),
			fields : (macro class {
				override public function new() {
					super();
					parse( $v{fileContent} );

					// Init levels quick access
					for(l in _levels)
						Reflect.setField(levels, l.identifier, l);
				}

				public function resolveLevel(id:String) : Null<led.Level> {
					for(l in _levels)
						if( l.identifier==id )
							return l;
					return null;
				}
			}).fields.concat( projectFields ),
		});


		// Register things
		timer("reg");
		var modPath = Context.getLocalModule();
		Context.defineModule(modPath, types);
		Context.registerModuleDependency(modPath, projectFilePath);
		return macro : Void;
		#end
	}

	// public macro static function macroParse(filePath:String) {
	// 	// Read file
	// 	timer("read");
	// 	var raw =
	// 		try sys.io.File.read(filePath, false).readAll().toString()
	// 		catch(e:Dynamic) {
	// 			error("File not found "+filePath);
	// 			return null;
	// 		}

	// 	timer("json");
	// 	var json : Dynamic =
	// 		try haxe.Json.parse(raw)
	// 		catch(e:Dynamic) {
	// 			error("Couldn't parse JSON "+filePath);
	// 			return null;
	// 		}

	// 	timer("macro");

	// 	var p = Context.currentPos();

	// 	// Create project object
	// 	var projectFields = makeObjectFields(json, [
	// 		"name",
	// 		"dataVersion",
	// 		"defaultPivotX",
	// 		"defaultPivotY",
	// 		"bgColor",
	// 	]);

	// 	// Add levels
	// 	var levelsJson : Array<Dynamic> = cast json.levels;
	// 	var levels : Array<{ id:String, e:Expr }> = [];
	// 	for(json in levelsJson) {
	// 		var levelFields = makeObjectFields(json, [
	// 			"identifier",
	// 			"uid",
	// 			"pxWid",
	// 			"pxHei",
	// 		]);
	// 		levels.push({
	// 			id: json.identifier,
	// 			e: { expr:EObjectDecl(levelFields), pos:p }
	// 		});

	// 		// Add layer instances
	// 		var layersJson : Array<Dynamic> = cast json.layerInstances;
	// 		var layers : Array<{ id:String, e:Expr }> = [];
	// 		for(json in layersJson) {
	// 			var cWid : Int = json.__cWid;
	// 			var cHei : Int = json.__cHei;
	// 			var layerFields = makeObjectFields(json, [
	// 				"pxOffsetX",
	// 				"pxOffsetY",
	// 			]);

	// 			// Misc fields
	// 			layerFields.push({ field: "cWid", expr: macro $v{cWid} });

	// 			// Build specific layer data
	// 			switch( json.__type ) {
	// 				case "IntGrid":
	// 					var intGrid : Map<Int,Int> = new Map();
	// 					var jsonData : Array<Dynamic> = json.intGrid;
	// 					for(ig in jsonData)
	// 						intGrid.set( ig.coordId, ig.v );
	// 					// trace(intGrid);

	// 					var e = macro function get(cx:Int,cy:Int) {
	// 						if( cx<0 || cx>=$v{cWid} || cy<0 || cy>=$v{cHei} )
	// 							return -1;
	// 						else
	// 							return 666;
	// 							// return $v{intGrid.get(cy*cWid + cx)};
	// 					}
	// 					layerFields.push({
	// 						field: "get",
	// 						expr: e,
	// 					});

	// 					var e = macro new led.BaseLayer($v{json});
	// 					trace(e.expr);
	// 					layerFields.push({
	// 						field: "inst",
	// 						expr: e,
	// 					});


	// 					// var intGrid : Array<Dynamic> = json.intGrid;
	// 					// var grid : Array<Array<Int>> = [];
	// 					// for(cx in 0...cWid) {
	// 					// 	grid[cx] = [];
	// 					// 	for(cy in 0...cHei)
	// 					// 		grid[cx][cy] = -1;
	// 					// }
	// 					// for(ig in intGrid) {
	// 					// 	var cx = coordIdToX( ig.coordId, cWid );
	// 					// 	var cy = coordIdToY( ig.coordId, cWid );
	// 					// 	grid[cx][cy] = ig.v;
	// 					// }

	// 					// // Build grid expr
	// 					// var lines : Array<Expr> = [];
	// 					// for( cx in 0...cWid) {
	// 					// 	var cols = [];
	// 					// 	for( cy in 0...cHei)
	// 					// 		cols.push( macro $v{grid[cx][cy]} );
	// 					// 	lines.push({
	// 					// 		expr: EArrayDecl(cols),
	// 					// 		pos: p,
	// 					// 	});
	// 					// }

	// 					// layerFields.push({
	// 					// 	field: "intGrid",
	// 					// 	expr: {
	// 					// 		expr: EArrayDecl(lines),
	// 					// 		pos:p,
	// 					// 	},
	// 					// });


	// 				case _:
	// 					// warning('Unsupported layer type ${json.__type} ("${json.__identifier}")');
	// 			}

	// 			layers.push({
	// 				id: json.__identifier,
	// 				e: { expr:EObjectDecl(layerFields), pos:p },
	// 			});
	// 		}
	// 		levelFields.push({
	// 			field: "layers",
	// 			expr: { expr:EObjectDecl(layers.map( function(l) return { field:l.id, expr:l.e, quotes:null })), pos:p },
	// 		});
	// 	}


	// 	// Levels array access
	// 	projectFields.push({
	// 		field: "levels_arr",
	// 		expr: { expr:EArrayDecl(levels.map( function(l) return l.e )), pos:p },
	// 	});
	// 	// Levels ID access
	// 	projectFields.push({
	// 		field: "levels",
	// 		expr: { expr:EObjectDecl(levels.map( function(l) return { field:l.id, expr:l.e, quotes:null })), pos:p },
	// 	});


	// 	var out = { expr: EObjectDecl(projectFields), pos:p }
	// 	timer();
	// 	return out;
	// }


	#if macro
	static var hexColorReg = ~/^#([0-9abcdefABCDEF]{6})$/g;

	// Turn selected fields from an object in macro ObjectFields
	// static function makeObjectFields(json:Dynamic, fields:Array<String>) : Array<ObjectField> {
	// 	var objFields : Array<ObjectField> = [];
	// 	for(field in fields) {
	// 		var v : Dynamic = Reflect.field(json,field);

	// 		var e = switch Type.typeof(v) {
	// 			case TInt: EConst(CInt( Std.string(v) ));

	// 			case TFloat: EConst(CFloat( Std.string(v) ));

	// 			case TClass(String):
	// 				var v = Std.downcast(v,String);
	// 				if( hexColorReg.match(v) )
	// 					EConst(CInt( parseColor(v) ));
	// 				else
	// 					EConst(CString( v ));

	// 			case _:
	// 				error("Unsupported type "+Type.typeof(v)+" ("+field+")");
	// 				return null;
	// 		}

	// 		if( e!=null ) {
	// 			// trace(field+" => "+e);
	// 			objFields.push({ field:field, expr:{ expr:e, pos:Context.currentPos() } });
	// 		}
	// 	}

	// 	return objFields;
	// }


	static inline function error(msg:Dynamic, ?p:Position) {
		Context.fatalError( Std.string(msg), p==null ? Context.currentPos() : p );
		return null;
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
		// #if debug
		if( _t>=0 )
			trace( Std.int( ( haxe.Timer.stamp()-_t ) * 1000 ) / 1000  + "s " + _timerName );
		_timerName = name;
		_t = haxe.Timer.stamp();
		// #end
	}
	#end
}

