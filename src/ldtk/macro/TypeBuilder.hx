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
	static var isSingleWorld = false;

	// Module infos
	static var rawMod : String = "";
	static var modPack : Array<String> = [];
	static var modName : String = "";
	static var curPos(get,never) : Position;
		inline static function get_curPos() return Context.currentPos();

	// Types
	static var projectFields : Array<Field> = [];
	static var externEnumTypes : Map<String,{ path:String, ct:ComplexType}> = new Map();
	static var externEnumResolverSwitch : Expr;
	static var entityIdsEnum : TypeDefinition;
	static var baseEntityType : TypeDefinition;
	static var levelType : TypeDefinition;
	static var tilesets : Map<Int,{ typeName:String, json:TilesetDefJson }> = new Map();
	static var localEnums : Map<Int, TypeDefinition> = new Map();

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
		isSingleWorld = false;
		#if ldtk_times
		_curMod = modName;
		#end

		// if( modPack.length==0 )
			// warning("It is recommended to move this file to its own package to avoid potential name conflicts.");

		loadJson();
		createLocalEnums();
		createEntityIdEnum();
		linkExternalEnums();
		createBaseEntityClass();
		createSpecializedEntitiesClasses();
		createTilesetsClasses();
		createLayersClasses();
		createLevelClass();
		createProjectWorldClass();
		for(worldJson in json.worlds)
			createSpecializedWorldClass(worldJson);
		createTilesetAccess();
		createWorldsAccessInProject();
		createProjectToc();
		// if( isSingleWorld )
		// 	addSingleWorldFields();
		createProjectClass();

		haxe.macro.Compiler.keep( Context.getLocalModule() );
		timer("end");
		return macro : Void;
	}


	static function getEnumDefJson(id:String) : Null<EnumDefJson> {
		for(ed in json.defs.enums)
			if( ed.identifier==id )
				return ed;

		for(ed in json.defs.externalEnums)
			if( ed.identifier==id )
				return ed;

		return null;
	}


	static function getTilesetDefJson(uid:Null<Int>) : Null<TilesetDefJson> {
		if( uid==null || uid<0 )
			return null;

		for(d in json.defs.tilesets)
			if( d.uid==uid )
				return d;
		return null;
	}


	static function sanitizeIdentifier(id:String, capitalize=true) {
		if( id==null )
			id = "_";

		// Replace any invalid char with "_"
		var reg = ~/([^a-z0-9_])+/gi;
		id = reg.replace(id, "_");

		// Capitalize
		if( capitalize ) {
			var reg = ~/^(_*)([a-z])([a-zA-Z0-9_]*)/g; // extract first letter, if it's lowercase
			if( reg.match(id) )
				id = reg.matched(1) + reg.matched(2).toUpperCase() + reg.matched(3);
		}

		return id;
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

		// Create dummy JSON world
		if( json.worlds==null || json.worlds.length==0 ) {
			json.worlds = [ World.createDummyJson(json) ];
			isSingleWorld = true;
		}

		if( dn.Version.lower(json.jsonVersion, MIN_JSON_VERSION, true) )
			error('JSON version: "${json.jsonVersion}", required at least: "$MIN_JSON_VERSION"');
	}


	/**
		Create enums from project EnumDefs
	**/
	static function createLocalEnums() {
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
						name: sanitizeIdentifier(json.id),
						pos: curPos,
						kind: FVar(null, null),
					}
				}),
			}
			localEnums.set(e.uid, enumTypeDef);
			registerTypeDefinitionModule(enumTypeDef, projectFilePath);
		}
	}


	/**
		Create a single enum that contains all Entity IDs
	**/
	static function createEntityIdEnum() {
		timer("entityIds");
		entityIdsEnum = {
			name: modName+"_EntityEnum",
			pack: modPack,
			kind: TDEnum,
			doc: "An enum representing all Entity IDs",
			pos: curPos,
			fields: json.defs.entities.map( function(json) : Field {
				return {
					name: sanitizeIdentifier(json.identifier),
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
		var resolverCases : Array<Case> = [];

		for(e in json.defs.externalEnums){
			var p = new haxe.io.Path(e.externalRelPath);
			var fileName = p.file+"."+p.ext;
			switch p.ext {
				case null: // (should not happen, as the file extension is enforced in editor)

				// HX files
				case _.toLowerCase()=>"hx":
					// Check file
					var path = locateHxFile(fileName);
					if( path==null ) {
						error("External Enum file \""+fileName+"\" is used in LDtk Project but it can't be found in the current classPaths.");
						continue;
					}

					// Read HX file to find its package
					var fi = sys.io.File.read(path, false);
					var fileContent = fi.readAll().toString();
					fi.close();
					var enumPack = hxPackageReg.match(fileContent) ? hxPackageReg.matched(1)+"." : "";
					var enumMod = enumPack + p.file;

					// Create resolver expr
					resolverCases.push({
						values: [ macro $v{e.identifier} ],
						expr: macro {
							var e =
								try Type.resolveEnum($v{enumPack + e.identifier})
								catch(_) null;
							if( e!=null )
								Type.createEnum(e, enumValueId);
							else
								null;
						},
					});

					// Register complex type
					var ct =
						try Context.getType(enumMod+"."+e.identifier).toComplexType()
						catch(e:Dynamic) error("Cannot resolve the external HX Enum "+e.ide+" from "+enumMod+", maybe the package is wrong?");
					externEnumTypes.set(e.identifier, {
						path: enumPack+e.identifier,
						ct: ct
					});


				// CastleDB
				case _.toLowerCase()=>"cdb":
					// Lookup file
					var dir = dn.FilePath.extractDirectoryWithoutSlash(projectFilePath, true);
					var path = dn.FilePath.cleanUp(dir+"/"+e.externalRelPath, true);
					if( !sys.FileSystem.exists(path) ) {
						error("External Enum file \""+fileName+"\" is used in LDtk Project but it can't be found at: "+path);
						continue;
					}

					// Need classpath to Castle DB instance to resolve its enums (use -D ldtkCastle=...)
					var cdbFull = Context.definedValue("ldtkCastle");
					if( cdbFull==null )
						Context.fatalError('Missing "-D ldtkCastle=full.package.of.CastleDbClass". This is necessary because the LDtk project uses a CastleDB file.', Context.currentPos());

					var cdbPack = cdbFull.split(".");
					var cdbClassName = cdbPack.pop();

					// This is where dark magic happens: we *hope* that the CDB class will exist at the end of the compilation time
					var ct : ComplexType = TPath({ name:cdbClassName, pack:cdbPack, sub:e.identifier+"Kind" });

					// Create resolver expr
					var cdbExpr : Expr = {
						expr: EConst( CIdent(cdbClassName) ),
						pos: Context.currentPos(),
					}
					resolverCases.push({
						values: [ macro $v{e.identifier} ],
						expr: macro {
							var cdb : Dynamic = cast $cdbExpr; // CastleDB class
							var cdbEnum : Dynamic = Reflect.field(cdb, $v{e.identifier}); // Sheet object
							var byId : Map<String,Dynamic> = cdbEnum.byId; // ID resolver in sheet
							return byId.get(enumValueId).id;
						},
					});

					// Register complex type
					externEnumTypes.set(e.identifier, {
						path: e.identifier,
						ct: ct,
					});

				case _:
					error("Unsupported external enum file format "+p.ext);
			}
		}

		externEnumResolverSwitch = {
			expr: ESwitch(
				macro name,
				resolverCases,
				macro { ldtk.Project.error("Unknown external enum name: "+name); null; }
			),
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

				override public function new(p, json) {
					super(p, json);

					entityType = Type.createEnum($entityEnumRef, p.capitalize(json.__identifier));
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
				fields : (macro class { }).fields,
			}

			addFieldsToTypeDef(entityType, e.fieldDefs);
			registerTypeDefinitionModule(entityType, projectFilePath);
		}
	}



	/**
		Add listed FieldDefs to a specificied macro TypeDefinition
	**/
	static function addFieldsToTypeDef(typeDef:TypeDefinition, fieldDefs:Array<FieldDefJson>) {
		var arrayReg = ~/Array<(.*)>/gi;
		for(f in fieldDefs) {
			var isArray = arrayReg.match(f.__type);
			var typeName = isArray ? arrayReg.matched(1) : f.__type;

			var fields : Array<{ name:String, ?desc:String, ct:ComplexType, ?customTypeFieldKind:Dynamic }> = [];
			switch typeName {
				case "Int":
					fields.push({ name: f.identifier, ct: f.canBeNull ? (macro : Null<Int>) : (macro : Int) });

				case "Float":
					fields.push({ name: f.identifier, ct: f.canBeNull ? (macro : Null<Float>) : (macro : Float) });

				case "String":
					fields.push({ name: f.identifier, ct: f.canBeNull ? (macro : Null<String>) : (macro : String) });

				case "FilePath":
					fields.push({ name: f.identifier, ct: f.canBeNull ? (macro : Null<String>) : (macro : String) });
					fields.push({
						name: f.identifier+"_bytes",
						desc: "Contains the full `haxe.io.Bytes` of corresponding file, as available at compilation time.",
						ct: f.canBeNull ? (macro : Null<haxe.io.Bytes>) : (macro : haxe.io.Bytes),
						customTypeFieldKind: FProp("get", "never", macro : Null<haxe.io.Bytes>)
					});
					// Build getter
					var getterFunc : Function = {
						expr: macro {
							var relPath = Reflect.field(this, "f_"+$v{f.identifier});
							return relPath==null ? null : untypedProject.getAsset(relPath);
						},
						args: [],
						ret: macro : Null<haxe.io.Bytes>,
					}
					typeDef.fields.push({
						name: "get_f_"+f.identifier+"_bytes",
						access: [APrivate],
						kind: FFun(getterFunc),
						pos: curPos,
					});

				case "Bool":
					fields.push({ name: f.identifier, ct: macro : Bool });

				case "Color":
					fields.push({
						name: f.identifier+"_int",
						desc: "Color code as Integer (`0xrrggbb` format)",
						ct: f.canBeNull ? (macro : Null<Int>) : (macro : Int)
					});
					fields.push({
						name: f.identifier+"_hex",
						desc: "Color code as String (`\"#rrggbb\"` format)",
						ct: f.canBeNull ? (macro : Null<String>) : (macro : String)
					});

				case "Point":
					fields.push({ name: f.identifier, ct: f.canBeNull ? (macro : Null<ldtk.Point>) : (macro : ldtk.Point) });

				case "EntityRef":
					fields.push({
						name: f.identifier,
						desc: "Entity reference informations",
						ct: f.canBeNull ? (macro : Null<ldtk.Json.EntityReferenceInfos>) : (macro : ldtk.Json.EntityReferenceInfos),
					});

				case _.indexOf("LocalEnum.") => 0:
					var enumId = typeName.substr( typeName.indexOf(".")+1 );
					var enumType = Context.getType( "Enum_"+enumId ).toComplexType();
					fields.push({
						name: f.identifier,
						desc: "Enum value of "+enumId+". To retrieve the enum color or tile, use `project` methods (eg. `project.getEnumColor(myEnumValue)`)",
						ct: f.canBeNull ? (macro : Null<$enumType>) : (macro : $enumType)
					});

				case _.indexOf("ExternEnum.") => 0:
					var enumId = typeName.substr( typeName.indexOf(".")+1 );
					if( !externEnumTypes.exists(enumId) )
						Context.fatalError("Unknown external enum "+enumId, Context.currentPos());
					var ct = externEnumTypes.get(enumId).ct;
					var ed = getEnumDefJson(enumId);
					fields.push({
						name: f.identifier,
						desc: "Enum value of "+enumId+". To retrieve the enum color or tile, use `project` methods (eg. `project.getEnumColor(myEnumValue)`)" + (ed==null?"":"\nExtern source: "+ed.externalRelPath),
						ct: f.canBeNull ? (macro : Null<$ct>) : (macro : $ct)
					});

				case "Tile":
					#if heaps
					fields.push({
						name: f.identifier+"_getTile",
						ct: f.canBeNull ? (macro : Void->Null<h2d.Tile>) : (macro : Void->h2d.Tile)
					});
					#end
					fields.push({
						name: f.identifier+"_infos",
						ct: f.canBeNull ? (macro : Null<ldtk.Json.TilesetRect>) : (macro : ldtk.Json.TilesetRect)
					});

				case _:
					error("Unsupported field type "+typeName); // TODO add some extra context
			}

			// Add fields
			for(fi in fields) {
				if( isArray ) {
					// Turn field into Array<...>
					switch fi.ct {
					case TPath(_), TFunction(_):
						fi.ct = TPath({
							name: "Array",
							pack: [],
							params: [ TPType(fi.ct) ],
						});

					case _: error("Cannot turn custom field type "+fi.ct.getName()+" into an Array");
					}
				}

				typeDef.fields.push({
					name: "f_"+fi.name,
					access: [ APublic ],
					kind: fi.customTypeFieldKind==null ? FVar(fi.ct) : fi.customTypeFieldKind,
					doc: fi.desc!=null ? fi.desc : "Custom field "+fi.name+" ("+f.__type+")",
					pos: curPos,
				});
			}
		}
	}


	/**
		Create tileset classes
	**/
	static function createTilesetsClasses() {
		timer("tilesetClasses");
		tilesets = new Map();
		for(t in json.defs.tilesets) {
			// Create tileset class
			var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Tileset" }
			var tilesetType : TypeDefinition = {
				pos : curPos,
				name : "Tileset_"+t.identifier,
				pack : modPack,
				doc: 'Tileset class of atlas "${t.relPath}"',
				kind : TDClass(parentTypePath),
				fields : (macro class {
					override public function new(p,json) {
						super(p,json);
					}
				}).fields,
			}

			// Enum tags
			if( t.tagsSourceEnumUid!=null ) {
				var enumTypeDef = localEnums.get(t.tagsSourceEnumUid);
				var enumComplexType = Context.getType(enumTypeDef.name).toComplexType();
				var enumTypeExpr = { pos:curPos, expr:EConst(CIdent(enumTypeDef.name)) }
				tilesetType.fields = tilesetType.fields.concat( (macro class {

					/** Return TRUE if the specifiied tile ID was tagged with given enum `tag`. **/
					public inline function hasTag(tileId:Int, tag:$enumComplexType) {
						final allTileIds = untypedTags.get( tag.getName() );
						return allTileIds==null ? false : allTileIds.exists(tileId);
					}

					/** Return an array of all tags associated with give tile ID. WARNING: this allocates a new array on call. **/
					public function getAllTags(tileId:Int) : Array<$enumComplexType> {
						var all = [];
						for(t in untypedTags.keys()) {
							if( untypedTags.get(t).exists(tileId) )
								all.push( Type.createEnum( $enumTypeExpr, t) );
						}
						return all;
					}
				}).fields );
			}

			registerTypeDefinitionModule(tilesetType, projectFilePath);
			tilesets.set(t.uid, {
				typeName: tilesetType.name,
				json: t,
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

					if( l.tilesetDefUid==null ) {
						// IntGrid
						var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Layer_IntGrid" }
						var layerType : TypeDefinition = {
							pos : curPos,
							name : "Layer_"+l.identifier,
							pack : modPack,
							doc: "IntGrid layer",
							kind : TDClass(parentTypePath),
							fields : (macro class {
								override public function new(p,json) {
									super(p,json);

									for(v in $v{l.intGridValues} ) {
										valueInfos.set( v.value, {
											value: v.value,
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
						if( l.tilesetDefUid==null || !tilesets.exists(l.tilesetDefUid) )
							error('Missing tileset in layer "${l.identifier}"');

						var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Layer_IntGrid_AutoLayer" }
						var tilesetCT = Context.getType( tilesets.get(l.tilesetDefUid).typeName ).toComplexType();

						var layerType : TypeDefinition = {
							pos : curPos,
							name : "Layer_"+l.identifier,
							pack : modPack,
							doc: "IntGrid layer with auto-layer capabilities",
							kind : TDClass(parentTypePath),
							fields : (macro class {
								public var tileset(get,never) : $tilesetCT;
									inline function get_tileset() return cast untypedTileset;

								override public function new(p,json) {
									super(p,json);

									// Store IntGrid values extra infos
									for(v in $v{l.intGridValues} ) {
										valueInfos.set( v.value, {
											value: v.value,
											identifier: v.identifier,
											color: Std.parseInt( "0x"+v.color.substr(1) ),
										});
									}
								}
							}).fields,
						}

						registerTypeDefinitionModule(layerType, projectFilePath);
					}


				case AutoLayer:
					// Pure Auto-layer
					if( l.tilesetDefUid==null || !tilesets.exists(l.tilesetDefUid) )
						error('Missing tileset in layer "${l.identifier}"');

					var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Layer_AutoLayer" }
					var tilesetCT = Context.getType( tilesets.get(l.tilesetDefUid).typeName ).toComplexType();

					var layerType : TypeDefinition = {
						pos : curPos,
						name : "Layer_"+l.identifier,
						pack : modPack,
						doc: "IntGrid layer with auto-layer capabilities",
						kind : TDClass(parentTypePath),
						fields : (macro class {
							public var tileset(get,never) : $tilesetCT;
							inline function get_tileset() return cast untypedTileset;

							override public function new(p,json) {
								super(p,json);
							}
						}).fields,
					}

					registerTypeDefinitionModule(layerType, projectFilePath);


				case Entities:
					var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Layer_Entities" }
					var baseEntityComplexType = Context.getType(baseEntityType.name).toComplexType();

					// Typed Entity arrays
					var entityArrayFields : Array<Field> = [];
					for(e in json.defs.entities) {
						if( !matchesTags(e.tags, l.requiredTags, l.excludedTags) )
							continue;

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
							override public function new(p,json) {
								for( f in $a{entityArrayExpr} )
									Reflect.setField(this, f, []);

								super(p,json);
							}

							override function _instanciateEntity(json) {
								var c = Type.resolveClass($v{modPack.concat(["Entity_"]).join(".")}+json.__identifier);
								if( c==null )
									return null;
								else
									return cast Type.createInstance(c, [untypedProject, json]);
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
					if( l.tilesetDefUid==null || !tilesets.exists(l.tilesetDefUid) )
						error('Missing default tileset in layer "${l.identifier}"');

					var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Layer_Tiles" }
					var tilesetCT = Context.getType( tilesets.get(l.tilesetDefUid).typeName ).toComplexType();
					var layerType : TypeDefinition = {
						pos : curPos,
						name : "Layer_"+l.identifier,
						pack : modPack,
						doc: "Tile layer",
						kind : TDClass(parentTypePath),
						fields : (macro class {
							public var tileset(get,never) : $tilesetCT;
								inline function get_tileset() return cast untypedTileset;


							override public function new(p,json) {
								super(p,json);
							}
						}).fields,
					}
					registerTypeDefinitionModule(layerType, projectFilePath);


				case _:
					error("Unknown layer type "+l.type);
			}
		}
	}


	static function matchesTags(elementTags:Array<String>, requireds:Array<String>, excludeds:Array<String>) : Bool {
		var tmap = new Map();
		for(t in elementTags)
			tmap.set(t,t);

		if( requireds.length>0 ) {
			var hasOne = false;
			for(t in requireds)
				if( tmap.exists(t) ) {
					hasOne = true;
					break;
				}
			if( !hasOne )
				return false;
		}

		for(t in excludeds)
			if( tmap.exists(t) )
				return false;

		return true;
	}


	/**
		Create specialized world class with quick level access
	**/
	static function createProjectWorldClass() {
		timer("projectWorldClass");

		// World class
		var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"World" }
		var levelTypePath : TypePath = { pack:modPack, name:levelType.name }
		var levelComplexType = Context.getType(levelType.name).toComplexType();
		var worldType = {
			pos : curPos,
			name : modName+"_World",
			pack : modPack,
			kind : TDClass(parentTypePath),
			fields : (macro class {
				public var levels : Array<$levelComplexType> = [];

				override public function new(project, arrayIndex, json) {
					super(project, arrayIndex, json);
				}

				override function fromJson(json:Dynamic) {
					super.fromJson(json);

					levels = cast _untypedLevels.copy();
				}

				override function _instanciateLevel(project, arrayIndex:Int, json) {
					return new $levelTypePath(project, arrayIndex, json);
				}

				/** Get a level from its UID (int) or Identifier (string) **/
				public function getLevel(?uid:Int, ?idOrIid:String) : Null<$levelComplexType> {
					if( uid==null && idOrIid==null )
						return null;

					for(l in _untypedLevels)
						if( idOrIid!=null && ( l.identifier==idOrIid || l.iid==idOrIid ) || uid!=null && l.uid==uid )
							return cast l;
					return null;
				}

				/**
					Get a level using a world pixel coord
				**/
				public function getLevelAt(worldX:Float, worldY:Float) : Null<$levelComplexType> {
					for(l in _untypedLevels)
						if( worldX>=l.worldX && worldX<l.worldX+l.pxWid && worldY>=l.worldY && worldY<l.worldY+l.pxHei )
							return cast l;
					return null;
				}
			}).fields,
		}

		registerTypeDefinitionModule(worldType, projectFilePath);
	}


	/**
		Create specialized world class with quick level access
	**/
	static function createSpecializedWorldClass(worldJson:WorldJson) {
		timer("specWorldClass");

		// Level access in world class
		var accessFields : Array<ObjectField> = worldJson.levels.map( function(j) {
			return {
				field: j.identifier,
				expr: macro null,
				quotes: null,
			}
		});
		var complexType = Context.getType(rawMod+"_Level").toComplexType();
		var accessType : ComplexType = TAnonymous(worldJson.levels.map( function(j) : Field {
			return {
				name: j.identifier,
				kind: FVar(macro : $complexType),
				pos: curPos,
			}
		}));


		// Add single-world convenience shortcuts to project class
		if( isSingleWorld ) {
			var levelComplexType = Context.getType(levelType.name).toComplexType();

			var shortcutFields = (macro class {
				@:deprecated('DEPRECATED! Use "myProject.all_worlds.Default.all_levels"') @:noCompletion
				public var all_levels(get,never) : $accessType;
					function get_all_levels() return this.all_worlds.Default.all_levels;

				@:deprecated('DEPRECATED! Use "myProject.all_worlds.Default.levels"') @:noCompletion
				public var levels(get,never) : Array<$levelComplexType>;
					function get_levels() return this.all_worlds.Default.levels;

				@:deprecated('DEPRECATED! Use "myProject.all_worlds.Default.layout"') @:noCompletion
				public var worldLayout(get,never) : ldtk.Json.WorldLayout;
					function get_worldLayout() return this.all_worlds.Default.layout;

				@:deprecated('DEPRECATED! Use "myProject.all_worlds.Default.getLevel"') @:noCompletion
				public function getLevel(?uid:Int, ?idOrIid:String) : Null<$levelComplexType> {
					return this.all_worlds.Default.getLevel(uid,idOrIid);
				}

				@:deprecated('DEPRECATED! Use "myProject.all_worlds.Default.getLevelAt"') @:noCompletion
				public function getLevelAt(x:Int, y:Int) : Null<$levelComplexType> {
					return this.all_worlds.Default.getLevelAt(x,y);
				}
			}).fields;

			for(f in shortcutFields)
				projectFields.push(f);
		}



		// World class
		var parentTypePath : TypePath = { pack:modPack, name:modName+"_World" }
		var levelTypePath : TypePath = { pack:modPack, name:levelType.name }
		var levelComplexType = Context.getType(levelType.name).toComplexType();
		var worldType = {
			pos : curPos,
			name : modName+"_World_"+worldJson.identifier,
			pack : modPack,
			kind : TDClass(parentTypePath),
			fields : (macro class {
				/** A convenient way to access all worlds in a type-safe environment **/
				public var all_levels : $accessType;

				override public function new(project, arrayIndex, json) {
					super(project, arrayIndex, json);
				}

				override function fromJson(json:Dynamic) {
					super.fromJson(json);

					// Init levels quick access
					all_levels = cast {}
					for(l in _untypedLevels)
						Reflect.setField(all_levels, l.identifier, l);
				}
			}).fields,
		}
		registerTypeDefinitionModule(worldType, projectFilePath);
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
				override public function new(project, arrayIdx, json) {
					super(project, arrayIdx, json);
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
						return cast Type.createInstance(c, [untypedProject, json]);
				}

				/**
					Get a layer using its identifier. WARNING: the class of this layer will be more generic than when using proper `l_layerName` fields.
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

		addFieldsToTypeDef(levelType, json.defs.levelFields);
		registerTypeDefinitionModule(levelType, projectFilePath);
	}


	/**
		Build quick levels access using their identifier
	**/
	static function createWorldsAccessInProject() {
		var accessFields : Array<ObjectField> = json.worlds.map( function(worldJson) {
			return {
				field: worldJson.identifier,
				expr: macro null,
				quotes: null,
			}
		});
		var accessType : ComplexType = TAnonymous(json.worlds.map( function(worldJson) : Field {
			var complexType = Context.getType(rawMod+"_World_"+worldJson.identifier).toComplexType();
			return {
				name: worldJson.identifier,
				kind: FVar(macro : $complexType),
				pos: curPos,
			}
		}));

		projectFields.push({
			name: "all_worlds",
			doc: "A convenient way to access all worlds in a type-safe environment",
			kind: FVar(accessType, { expr:EObjectDecl(accessFields), pos:curPos }),
			pos: curPos,
			access: [ APublic ],
		});
	}


	/**
		Build quick tileset access using their identifier
	**/
	static function createTilesetAccess() {
		var objectFields : Array<Field> = [];
		// var constructors : Array<Expr> = [];

		for(t in tilesets) {
			var ct = Context.getType(t.typeName).toComplexType();
			objectFields.push({
				name: t.json.identifier,
				kind: FVar(ct),
				pos: curPos,
			});

			// var path : TypePath = { pack:modPack, name:t.typeName }
			// constructors.push( macro function(projectJson:) {} );
			// constructors.push( macro new $path() );
		}
		var accessType : ComplexType = TAnonymous(objectFields);

		projectFields.push({
			name: "all_tilesets",
			doc: "A convenient way to access all tilesets in a type-safe environment",
			kind: FVar(accessType),
			pos: curPos,
			access: [ APublic ],
		});
	}


	/**
		Create the `toc` anonymous structure in Project main class.
		It is populated in Project.parseJson()
	**/
	static function createProjectToc() {
		timer("projectToc");
		var accessType : ComplexType = TAnonymous(json.defs.entities.map( function(ed) : Field {
			return {
				name: ed.identifier,
				kind: FVar(macro : Array<ldtk.Json.TocInstanceData>),
				pos: curPos,
			}
		}));
		var accessFields: Array<ObjectField> = json.defs.entities.map( function(ed) {
			return {
				field: ed.identifier,
				expr: macro [],
				quotes: null,
			}
		});
		projectFields.push({
			name: "toc",
			doc: "This table of content contains the list of all elements whose 'Add to table of content' option is enabled.",
			kind: FVar(accessType, { expr:EObjectDecl(accessFields), pos:curPos }),
			pos: curPos,
			access: [ APublic ],
		});
	}


	// static function addSingleWorldFields() {
		// var fieldName = "all_levels";
		// var getter : Function = {
		// 	expr: macro return all_worlds.Default.all_levels,
		// 	args: [],
		// 	ret: (macro : Dynamic),
		// }

		// projectFields.push({
		// 	name: fieldName,
		// 	pos: curPos,
		// 	kind: FProp("get","never", getter.ret),
		// 	access: [APublic],
		// });

		// projectFields.push({
		// 	name: "get_"+fieldName,
		// 	pos: curPos,
		// 	kind: FFun(getter),
		// });
	// }


	/**
		Create main Project class
	**/
	static function createProjectClass() {
		timer("projectClass");
		var projectDir = StringTools.replace(projectFilePath, "\\", "/");
		projectDir = projectDir.indexOf("/")<0 ? null : projectDir.substring(0, projectDir.lastIndexOf("/"));
		var parentTypePath : TypePath = { pack: [APP_PACKAGE], name:"Project" }
		// var worldTypePath : TypePath = { pack:modPack, name:modName+"_World" }
		var worldCT = Context.getType(modName+"_World").toComplexType();
		var projectClass : TypeDefinition = {
			pos : curPos,
			name : modName,
			pack : modPack,
			kind : TDClass(parentTypePath),
			fields : (macro class {

				/** An array access to all Worlds.
					IMPORTANT: the returned World classes will use the generic world class, and not the specialized classes (the ones available through `all_worlds.SomeWorld`). This means that worlds from this iterator won't have unique fields like `all_levels`. **/
				public var worlds(get,never) : Array<$worldCT>;
					inline function get_worlds() return cast _untypedWorlds;

				/**
					If "overrideEmbedJson is provided, the embedded JSON from compilation-time will be ignored, and this JSON will be used instead.
				**/
				override public function new(?overrideEmbedJson:String) {
					super();
					this._enumTypePrefix = $v{modPack.concat(["Enum_"]).join(".")};
					projectDir = $v{projectDir};
					projectFilePath = $v{projectFilePath};
					parseJson( overrideEmbedJson!=null ? overrideEmbedJson : $v{fileContent} );
				}

				override function parseJson(json) {
					super.parseJson(json);

					// Init worlds quick access
					for(w in _untypedWorlds)
						Reflect.setField(all_worlds, w.identifier, w);
				}


				/** Return a world instance from its IID **/
				public function getWorld(iid:String) : Null<$worldCT> {
					for(w in worlds)
						if( w.iid==iid )
							return w;
					return null;
				}


				override function _instanciateTileset(project, json) {
					var c = Type.resolveClass( $v{modPack.concat(["Tileset_"]).join(".")}+json.identifier );
					if( c==null )
						return null;
					else
						return cast Type.createInstance(c, [project, json]);
				}

				override function _instanciateWorld(untypedProject, arrayIndex:Int, json) {
					var classId = $v{modPack.concat([modName+"_World_"]).join(".")} + json.identifier;
					var c = Type.resolveClass(classId);
					if( c==null ) {
						ldtk.Project.error("Couldn't instanciate World class "+classId);
						return null;
					}
					else
						return cast Type.createInstance(c, [untypedProject, arrayIndex, json]);
					// return new $worldTypePath(project, arrayIndex, json);
				}

				@:haxe.warning("-WUnusedPattern")
				override function _resolveExternalEnumValue<T>(name:String, enumValueId:String) : T {
					return $externEnumResolverSwitch;
				}
			}).fields.concat( projectFields ),
		}
		registerTypeDefinitionModule(projectClass, projectFilePath);
	}




	/**
		Search a file in all classPaths + sub folders
	**/
	static function locateHxFile(searchFileName:String) : Null<String> {
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

