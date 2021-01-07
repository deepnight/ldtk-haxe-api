package ldtk.macro;

#if( !macro && !display )
#error "This class should not be used outside of macros"
#end

import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
import ldtk.Json;

/**
	This class will build all necessary classes and types from a LDtk project file.
**/
class TypeBuilder {
	static var MIN_JSON_VERSION = "0.5.0";
	static var APP_PACKAGE = "ldtk";

	// File
	static var projectFilePath : String;
	static var fileContent : String;
	static var json : ProjectJson;
	static var locateCache : Map<String,String>;

	// Module infos
	static var rawMod : String = "";
	static var modPack : Array<String> = [];
	static var modName : String = "";
	static var curPos(get,never) : Position;
		inline static function get_curPos() return Context.currentPos();

	// Types
	static var projectFields : Array<Field> = [];
	static var externEnumTypes : Map<String,{ path:String, ct:ComplexType}> = new Map();
	static var externEnumSwitchExpr : Expr;
	static var entityIdsEnum : TypeDefinition;
	static var baseEntityType : TypeDefinition;
	static var levelType : TypeDefinition;
	static var tilesets : Map<Int,{ typeName:String, json:TilesetDefJson }> = new Map();

	#if ldtk_times
	static var _curMod : String;
	#end




	/**
		Build all types from project file provided as parameter.
	**/
	public static function buildTypes(projectFilePath:String) {
		// Init
		TypeBuilder.projectFilePath = projectFilePath;
		json = null;
		fileContent = null;
		locateCache = new Map();
		rawMod = Context.getLocalModule();
		modPack = rawMod.split(".");
		modName = modPack.pop();
		projectFields = [];
		externEnumTypes = new Map();
		tilesets = new Map();
		#if ldtk_times
		_curMod = modName;
		#end

		// if( modPack.length==0 )
			// warning("It is recommended to move this file to its own package to avoid potential name conflicts.");

		loadJson();
		createEnumDefs();
		createEntityIdEnum();
		linkExternalEnums();
		createBaseEntityClass();
		createSpecializedEntitiesClasses();
		createTilesetsClasses();
		createLayersClasses();
		createLevelClass();
		createLevelAccess();
		createProjectClass();

		haxe.macro.Compiler.keep( Context.getLocalModule() );
		timer("end");
		return macro : Void;
	}


	/**
		Load and parse the Json from disk
	**/
	static function loadJson() {
		// Read file
		timer("read");
		var fi =
			try sys.io.File.read(projectFilePath)
			catch(e:Dynamic) error("File not found "+projectFilePath);

		fileContent =
			try fi.readAll().toString()
			catch(e:Dynamic) error("Couldn't read file content "+projectFilePath);

		fi.close();

		// Parse JSON
		timer("json");
		json =
			try haxe.Json.parse(fileContent)
			catch(e:Dynamic) {
				var jsonPos = Context.makePosition({ min:0, max:0, file:projectFilePath });
				Context.info("Couldn't parse JSON "+projectFilePath, jsonPos);
				error("Failed to parse project JSON");
			}

		if( dn.Version.lower(json.jsonVersion, MIN_JSON_VERSION) )
			error('JSON version: "${json.jsonVersion}", required at least: "$MIN_JSON_VERSION"');
	}


	/**
		Create enums from project EnumDefs
	**/
	static function createEnumDefs() {
		timer("localEnums");
		for(e in json.defs.enums) {
			var enumTypeDef : TypeDefinition = {
				name: "Enum_"+e.identifier,
				pack: modPack,
				doc: "Enumeration of all possible "+e.identifier+" values",
				kind: TDEnum,
				pos: curPos,
				fields: e.values.map( function(json) : Field {
					return {
						name: json.id,
						pos: curPos,
						kind: FVar(null, null),
					}
				}),
			}
			registerTypeDefinitionModule(enumTypeDef, projectFilePath);
		}
	}


	/**
		Create a single enum that contains all Entity IDs
	**/
	static function createEntityIdEnum() {
		timer("entityIds");
		entityIdsEnum = {
			name: "EntityEnum",
			pack: modPack,
			kind: TDEnum,
			doc: "An enum representing all Entity IDs",
			pos: curPos,
			fields: json.defs.entities.map( function(json) : Field {
				return {
					name: json.identifier,
					pos: curPos,
					kind: FVar(null, null),
				}
			}),
		}
		registerTypeDefinitionModule(entityIdsEnum, projectFilePath);
	}


