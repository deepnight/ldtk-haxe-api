package ldtk;

/**
	LDtk Project JSON importer for Haxe.

	USAGE:

	Create a HX file for each LDtk project JSON. The filename isn’t important, pick whatever you like.
	This HX will host all the the typed data extracted from the project file:

	```
	private typedef _Tmp =
		haxe.macro.MacroType<[ ldtk.Project.build("path/to/myProject.ldtk") ]>;
	```

	See full documentation here: https://ldtk.io/docs
**/


#if macro


/* MACRO TYPE BUILDER *****************************************************/

import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;

class Project {

	/** Build project types based on Project JSON **/
	public static function build(projectFilePath:String) {
		#if !macro
			error("Should only be used in macros");
		#else

			return ldtk.macro.TypeBuilder.buildTypes(projectFilePath);
		#end
	}
}


#else


/* ACTUAL PROJECT CLASS *****************************************************/

import ldtk.Json;

class Project {
	/** Contains the full path to the project JSON, as provided to the macro (using slashes) **/
	public var projectFilePath : String;

	/** Contains the directory of the project JSON (using slashes, no trailing slash) **/
	public var projectDir : Null<String>;

	/** Project background color (as Int 0xrrggbb) **/
	public var bgColor_int: UInt;

	/** Project background color (as Hex "#rrggbb") **/
	public var bgColor_hex: String;

	var _untypedWorlds : Array<ldtk.World>;

	/** Full access to the JSON project definitions **/
	public var defs : ldtk.Json.DefinitionsJson;

	/** A map containing all untyped Tilesets, indexed using their JSON  `uid` (integer unique ID). The typed tilesets will be added in a field called `all_tilesets` by macros. **/
	@:allow(ldtk.Layer_Tiles, ldtk.Layer_AutoLayer, ldtk.Layer_IntGrid_AutoLayer, ldtk.Entity)
	var _untypedTilesets : Map<Int, ldtk.Tileset>;

	/** Internal asset cache to avoid reloading of previously loaded data. **/
	var assetCache : Map<String, haxe.io.Bytes>; // TODO support hot reloading

	var _untypedToc : Map<String, Array<ldtk.Json.EntityReferenceInfos>>;

	function new() {}

	/**
		Replace current project using another project-JSON data.

		WARNING: types and classes are generated at compilation-time, not at runtime.
	**/
	public function parseJson(jsonString:String) {
		// Init
		_untypedTilesets = new Map();
		_untypedToc = new Map();
		assetCache = new Map();

		// Parse json
		var untypedJson : Dynamic = haxe.Json.parse(jsonString);
		var json : ProjectJson = untypedJson;

		// Init misc fields
		defs = json.defs;
		bgColor_hex = json.bgColor;
		bgColor_int = ldtk.Project.hexToInt(json.bgColor);

		// Add dummy JSON world
		if( json.worlds==null || json.worlds.length==0 )
			json.worlds = [ World.createDummyJson(json) ];

		// Populate worlds
		_untypedWorlds = [];
		var idx = 0;
		for(json in json.worlds)
			_untypedWorlds.push( _instanciateWorld(this, idx++, json) );


		// Populate tilesets
		Reflect.setField(this, "all_tilesets", {});
		for(tsJson in json.defs.tilesets) {
			_untypedTilesets.set( tsJson.uid, _instanciateTileset(this, tsJson) );
			Reflect.setField( Reflect.field(this,"all_tilesets"), tsJson.identifier, _instanciateTileset(this, tsJson));
		}

		// Empty toc
		var classToc : Dynamic = Reflect.field(this,"toc");
		for( k in Reflect.fields(classToc) )
			Reflect.setField(classToc, k, []);

		// Populate toc
		if( json.toc!=null ) {
			var jsonToc : Array<ldtk.Json.TableOfContentEntry> = json.toc;
			for(te in jsonToc)
				if( Reflect.hasField(classToc, te.identifier) )
					Reflect.setField(classToc, te.identifier, te.instances.copy());
		}
	}

	/** Transform an identifier string by capitalizing its first letter **/
	@:noCompletion
	public function capitalize(id:String) {
		if( id==null )
			id = "";

		var reg = ~/^(_*)([a-z])([a-zA-Z0-9_]*)/g; // extract first letter, if it's lowercase
		if( reg.match(id) )
			id = reg.matched(1) + reg.matched(2).toUpperCase() + reg.matched(3);

		return id;
	}


	var _enumTypePrefix : String;

