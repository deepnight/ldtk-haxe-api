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
		var mod = Context.getLocalModule();
		var modPack = mod.split(".");
		var modName = modPack.pop();
		var types = new Array<haxe.macro.Expr.TypeDefinition>();
		var projectFields : Array<Field> = [];

		// Read JSON
		timer("json");
		var json : ProjectJson = haxe.Json.parse(fileContent);


		// Build layers access
		// var layers : Array<ObjectField> = [];
		// for(l in json.defs.layers) {
		// 	layers.push({
		// 		field: l.identifier,
		// 		expr: macro 0,
		// 	});
		// }
		// projectFields.push({
		// 	name: "layers",
		// 	kind: FVar(null, { expr:EObjectDecl(layers), pos:pos }),
		// 	pos: pos,
		// 	access: [ APublic ],
		// });

		timer("types");


		// Create Level extended class
		var parentType : TypePath = { pack: ["led"], name:"Level" }
		var levelType : TypeDefinition = {
			pos : pos,
			name : modName+"_Level",
			pack : modPack,
			kind : TDClass(parentType),
			fields : (macro class {
				override public function new(json) {
					super(json);

					// Init quick access
					// for(l in _layers)
						// Reflect.setField(layers, l.identifier, l);
				}

				public function resolveLayer(id:String) : Null<led.BaseLayer> {
					for(l in _layers)
						if( l.identifier==id )
							return l;
					return null;
				}
			}).fields,
		}
		Context.defineType(levelType);


		// Build levels access
		var levelAccessFields : Array<ObjectField> = json.levels.map( function(levelJson) {
			return {
				field: levelJson.identifier,
				expr: macro null,
				quotes: null,
			}
		});
		var levelComplexType = Context.getType(mod+"_Level").toComplexType();
		var levelAccessType : ComplexType = TAnonymous(json.levels.map( function(levelJson) : Field {
			return {
				name: levelJson.identifier,
				kind: FVar(macro : $levelComplexType),
				pos: pos,
			}
		}));
		projectFields.push({
			name: "levels",
			kind: FVar(levelAccessType, { expr:EObjectDecl(levelAccessFields), pos:pos }),
			pos: pos,
			access: [ APublic ],
		});


		// Create Project extended class
		var parentType : TypePath = { pack: ["led"], name:"Project" }
		types.push({
			pos : pos,
			name : modName,
			pack : modPack,
			kind : TDClass(parentType),
			fields : (macro class {
				override public function new() {
					super();
					fromJson( $v{fileContent} );

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
		Context.defineModule(mod, types);
		Context.registerModuleDependency(mod, projectFilePath);
		timer("end");
		return macro : Void;
		#end
	}

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
		#if debug
		if( _t>=0 )
			trace( Std.int( ( haxe.Timer.stamp()-_t ) * 1000 ) / 1000  + "s " + _timerName );
		_timerName = name;
		_t = haxe.Timer.stamp();
		#end
	}
	#end
}