	/**
		Link external HX Enums to actual HX files
	**/
	static function linkExternalEnums() {
		timer("externEnumParsing");
		var hxPackageReg = ~/package[ \t]+([\w.]+)[ \t]*;/gim;
		externEnumTypes = new Map();
		for(e in json.defs.externalEnums){
			var p = new haxe.io.Path(e.externalRelPath);
			var fileName = p.file+"."+p.ext;
			switch p.ext {
				case null: // (should not happen, as the file extension is enforced in editor)

				case _.toLowerCase()=>"hx":
					// HX files
					var path = locateFile(fileName);
					if( path==null ) {
						error("External Enum file \""+fileName+"\" is used in LDtk Project but it can't be found in the current classPaths.");
						continue;
					}

					var fi = sys.io.File.read(path, false);
					var fileContent = fi.readAll().toString();
					fi.close();
					var enumPack = hxPackageReg.match(fileContent) ? hxPackageReg.matched(1)+"." : "";
					var enumMod = enumPack + p.file;

					var ct =
						try Context.getType(enumMod+"."+e.identifier).toComplexType()
						catch(e:Dynamic) {
							error("Cannot resolve the external HX Enum "+e.ide+" from "+enumMod+", maybe the package is wrong?");
						}

					externEnumTypes.set(e.identifier, {
						path: enumPack+e.identifier,
						ct: ct
					});

				case _:
					error("Unsupported external enum file format "+p.ext);
			}
		}

		// Prepare a switch to resolve extern enum ID to runtime type identifier. It will be called in Project constructor.
		timer("entityClass");
		var cases : Array<Case> = [];
		for(e in externEnumTypes.keyValueIterator()) {
			cases.push({
				values: [ macro $v{e.key} ],
				expr: macro $v{e.value.path},
			});
		}
		externEnumSwitchExpr = {
			expr: ESwitch( macro name, cases, macro { ldtk.Project.error("Unknown external enum name"); null; } ),
			pos: curPos,
		}
	}


	static function createBaseEntityClass() {
		// Base Entity class for this project (with enum type)
		var entityEnumType = Context.getType(entityIdsEnum.name).toComplexType();
		var entityEnumRef : Expr = {
			expr: EConst(CIdent( entityIdsEnum.name )),
			pos:curPos,
		}

		var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Entity" }
		baseEntityType = {
			pos : curPos,
			name : modName+"_Entity",
			pack : modPack,
			doc: "Project specific Entity class",
			kind : TDClass(parentTypePath),
			fields : (macro class {
				/**
					The entity type identifier represented using an enum
				**/
				public var entityType : $entityEnumType;

				override public function new(json) {
					this._enumTypePrefix = $v{modPack.concat(["Enum_"]).join(".")};
					super(json);

					entityType = Type.createEnum($entityEnumRef, json.__identifier);
				}

				override function _resolveExternalEnum<T>(name:String) : Enum<T> {
					return cast Type.resolveEnum($externEnumSwitchExpr);
				}

				public inline function is(e:$entityEnumType) {
					return entityType==e;
				}
			}).fields,
		}

		// Dirty way to force compiler to keep/import these classes
		// for(e in externEnumTypes.keyValueIterator())
		// 	baseEntityType.fields.push({
		// 		name: "_extEnum_"+e.key,
		// 		pos: pos,
		// 		kind: FVar( e.value.ct ),
		// 		access: [],
		// 	});
		registerTypeDefinitionModule(baseEntityType, projectFilePath);
	}