	function _resolveExternalEnumValue<T>(name:String, enumValueId:String) : T {
		return null;
	}


	/** Used to populated field instances with actual values **/
	@:allow(ldtk.Entity, ldtk.Level)
	function _assignFieldInstanceValues(target:Dynamic, fieldInstances:Array<FieldInstanceJson>) {
		var arrayReg = ~/Array<(.*)>/gi;
		for(f in fieldInstances) {
			if( f.__value==null )
				continue;

			var isArray = arrayReg.match(f.__type);
			var typeName = isArray ? arrayReg.matched(1) : f.__type;

			switch typeName {
				case "Int", "Float", "Bool", "String" :
					Reflect.setField(target, "f_"+f.__identifier, f.__value);

				case "FilePath" :
					Reflect.setField(target, "f_"+f.__identifier, f.__value);

				case "Color":
					Reflect.setField(target, "f_"+f.__identifier+"_hex", f.__value);
					if( !isArray )
						Reflect.setField(target, "f_"+f.__identifier+"_int", ldtk.Project.hexToInt(f.__value));
					else {
						var arr : Array<String> = f.__value;
						Reflect.setField(target, "f_"+f.__identifier+"_int", arr.map( (c)->ldtk.Project.hexToInt(c) ) );
					}

				case "Point":
					if( !isArray )
						Reflect.setField(target, "f_"+f.__identifier, new ldtk.Point(f.__value.cx, f.__value.cy));
					else {
						var arr : Array<{ cx:Int, cy:Int }> = f.__value;
						Reflect.setField(target, "f_"+f.__identifier, arr.map( (pt)->new ldtk.Point(pt.cx, pt.cy) ) );
					}

				case "EntityRef":
					Reflect.setField(target, "f_"+f.__identifier, f.__value);

				case _.indexOf("LocalEnum.") => 0:
					var type = _enumTypePrefix + typeName.substr( typeName.indexOf(".")+1 );
					var e = Type.resolveEnum( type );
					if( !isArray )
						Reflect.setField(target, "f_"+f.__identifier, Type.createEnum(e, capitalize(f.__value)) );
					else {
						var arr : Array<String> = f.__value;
						Reflect.setField(target, "f_"+f.__identifier, arr.map( (k)->Type.createEnum(e,capitalize(k)) ) );
					}


				case _.indexOf("ExternEnum.") => 0:
					var type = typeName.substr( typeName.indexOf(".")+1 );
					if( !isArray )
						Reflect.setField(target, "f_"+f.__identifier, _resolveExternalEnumValue(type, f.__value) );
					else {
						var arr : Array<String> = f.__value;
						Reflect.setField(target, "f_"+f.__identifier, arr.map( (k)->_resolveExternalEnumValue(type, k) ) );
					}

				case "Tile":
					function _checkTile(tileRect : TilesetRect) {
						if( tileRect==null || !dn.M.isValidNumber(tileRect.x) )
							return null; // old format
						else
							return tileRect;
					}
					#if heaps
					function _heapsTileGetter(tileRect:TilesetRect) {
						if( tileRect==null || !dn.M.isValidNumber(tileRect.x) || !_untypedTilesets.exists(tileRect.tilesetUid))
							return null;

						var tileset = _untypedTilesets.get(tileRect.tilesetUid);
						var tile = tileset.getFreeTile( tileRect.x, tileRect.y, tileRect.w, tileRect.h );
						return tile;
					}
					#end

					if( isArray ) {
						var arr : Array<TilesetRect> = f.__value;
						Reflect.setField(target, "f_"+f.__identifier+"_infos", arr.map( tr->_checkTile(tr) ) );
						#if heaps
						Reflect.setField(target, "f_"+f.__identifier+"_getTile", arr.map( tr->_heapsTileGetter.bind(tr) ) );
						#end

					}
					else {
						Reflect.setField(target, "f_"+f.__identifier+"_infos", _checkTile(f.__value));
						#if heaps
						Reflect.setField(target, "f_"+f.__identifier+"_getTile", _heapsTileGetter.bind(f.__value));
						#end
					}

				case _ :
					Project.error('Unknown field type $typeName at runtime'); // TODO add some helpful context here
			}
		}
	}


	@:keep public function toString() {
		return 'ldtk.Project[${_untypedWorlds.length} worlds]';
	}


