#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class LedParser {
	public macro static function parse(filePath:String) {
		// Read file
		var raw =
			try sys.io.File.read(filePath, false).readAll().toString()
			catch(e:Dynamic) {
				error("File not found "+filePath);
				return null;
			}

		var json : Dynamic =
			try haxe.Json.parse(raw)
			catch(e:Dynamic) {
				error("Couldn't parse JSON "+filePath);
				return null;
			}

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
				trace(json._identifier);
				var layerFields = makeObjectFields(json, [
					"pxOffsetX",
					"pxOffsetY",
				]);

				// TODO add layer content

				layers.push({
					id: json._identifier,
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


		var out = { expr: EObjectDecl(projectFields), pos:p }
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
	#end
}