	/**
		Create Entities specialized classes (each one might have specific custom fields)
	**/
	static function createSpecializedEntitiesClasses() {
		timer("specEntityClasses");
		for(e in json.defs.entities) {
			// Create entity class
			var parentTypePath : TypePath = { pack: baseEntityType.pack, name:baseEntityType.name }
			var entityType : TypeDefinition = {
				pos : curPos,
				name : "Entity_"+e.identifier,
				doc: "Specialized Entity class for "+e.identifier,
				pack : modPack,
				kind : TDClass(parentTypePath),
				fields : (macro class {
					override public function new(json) {
						super(json);
					}

				}).fields,
			}

			// Create field types
			var arrayReg = ~/Array<(.*)>/gi;
			for(f in e.fieldDefs) {
				var isArray = arrayReg.match(f.__type);
				var typeName = isArray ? arrayReg.matched(1) : f.__type;

				var fields : Array<{ name:String, ct:ComplexType }> = [];
				switch typeName {
					case "Int":
						fields.push({ name: f.identifier, ct: f.canBeNull ? (macro : Null<Int>) : (macro : Int) });

					case "Float":
						fields.push({ name: f.identifier, ct: f.canBeNull ? (macro : Null<Float>) : (macro : Float) });

					case "String":
						fields.push({ name: f.identifier, ct: f.canBeNull ? (macro : Null<String>) : (macro : String) });

					case "Bool":
						fields.push({ name: f.identifier, ct: macro : Bool });

					case "Color":
						fields.push({ name: f.identifier+"_int", ct: f.canBeNull ? (macro : Null<Int>) : (macro : Int) });
						fields.push({ name: f.identifier+"_hex", ct: f.canBeNull ? (macro : Null<String>) : (macro : String) });

					case "Point":
						fields.push({ name: f.identifier, ct: f.canBeNull ? (macro : Null<ldtk.Point>) : (macro : ldtk.Point) });

					case _.indexOf("LocalEnum.") => 0:
						var type = typeName.substr( typeName.indexOf(".")+1 );
						var enumType = Context.getType( "Enum_"+type ).toComplexType();
						fields.push({ name: f.identifier, ct: f.canBeNull ? (macro : Null<$enumType>) : (macro : $enumType) });

					case _.indexOf("ExternEnum.") => 0:
						var typeId = typeName.substr( typeName.indexOf(".")+1 );
						var ct = externEnumTypes.get(typeId).ct;
						fields.push({ name: f.identifier, ct: f.canBeNull ? (macro : Null<$ct>) : (macro : $ct) });

					case _:
						error("Unsupported field type "+typeName+" in Entity "+e.identifier);
				}


				for(fi in fields) {
					if( isArray ) {
						// Turn field into Array<...>
						switch fi.ct {
						case TPath(p):
							fi.ct = TPath({
								name: "Array",
								pack: [],
								params: [ TPType(fi.ct) ],
							});
						case _: error("Unexpected array subtype "+fi.ct.getName());
						}
					}

					entityType.fields.push({
						name: "f_"+fi.name,
						access: [ APublic ],
						kind: FVar(fi.ct),
						doc: "Entity field "+fi.name+" ("+f.__type+")",
						pos: curPos,
					});
				}
			}

			registerTypeDefinitionModule(entityType, projectFilePath);
		}
	}


	/**
		Create tileset classes
	**/
	static function createTilesetsClasses() {
		timer("tilesetClasses");
		tilesets = new Map();
		for(e in json.defs.tilesets) {
			// Create entity class
			var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Tileset" }
			var tilesetType : TypeDefinition = {
				pos : curPos,
				name : "Tileset_"+e.identifier,
				pack : modPack,
				doc: 'Tileset class of atlas "${e.relPath}"',
				kind : TDClass(parentTypePath),
				fields : (macro class {
					override public function new(json) {
						super(json);
					}

				}).fields,
			}
			registerTypeDefinitionModule(tilesetType, projectFilePath);
			tilesets.set(e.uid, {
				typeName: tilesetType.name,
				json: e,
			});
		}
	}