	/**
		Get an asset from current Asset management system. The path should be **relative to the project JSON file**.
	**/
	public function getAsset(projectRelativePath:String) : haxe.io.Bytes {
		if( assetCache.exists(projectRelativePath) )
			return assetCache.get(projectRelativePath);
		else {
			var bytes = loadAssetBytes(projectRelativePath);
			assetCache.set(projectRelativePath, bytes);
			return bytes;
		}
	}


	/**
		Try to resolve the Project file location in the current Asset management system
	**/
	function makeAssetRelativePath(projectRelativePath:String) {
		// Get project file name
		var p = StringTools.replace(projectFilePath, "\\", "/");
		var projectFileName = p.lastIndexOf("/")<0 ? p : p.substr( p.lastIndexOf("/")+1 );

		#if heaps

			// Browser all folders in Heaps res/ folder recursively to locate Project file
			var pendingDirs = [
				hxd.Res.loader.fs.getRoot()
			];
			while( pendingDirs.length>0 ) {
				var curDir = pendingDirs.shift();
				for(f in curDir) {
					if( f.isDirectory ) {
						// Found another dir
						pendingDirs.push(f);
					}
					else if( f.name==projectFileName ) {
						// Found it
						return dn.FilePath.cleanUp( ( f.directory.length==0 ? "" : f.directory+"/" ) + projectRelativePath, true );
					}
				}
			}
			error('Project file is not in Heaps res/ folder!');
			return "";

		#elseif openfl

			// Browse openFL assets to locate project file
			for( e in openfl.Assets.list() )
				if( e.indexOf(projectFileName)>=0 ) {
					// Found it
					var baseDir = e.indexOf("/")<0 ? "" : e.substr( 0, e.lastIndexOf("/") );
					return dn.FilePath.cleanUp( baseDir + "/" + projectRelativePath, true );
				}

			error('Project file is not in OpenFL assets!');
			return "";

		#else

			// Generic Haxe Resource Loading for Unsupported Frameworks
			// Browse resources to locate project file
			for(key => value in haxe.Resource.listNames()) {
				if(value == projectFilePath) {
					// Found it
					var baseDir = value.indexOf("/")<0 ? "" : value.substr( 0, value.lastIndexOf("/") );
					return dn.FilePath.cleanUp( baseDir + "/" + projectRelativePath, true );
				}
			}

			error('Project file is not loaded properly.\nPlease add "-r <path to project name.ldtk>" and "-r <path to each level file.ldtkl>" to your project.hxml build file and try again.');
			return "";

		#end
	}


	/**
		Load an Asset as haxe.io.Bytes
	**/
	function loadAssetBytes(projectRelativePath:String) : haxe.io.Bytes {
		#if heaps

			var resPath = makeAssetRelativePath(projectRelativePath);
			if( !hxd.Res.loader.exists(resPath) )
				error('Asset not found in Heaps res/ folder: $resPath');

			var res = hxd.Res.load(resPath);
			return res.entry.getBytes();

		#elseif openfl

			var assetId = makeAssetRelativePath(projectRelativePath);
			var bytes : haxe.io.Bytes = try openfl.Assets.getBytes(assetId) catch(e:Dynamic) {
				error('OpenFL asset not found or could not be accessed synchronously: $assetId ; error=$e');
				null;
			}
			return bytes;


		#else

			// Generic Haxe Resource Loading for Unsupported Frameworks
			var assetId = makeAssetRelativePath(projectRelativePath);
			var bytes : haxe.io.Bytes = try haxe.Resource.getBytes(assetId) catch(e:Dynamic) {
				error('Asset not found or was not loaded properly at runtime: $assetId ; error=$e');
				null;
			}
			return bytes;

		#end
	}


	#if flixel
	/**
		Get an asset image as FlxGraphic
	**/
	public function getFlxGraphicAsset(projectRelativePath:String) : flixel.graphics.FlxGraphic {
		var assetId = makeAssetRelativePath(projectRelativePath);
		var g = try flixel.graphics.FlxGraphic.fromAssetKey(assetId)
			catch(e:Dynamic) {
				error('FlxGraphic not found in assets: $assetId ; error=$e');
				null;
			}
		return g;
	}
	#end


	/**
		Crash with an error message
	**/
	public static function error(str:String) {
		throw '[ldtk-api] $str';
	}


	function _instanciateWorld(project:ldtk.Project, arrayIndex:Int, json:ldtk.Json.WorldJson) {
		return null; // overriden by Macros.hx
	}


	function _instanciateTileset(project:ldtk.Project, json:ldtk.Json.TilesetDefJson) {
		return null;
	}


