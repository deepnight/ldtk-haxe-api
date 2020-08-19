package led;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
#end

import led.JsonTypes;

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


		timer("types");

		// Create layers specialized classes
		var layerTypes : Map<String, TypeDefinition> = new Map();
		for(l in json.defs.layers) {
			switch l.type {
				case "IntGrid":
					var parentTypePath : TypePath = { pack: ["led"], name:"Layer_IntGrid" }
					var layerType : TypeDefinition = {
						pos : pos,
						name : modName+"_Layer_"+l.identifier,
						pack : modPack,
						kind : TDClass(parentTypePath),
						fields : (macro class {
							override public function new(json) {
								super(json);

								for(v in $v{l.intGridValues} ) {
									valueInfos.push({
										identifier: v.identifier,
										color: Std.parseInt( "0x"+v.color.substr(1) ),
									});
								}
								trace(valueInfos);
							}
						}).fields,
					}
					layerTypes.set(l.identifier, layerType);
					registerTypeDefinitionModule(layerType, projectFilePath);

				case "Tiles":
					var parentTypePath : TypePath = { pack: ["led"], name:"Layer_Tiles" }
					var layerType : TypeDefinition = {
						pos : pos,
						name : modName+"_Layer_"+l.identifier,
						pack : modPack,
						kind : TDClass(parentTypePath),
						fields : (macro class {
							override public function new(json) {
								super(json);
							}
						}).fields,
					}
					layerTypes.set(l.identifier, layerType);
					registerTypeDefinitionModule(layerType, projectFilePath);

				case "Entities":
					var parentTypePath : TypePath = { pack: ["led"], name:"Layer_Entities" }
					var layerType : TypeDefinition = {
						pos : pos,
						name : modName+"_Layer_"+l.identifier,
						pack : modPack,
						kind : TDClass(parentTypePath),
						fields : (macro class {
							override public function new(json) {
								super(json);
							}
						}).fields,
					}
					layerTypes.set(l.identifier, layerType);
					registerTypeDefinitionModule(layerType, projectFilePath);

				case _:
					error("Unknown layer type "+l.type);
			}
		}



		// Create Level specialized class
		var parentTypePath : TypePath = { pack: ["led"], name:"Level" }
		var levelType : TypeDefinition = {
			pos : pos,
			name : modName+"_Level",
			pack : modPack,
			kind : TDClass(parentTypePath),
			fields : (macro class {
				override public function new(json) {
					super(json);

					// Init quick access
					for(l in _layers)
						Reflect.setField(this, "l_"+l.identifier, l);
				}

				override function _instanciateLayer(json:led.JsonTypes.LayerInstJson) {
					var c = Type.resolveClass($v{mod}+"_Layer_"+json.__identifier);
					trace( $v{mod}+"_Layer_"+json.__identifier +" => "+(c!=null?"OK":"error!"));
					if( c==null )
						return null;
					else
						return cast Type.createInstance(c, [json]);
				}

				public function resolveLayer(id:String) : Null<led.Layer> {
					for(l in _layers)
						if( l.identifier==id )
							return l;
					return null;
				}
			}).fields,
		}
		for(l in json.defs.layers)
			levelType.fields.push({
				name: "l_"+l.identifier,
				access: [APublic],
				kind: FVar( Context.getType(mod+"_Layer_"+l.identifier).toComplexType() ),
				pos: pos,
			});
		registerTypeDefinitionModule(levelType, projectFilePath);


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
		var parentTypePath : TypePath = { pack: ["led"], name:"Project" }
		var levelTypePath : TypePath = { pack:modPack, name:levelType.name }
		types.push({
			pos : pos,
			name : modName,
			pack : modPack,
			kind : TDClass(parentTypePath),
			fields : (macro class {
				override public function new() {
					super();
					fromJson( haxe.Json.parse( $v{fileContent} ) );

					// Init levels quick access
					for(l in _untypedLevels)
						Reflect.setField(levels, l.identifier, l);
				}

				override function _instanciateLevel(json) {
					return new $levelTypePath(json);
				}

				public function resolveLevel(id:String) : Null<$levelComplexType> {
					for(l in _untypedLevels)
						if( l.identifier==id )
							return cast l;
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

	static function registerTypeDefinitionModule(typeDef:TypeDefinition, projectFilePath:String) {
		var mod = typeDef.pack.concat([ typeDef.name ]).join(".");
		Context.defineModule(mod, [typeDef]);
		Context.registerModuleDependency(mod, projectFilePath);

	}

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

	static inline function hexColorToStr(hex:String) : String {
		return "0x"+hex.substr(1);
	}

	static inline function hexColorToInt(hex:String) : UInt {
		return Std.parseInt( "0x"+hex.substr(1) );
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