	/**
		Create Layers specialized classes
	**/
	static function createLayersClasses() {
		timer("layerClasses");
		for(l in json.defs.layers) {
			var type = Type.createEnum(LayerType, Std.string(l.type)); // Json value is actually a String
			switch type {
				case IntGrid:

					if( l.autoTilesetDefUid==null ) {
						// IntGrid
						var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Layer_IntGrid" }
						var layerType : TypeDefinition = {
							pos : curPos,
							name : "Layer_"+l.identifier,
							pack : modPack,
							doc: "IntGrid layer",
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
								}
							}).fields,
						}

						registerTypeDefinitionModule(layerType, projectFilePath);
					}
					else {
						// Auto-layer IntGrid
						var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Layer_IntGrid_AutoLayer" }
						var ts = l.autoTilesetDefUid!=null ? tilesets.get(l.autoTilesetDefUid) : null;
						var tsComplexType = ts!=null ? Context.getType( ts.typeName ).toComplexType() : null;
						var tsTypePath : TypePath = ts!=null ? { pack: modPack, name: ts.typeName } : null;

						var layerType : TypeDefinition = {
							pos : curPos,
							name : "Layer_"+l.identifier,
							pack : modPack,
							doc: "IntGrid layer with auto-layer capabilities",
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

									tileset = ${ ts==null ? null : macro new $tsTypePath( cast $v{ts.json} ) }
								}

								override function _getTileset() return tileset;
							}).fields,
						}

						// Auto-layer tileset class
						layerType.fields.push({
							name: "tileset",
							access: [APublic],
							kind: FVar( tsComplexType ),
							pos: curPos,
						});

						registerTypeDefinitionModule(layerType, projectFilePath);
					}


				case AutoLayer:
					// Pure Auto-layer
					var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Layer_AutoLayer" }
					var ts = l.autoTilesetDefUid!=null ? tilesets.get(l.autoTilesetDefUid) : null;
					var tsComplexType = ts!=null ? Context.getType( ts.typeName ).toComplexType() : null;
					var tsTypePath : TypePath = ts!=null ? { pack: modPack, name: ts.typeName } : null;

					var layerType : TypeDefinition = {
						pos : curPos,
						name : "Layer_"+l.identifier,
						pack : modPack,
						doc: "IntGrid layer with auto-layer capabilities",
						kind : TDClass(parentTypePath),
						fields : (macro class {
							override public function new(json) {
								super(json);
								tileset = ${ ts==null ? null : macro new $tsTypePath( cast $v{ts.json} ) }
							}

							override function _getTileset() return tileset;
						}).fields,
					}

					// Auto-layer tileset class
					layerType.fields.push({
						name: "tileset",
						access: [APublic],
						kind: FVar( tsComplexType ),
						pos: curPos,
					});

					registerTypeDefinitionModule(layerType, projectFilePath);


				case Entities:
					var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Layer_Entities" }
					var baseEntityComplexType = Context.getType(baseEntityType.name).toComplexType();

					// Typed Entity arrays
					var entityArrayFields : Array<Field> = [];
					for(e in json.defs.entities) {
						var entityComplexType = Context.getType("Entity_"+e.identifier).toComplexType();
						entityArrayFields.push({
							name: "all_"+e.identifier,
							access: [APublic],
							kind: FVar( macro : Array<$entityComplexType> ),
							doc: "An array of all "+e.identifier+" instances",
							pos: curPos,
						});
					}
					var entityArrayExpr = entityArrayFields.map( f->macro $v{f.name} );

					var layerType : TypeDefinition = {
						pos : curPos,
						name : "Layer_"+l.identifier,
						doc: "Entity layer",
						pack : modPack,
						kind : TDClass(parentTypePath),
						fields : entityArrayFields.concat( (macro class {
							override public function new(json) {
								for( f in $a{entityArrayExpr} )
									Reflect.setField(this, f, []);

								super(json);
							}

							override function _instanciateEntity(json) {
								var c = Type.resolveClass($v{modPack.concat(["Entity_"]).join(".")}+json.__identifier);
								if( c==null )
									return null;
								else
									return cast Type.createInstance(c, [json]);
							}

							/**
								Get all entity instances. This methods returns generic Entity classes, so you won't have access to entity field values. You should prefer using specialized array accesses from fields "all_entityName".
							**/
							public inline function getAllUntyped() : Array<$baseEntityComplexType> {
								return cast _entities;
							}
						}).fields ),
					}
					// layerType.fields = layerType.fields.concat( entityArrayFields );

					registerTypeDefinitionModule(layerType, projectFilePath);


				case Tiles:
					var ts = tilesets.get(l.tilesetDefUid);
					var tsComplexType = Context.getType( ts.typeName ).toComplexType();
					var tsTypePath : TypePath = { pack: modPack, name: ts.typeName }

					var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Layer_Tiles" }
					var layerType : TypeDefinition = {
						pos : curPos,
						name : "Layer_"+l.identifier,
						pack : modPack,
						doc: "Tile layer",
						kind : TDClass(parentTypePath),
						fields : (macro class {
							override public function new(json) {
								super(json);

								tileset = new $tsTypePath( cast $v{ts.json} );
							}

							override function _getTileset() return tileset;
						}).fields,
					}
					// Tileset class
					layerType.fields.push({
						name: "tileset",
						access: [APublic],
						kind: FVar( tsComplexType ),
						pos: curPos,
					});
					registerTypeDefinitionModule(layerType, projectFilePath);


				case _:
					error("Unknown layer type "+l.type);
			}
		}
	}


	/**
		Create specialized Level class
	**/
	static function createLevelClass() {
		timer("levelClass");
		var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Level" }
		levelType = {
			pos : curPos,
			name : modName+"_Level",
			pack : modPack,
			doc: "Project specific Level class",
			kind : TDClass(parentTypePath),
			fields : (macro class {
				override public function new(project, json) {
					super(project, json);
				}

				override function fromJson(json) {
					super.fromJson(json);

					// Init quick access
					for(l in allUntypedLayers)
						Reflect.setField(this, "l_"+l.identifier, l);
				}

				override function _instanciateLayer(json:ldtk.Json.LayerInstanceJson) {
					var c = Type.resolveClass($v{modPack.concat(["Layer_"]).join(".")}+json.__identifier);
					if( c==null ) {
						ldtk.Project.error("Couldn't instanciate layer "+json.__identifier);
						return null;
					}
					else
						return cast Type.createInstance(c, [json]);
				}

				/**
					Get a layer using its identifier. WARNING: the class of this layer will be more generic than when using proper "f_layerName" fields.
				**/
				public function resolveLayer(id:String) : Null<ldtk.Layer> {
					load();
					for(l in allUntypedLayers)
						if( l.identifier==id )
							return l;
					return null;
				}
			}).fields,
		}

		// Create quick layer access fields
		for(l in json.defs.layers) {
			var layerComplexType = Context.getType("Layer_"+l.identifier).toComplexType();
			var property : Field = {
				name: "l_"+l.identifier,
				access: [APublic],
				kind: FProp("get","default", layerComplexType),
				doc: l.type+" layer",
				pos: curPos,
			}
			var getterFunc : Function = {
				expr: macro {
					load();
					return Reflect.field(this, $v{property.name});
				},
				ret: layerComplexType,
				args: [],
			}
			var getter : Field = {
				name: "get_l_"+l.identifier,
				kind: FFun(getterFunc),
				access: [ APrivate, AInline ],
				pos: curPos,
			}
			levelType.fields.push(property);
			levelType.fields.push(getter);
		}
		registerTypeDefinitionModule(levelType, projectFilePath);
	}


	/**
		Build quick levels access using their identifier
	**/
	static function createLevelAccess() {
		var levelAccessFields : Array<ObjectField> = json.levels.map( function(levelJson) {
			return {
				field: levelJson.identifier,
				expr: macro null,
				quotes: null,
			}
		});
		var levelComplexType = Context.getType(rawMod+"_Level").toComplexType();
		var levelAccessType : ComplexType = TAnonymous(json.levels.map( function(levelJson) : Field {
			return {
				name: levelJson.identifier,
				kind: FVar(macro : $levelComplexType),
				pos: curPos,
			}
		}));
		projectFields.push({
			name: "all_levels",
			doc: "A convenient way to access all levels in a type-safe environment",
			kind: FVar(levelAccessType, { expr:EObjectDecl(levelAccessFields), pos:curPos }),
			pos: curPos,
			access: [ APublic ],
		});
	}



	/**
		Create main Project class
	**/
	static function createProjectClass() {
		timer("projectClass");
		var projectDir = StringTools.replace(projectFilePath, "\\", "/");
		projectDir = projectDir.indexOf("/")<0 ? null : projectDir.substring(0, projectDir.lastIndexOf("/"));
		var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Project" }
		var levelTypePath : TypePath = { pack:modPack, name:levelType.name }
		var levelComplexType = Context.getType(levelType.name).toComplexType();
		var projectClass : TypeDefinition = {
			pos : curPos,
			name : modName,
			pack : modPack,
			kind : TDClass(parentTypePath),
			fields : (macro class {
				public var levels : Array<$levelComplexType> = [];

				/**
					If "overrideEmbedJson is provided, the embedded JSON from compilation-time will be ignored, and this JSON will be used instead.
				**/
				override public function new(?overrideEmbedJson:String) {
					super();
					projectDir = $v{projectDir};
					projectFilePath = $v{projectFilePath};
					parseJson( overrideEmbedJson!=null ? overrideEmbedJson : $v{fileContent} );
				}

				override function parseJson(json) {
					super.parseJson(json);

					levels = cast _untypedLevels.copy();

					// Init levels quick access
					for(l in _untypedLevels)
						Reflect.setField(all_levels, l.identifier, l);
				}

				override function _instanciateLevel(project, json) {
					return new $levelTypePath(project, json);
				}

				/**
					Get a level using its identifier
				**/
				public function resolveLevelIdentfier(id:String) : Null<$levelComplexType> {
					for(l in _untypedLevels)
						if( l.identifier==id )
							return cast l;
					return null;
				}
				/**
					Get a level using its UID
				**/
				public function resolveLevelUid(uid:Int) : Null<$levelComplexType> {
					for(l in _untypedLevels)
						if( l.uid==uid )
							return cast l;
					return null;
				}
			}).fields.concat( projectFields ),
		}
		registerTypeDefinitionModule(projectClass, projectFilePath);
	}




	/**
		Search a file in all classPaths + sub folders
	**/
	static function locateFile(searchFileName:String) : Null<String> {
		if( locateCache.exists(searchFileName) )
			return locateCache.get(searchFileName);

		var pending = Context.getClassPath().map( function(p) return StringTools.replace(p,"\\","/") );
		var cur = pending.pop();
		while( cur!=null ) {
			if( !sys.FileSystem.exists(cur) ) {
				cur = pending.pop();
				continue;
			}

			if( cur.indexOf("haxe/std")>0 ) { // ignore notoriously heavy folder
				cur = pending.pop();
				continue;
			}

			for(f in sys.FileSystem.readDirectory(cur) ) {
				var f = cur + ( cur.length>0 && cur.charAt(cur.length-1)!="/" ? "/" : "" ) + f;
				if( sys.FileSystem.isDirectory(f) )
					pending.push(f);
				else {
					var p = new haxe.io.Path(f);
					var name = p.file + ( p.ext!=null ? "."+p.ext : "" );
					if( name==searchFileName ) {
						// Found!
						locateCache.set(searchFileName, f);
						return f;
					}
				}
			}
			cur = pending.pop();
		}

		return null;
	}

	/**
		Register type definition
	**/
	static function registerTypeDefinitionModule(typeDef:TypeDefinition, projectFilePath:String) {
		var mod = Context.getLocalModule();
		Context.defineModule(mod, [typeDef]);
		Context.registerModuleDependency(mod, projectFilePath);
	}

	/**
		Stop with an error message
	**/
	static inline function error(msg:Dynamic, ?p:Position) : Dynamic {
		Context.fatalError( Std.string(msg), p==null ? Context.currentPos() : p );
		return null;
	}

	/**
		Print a compiler warning
	**/
	static inline function warning(msg:Dynamic, ?p:Position) {
		Context.warning( Std.string(msg), p==null ? Context.currentPos() : p );
	}

	/**
		Convert "#rrggbb" to "0xrrggbb" (String)
	**/
	static inline function hexColorToStr(hex:String) : String {
		return "0x"+hex.substr(1);
	}

	/**
		Convert "#rrggbb" to 0xrrggbb (Integer)
	**/
	static inline function hexColorToInt(hex:String) : Int {
		return Std.parseInt( "0x"+hex.substr(1) );
	}


	static var _t = -1.;
	static var _timerName = "";
	/**
		Debug timer
	**/
	static inline function timer(?name="") {
		#if ldtk_times
		if( _t>=0 ) {
			var l = '[LDtk.$_curMod] $_timerName: ${Std.int( ( haxe.Timer.stamp()-_t ) * 1000 ) / 1000}s';
			#if sys
			Sys.println(l);
			#else
			trace(l);
			#end
		}

		_timerName = name;
		_t = haxe.Timer.stamp();
		#end
	}
}