	function searchDef<T:{uid:Int, identifier:String}>(arr:Array<T>, ?uid:Int, ?identifier:String) {
		if( uid==null && identifier==null )
			return null;

		for(e in arr)
			if( uid!=null && e.uid==uid || identifier!=null && e.identifier==identifier )
				return e;

		return null;
	}

	/**
		Get a Layer definition using either its uid (Int) or identifier (String)
	**/
	public function getLayerDefJson(?uid:Int, ?identifier:String) : Null<ldtk.Json.LayerDefJson> {
		return searchDef( defs.layers, uid, identifier );
	}
	@:noCompletion @:deprecated("Method was renamed to: getLayerDefJson")
	public function getLayerDef(?uid,?identifier) return getLayerDefJson(uid,identifier);

	/**
		Get an Entity definition using either its uid (Int) or identifier (String)
	**/
	public inline function getEntityDefJson(?uid:Int, ?identifier:String) : Null<ldtk.Json.EntityDefJson> {
		return searchDef( defs.entities, uid, identifier );
	}
	@:noCompletion @:deprecated("Method was renamed to: getEntityDefJson")
	public function getEntityDef(?uid,?identifier) return getEntityDefJson(uid,identifier);



	/**
		Get a Tileset definition using either its uid (Int) or identifier (String)
	**/
	public inline function getTilesetDefJson(?uid:Int, ?identifier:String) : Null<ldtk.Json.TilesetDefJson> {
		return searchDef( defs.tilesets, uid, identifier );
	}
	@:noCompletion @:deprecated("Method was renamed to: getTilesetDefJson")
	public function getTilesetDef(?uid,?identifier) return getTilesetDefJson(uid,identifier);


	/**
		Get an Enum definition using either its uid (Int) or identifier (String)
	**/
	public inline function getEnumDefJson(?uid:Int, ?identifier:String) : Null<ldtk.Json.EnumDefJson> {
		var e = searchDef( defs.enums, uid, identifier );
		if( e!=null )
			return e;
		else
			return searchDef( defs.externalEnums, uid, identifier );
	}
	@:noCompletion @:deprecated("Method was renamed to: getEnumDefJson")
	public function getEnumDef(?uid,?identifier) return getEnumDefJson(uid,identifier);


	/**
		Get an Enum definition using an Enum value
	**/
	public function getEnumDefFromValue(v:EnumValue) : Null<ldtk.Json.EnumDefJson> {
		try {
			var name = Type.getEnum(v).getName();
			var defId = name.substr( name.indexOf("_")+1 ); // get rid of the Macro prefix
			defId = defId.substr( defId.lastIndexOf(".")+1 );
			return getEnumDefJson(defId);
		}
		catch(err:Dynamic) {
			return null;
		}
	}

	function getEnumTileInfosFromValue(v:EnumValue) : Null<{ x:Int, y:Int, w:Int, h:Int, tilesetUid:Int }> {
		var ed = getEnumDefFromValue(v);
		if( ed==null )
			return null;

		for(ev in ed.values)
			if( ev.id==v.getName() && ev.__tileSrcRect!=null )
				return {
					tilesetUid: ed.iconTilesetUid,
					x: ev.__tileSrcRect[0],
					y: ev.__tileSrcRect[1],
					w: ev.__tileSrcRect[2],
					h: ev.__tileSrcRect[3],
				};

		return null;
	}

	#if heaps

	public function getEnumTile(enumValue:EnumValue) : Null<h2d.Tile> {
		var tileInfos = getEnumTileInfosFromValue(enumValue);
		if( tileInfos==null )
			return null;

		var tileset = _untypedTilesets.get(tileInfos.tilesetUid);
		if( tileset==null )
			return null;

		return tileset.getFreeTile(tileInfos.x, tileInfos.y, tileInfos.w, tileInfos.h);
	}
	#end

	public function getEnumColor(enumValue:EnumValue) : UInt {
		var ed = getEnumDefFromValue(enumValue);
		for(v in ed.values)
			if( v.id==enumValue.getName() )
				return v.color;
		return 0xff00ff;
	}

	@:noCompletion
	public static inline function hexToInt(hex:String) : Int {
		return hex==null ? 0x0 : Std.parseInt( "0x"+hex.substr(1) );
	}

	@:noCompletion
	public static inline function intToHex(c:Int, ?leadingZeros=6) : String {
		var h = StringTools.hex(c);
		while( h.length<leadingZeros )
			h="0"+h;
		return "#"+h;
	}
}

#end // End of "if !macro"
