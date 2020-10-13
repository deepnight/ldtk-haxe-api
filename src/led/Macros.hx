package led;

#if( !macro && !display )
#error "This class should not be used outside of macros"
#end

import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;

import led.Json;

class Macros {
	static var locateCache : Map<String,String>;

	#if debug
	static var _curMod : String;
	#end

	public static function buildTypes(projectFilePath:String) {
		// Read project file
		timer("read");
		var fi =
			try sys.io.File.read(projectFilePath)
			catch(e:Dynamic) error("File not found "+projectFilePath);

		var fileContent =
			try fi.readAll().toString()
			catch(e:Dynamic) error("Couldn't read file content "+projectFilePath);

		fi.close();

		// Init stuff
		locateCache = new Map();
		var pos = Context.currentPos();
		var mod = Context.getLocalModule();
		var modPack = mod.split(".");
		var modName = modPack.pop();
		// if( modPack.length==0 )
			// warning("It is recommended to move this file to its own package to avoid potential name conflicts.");
		#if debug
		_curMod = modName;
		#end
		var projectFields : Array<Field> = [];

		// Create a package name from the Module name
		// var firstLetterReg = ~/(_*[A-Z])([A-Za-z_0-9]*)/g;
		// firstLetterReg.match(mod);
		// var projectTypesPack = firstLetterReg.matched(1).toLowerCase() + firstLetterReg.matched(2);

		// Read JSON
		timer("json");
		var json : ProjectJson =
			try haxe.Json.parse(fileContent)
			catch(e:Dynamic) {
				var jsonPos = Context.makePosition({ min:0, max:0, file:projectFilePath });
				Context.info("Couldn't parse JSON "+projectFilePath, jsonPos);
				error("Failed to parse project JSON");
			}


		// Create project custom Enums
		timer("localEnums");
		for(e in json.defs.enums) {
			var enumTypeDef : TypeDefinition = {
				name: "Enum_"+e.identifier,
				pack: modPack,
				doc: "Enumeration of all possible "+e.identifier+" values",
				kind: TDEnum,
				pos: pos,
				fields: e.values.map( function(json) : Field {
					return {
						name: json.id,
						pos: pos,
						kind: FVar(null, null),
					}
				}),
			}
			registerTypeDefinitionModule(enumTypeDef, projectFilePath);
		}


		// Create an enum to represent all Entity IDs
		timer("entityIds");
		var allEntitiesEnum : TypeDefinition = {
			name: "EntityEnum",
			pack: modPack,
			kind: TDEnum,
			doc: "An enum representing all Entity IDs",
			pos: pos,
			fields: json.defs.entities.map( function(json) : Field {
				return {
					name: json.identifier,
					pos: pos,
					kind: FVar(null, null),
				}
			}),
		}
		registerTypeDefinitionModule(allEntitiesEnum, projectFilePath);


		// Link external HX Enums to actual HX files
		timer("externEnumParsing");
		var hxPackageReg = ~/package[ \t]+([\w.]+)[ \t]*;/gim;
		var externEnumTypes : Map<String,{ path:String, ct:ComplexType}> = new Map();
		for(e in json.defs.externalEnums){
			var p = new haxe.io.Path(e.externalRelPath);
			var fileName = p.file+"."+p.ext;
			switch p.ext {
				case null: // (should not happen, as the file extension is enforced in editor)

				case _.toLowerCase()=>"hx":
					// HX files
					var path = locateFile(fileName);
					if( path==null ) {
						error("External Enum file \""+fileName+"\" is used in LED Project but it can't be found in the current classPaths.");
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


		// Prepare a switch to resolve extern enum ID to runtime type identifier
		timer("entityClass");
		var cases : Array<Case> = [];
		for(e in externEnumTypes.keyValueIterator()) {
			cases.push({
				values: [ macro $v{e.key} ],
				expr: macro $v{e.value.path},
			});
		}
		var switchExpr : Expr = {
			expr: ESwitch( macro name, cases, macro throw "Unknown external enum name" ),
			pos: pos,
		}


		// Base Entity class for this project (with enum type)
		var entityEnumType = Context.getType(allEntitiesEnum.name).toComplexType();
		var entityEnumRef : Expr = {
			expr: EConst(CIdent( allEntitiesEnum.name )),
			pos:pos,
		}

		var parentTypePath : TypePath = { pack: ["led"], name:"Entity" }
		var baseEntityType : TypeDefinition = {
			pos : pos,
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
					return cast Type.resolveEnum($switchExpr);
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


		// Create Entities specialized classes (each one mihgt have specific custom fields)
		timer("specEntityClasses");
		for(e in json.defs.entities) {
			// Create entity class
			var parentTypePath : TypePath = { pack: baseEntityType.pack, name:baseEntityType.name }
			var entityType : TypeDefinition = {
				pos : pos,
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
						fields.push({ name: f.identifier+"_int", ct: f.canBeNull ? (macro : Null<UInt>) : (macro : UInt) });
						fields.push({ name: f.identifier+"_hex", ct: f.canBeNull ? (macro : Null<String>) : (macro : String) });

					case "Point":
						fields.push({ name: f.identifier, ct: f.canBeNull ? (macro : Null<led.Point>) : (macro : led.Point) });

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
						pos: pos,
					});
				}
			}

			registerTypeDefinitionModule(entityType, projectFilePath);
		}


		// Create tileset classes
		timer("tilesetClasses");
		var tilesets : Map<Int,{ typeName:String, json:TilesetDefJson }> = new Map();
		for(e in json.defs.tilesets) {
			// Create entity class
			var parentTypePath : TypePath = { pack: ["led"], name:"Tileset" }
			var tilesetType : TypeDefinition = {
				pos : pos,
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


		// Create Layers specialized classes
		timer("layerClasses");
		for(l in json.defs.layers) {
			switch l.type {
				case "IntGrid":

					if( l.autoTilesetDefUid==null ) {
						// IntGrid
						var parentTypePath : TypePath = { pack: ["led"], name:"Layer_IntGrid" }
						var layerType : TypeDefinition = {
							pos : pos,
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
						var parentTypePath : TypePath = { pack: ["led"], name:"Layer_IntGrid_AutoLayer" }
						var ts = l.autoTilesetDefUid!=null ? tilesets.get(l.autoTilesetDefUid) : null;
						var tsComplexType = ts!=null ? Context.getType( ts.typeName ).toComplexType() : null;
						var tsTypePath : TypePath = ts!=null ? { pack: modPack, name: ts.typeName } : null;

						var layerType : TypeDefinition = {
							pos : pos,
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

									tileset = ${ ts==null ? null : macro new $tsTypePath( $v{ts.json} ) }
								}

								override function _getTileset() return tileset;
							}).fields,
						}

						// Auto-layer tileset class
						layerType.fields.push({
							name: "tileset",
							access: [APublic],
							kind: FVar( tsComplexType ),
							pos: pos,
						});

						registerTypeDefinitionModule(layerType, projectFilePath);
					}


				case "AutoLayer":
					// Pure Auto-layer
					var parentTypePath : TypePath = { pack: ["led"], name:"Layer_AutoLayer" }
					var ts = l.autoTilesetDefUid!=null ? tilesets.get(l.autoTilesetDefUid) : null;
					var tsComplexType = ts!=null ? Context.getType( ts.typeName ).toComplexType() : null;
					var tsTypePath : TypePath = ts!=null ? { pack: modPack, name: ts.typeName } : null;

					var layerType : TypeDefinition = {
						pos : pos,
						name : "Layer_"+l.identifier,
						pack : modPack,
						doc: "IntGrid layer with auto-layer capabilities",
						kind : TDClass(parentTypePath),
						fields : (macro class {
							override public function new(json) {
								super(json);
								tileset = ${ ts==null ? null : macro new $tsTypePath( $v{ts.json} ) }
							}
							
							override function _getTileset() return tileset;
						}).fields,
					}

					// Auto-layer tileset class
					layerType.fields.push({
						name: "tileset",
						access: [APublic],
						kind: FVar( tsComplexType ),
						pos: pos,
					});

					registerTypeDefinitionModule(layerType, projectFilePath);


				case "Entities":
					var parentTypePath : TypePath = { pack: ["led"], name:"Layer_Entities" }
					var baseEntityComplexType = Context.getType(baseEntityType.name).toComplexType();
					var layerType : TypeDefinition = {
						pos : pos,
						name : "Layer_"+l.identifier,
						doc: "Entity layer",
						pack : modPack,
						kind : TDClass(parentTypePath),
						fields : (macro class {
							override public function new(json) {
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
						}).fields,
					}

					// Typed entity-arrays getters
					for(e in json.defs.entities) {
						var entityComplexType = Context.getType("Entity_"+e.identifier).toComplexType();
						layerType.fields.push({
							name: "all_"+e.identifier,
							access: [APublic],
							kind: FVar( macro : Array<$entityComplexType> ),
							doc: "An array of all "+e.identifier+" instances",
							pos: pos,
						});
					}
					registerTypeDefinitionModule(layerType, projectFilePath);


				case "Tiles":
					var ts = tilesets.get(l.tilesetDefUid);
					var tsComplexType = Context.getType( ts.typeName ).toComplexType();
					var tsTypePath : TypePath = { pack: modPack, name: ts.typeName }

					var parentTypePath : TypePath = { pack: ["led"], name:"Layer_Tiles" }
					var layerType : TypeDefinition = {
						pos : pos,
						name : "Layer_"+l.identifier,
						pack : modPack,
						doc: "Tile layer",
						kind : TDClass(parentTypePath),
						fields : (macro class {
							override public function new(json) {
								super(json);

								tileset = new $tsTypePath( $v{ts.json} );
							}

							override function _getTileset() return tileset;
						}).fields,
					}
					// Tileset class
					layerType.fields.push({
						name: "tileset",
						access: [APublic],
						kind: FVar( tsComplexType ),
						pos: pos,
					});
					registerTypeDefinitionModule(layerType, projectFilePath);


				case _:
					error("Unknown layer type "+l.type);
			}
		}



		// Create Level specialized class
		timer("levelClass");
		var parentTypePath : TypePath = { pack: ["led"], name:"Level" }
		var levelType : TypeDefinition = {
			pos : pos,
			name : modName+"_Level",
			pack : modPack,
			doc: "Project specific Level class",
			kind : TDClass(parentTypePath),
			fields : (macro class {
				override public function new(json) {
					super(json);

					// Init quick access
					for(l in allUntypedLayers)
						Reflect.setField(this, "l_"+l.identifier, l);
				}

				override function _instanciateLayer(json:led.Json.LayerInstanceJson) {
					var c = Type.resolveClass($v{modPack.concat(["Layer_"]).join(".")}+json.__identifier);
					if( c==null )
						throw "Couldn't instanciate layer "+json.__identifier;
					else
						return cast Type.createInstance(c, [json]);
				}

				/**
					Get a layer using its identifier. WARNING: the class of this layer will be more generic than when using proper "f_layerName" fields.
				**/
				public function resolveLayer(id:String) : Null<led.Layer> {
					for(l in allUntypedLayers)
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
				kind: FVar( Context.getType("Layer_"+l.identifier).toComplexType() ),
				doc: l.type+" layer",
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
			name: "all_levels",
			doc: "A convenient way to access all levels in a type-safe environment",
			kind: FVar(levelAccessType, { expr:EObjectDecl(levelAccessFields), pos:pos }),
			pos: pos,
			access: [ APublic ],
		});


		// Create Project extended class
		timer("projectClass");
		var projectDir = StringTools.replace(projectFilePath, "\\", "/");
		projectDir = projectDir.indexOf("/")<0 ? null : projectDir.substring(0, projectDir.lastIndexOf("/"));
		var parentTypePath : TypePath = { pack: ["led"], name:"Project" }
		var levelTypePath : TypePath = { pack:modPack, name:levelType.name }
		var levelComplexType = Context.getType(levelType.name).toComplexType();
		var projectClass : TypeDefinition = {
			pos : pos,
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

				override function _instanciateLevel(json) {
					return new $levelTypePath(json);
				}

				/**
					Get a level using its identifier
				**/
				public function resolveLevel(id:String) : Null<$levelComplexType> {
					for(l in _untypedLevels)
						if( l.identifier==id )
							return cast l;
					return null;
				}
			}).fields.concat( projectFields ),
		}
		registerTypeDefinitionModule(projectClass, projectFilePath);


		haxe.macro.Compiler.keep( Context.getLocalModule() );
		timer("end");
		return macro : Void;
	}



	static var hexColorReg = ~/^#([0-9abcdefABCDEF]{6})$/g;

	// Search a file in all classPaths + sub folders
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

	static function registerTypeDefinitionModule(typeDef:TypeDefinition, projectFilePath:String) {
		var mod = Context.getLocalModule();
		Context.defineModule(mod, [typeDef]);
		Context.registerModuleDependency(mod, projectFilePath);
	}

	static inline function error(msg:Dynamic, ?p:Position) : Dynamic {
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
		// if( _t>=0 )
		// 	trace(_curMod+" => "+ Std.int( ( haxe.Timer.stamp()-_t ) * 1000 ) / 1000  + "s " + _timerName );
		// _timerName = name;
		// _t = haxe.Timer.stamp();
		#end
	}
}

