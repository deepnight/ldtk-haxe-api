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

	var _untypedLevels : Array<ldtk.Level>;

	/** Full access to the JSON project definitions **/
	public var defs : ldtk.Json.DefinitionsJson;

	/** World layout enum **/
	public var worldLayout : WorldLayout;

	/** A map containing all Tilesets, indexed using their JSON  `uid` (integer unique ID) **/
	public var tilesets : Map<Int, ldtk.Tileset>;

	/** Internal asset cache to avoid reloading of previously loaded data. **/
	var assetCache : Map<String, haxe.io.Bytes>; // TODO support hot reloading


	function new() {}

	/**
		Replace current project using another project-JSON data.

		WARNING: types and classes are generated at compilation-time, not at runtime.
	**/
	public function parseJson(jsonString:String) {
		// Init
		tilesets = new Map();
		assetCache = new Map();

		// Parse json
		var json : Dynamic = haxe.Json.parse(jsonString);
		bgColor_hex = json.bgColor;
		bgColor_int = ldtk.Project.hexToInt(json.bgColor);

		// Populate levels
		_untypedLevels = [];
		for(json in (cast json.levels : Array<Dynamic>))
			_untypedLevels.push( _instanciateLevel(this, json) );

		// Populate tilesets
		for(tsJson in (cast json.defs.tilesets : Array<Dynamic>))
			tilesets.set( tsJson.uid, new ldtk.Tileset(this, tsJson) );

		// Init misc fields
		worldLayout = WorldLayout.createByName( Std.string(json.worldLayout) );
		defs = json.defs;
	}


	@:keep public function toString() {
		return 'ldtk.Project[${_untypedLevels.length} levels]';
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
						return ( f.directory.length==0 ? "" : f.directory+"/" ) + projectRelativePath;
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
					return baseDir + "/" + projectRelativePath;
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
					return baseDir + "/" + projectRelativePath;
				}
			}

			error('Project file is not loaded properly.\nPlease add "-r <path to project name.ldtk>" and "-r <path to each level file.ldtkl>" to your project.hxml build file and try again.');
			return "";

			/** Original error message here for unsupported frameworks
			 *  error("Project asset loading is not supported on this Haxe target or framework.");
			 * return "";
			 */

		#end
	}


	/**
		Load an Asset as haxe.io.Bytes
	**/
	function loadAssetBytes(projectRelativePath:String) : haxe.io.Bytes {
		#if heaps

			var resPath = makeAssetRelativePath(projectRelativePath);
			if( !hxd.Res.loader.exists(resPath) )
				error('Asset not found in Heaps res/ folder: $projectRelativePath');

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
			
			/** Original error message here for unsupported frameworks
			 * // TODO support asset loading on "sys" platform
			 * error("Project asset loading is not supported on this Haxe target or framework.");
			 * return null;
			 */

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


	function _instanciateLevel(project:ldtk.Project, json:ldtk.Json.LevelJson) {
		return null; // overriden by Macros.hx
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
	public inline function getLayerDef(?uid:Int, ?identifier:String) : Null<ldtk.Json.LayerDefJson> {
		return searchDef( defs.layers, uid, identifier );
	}

	/**
		Get an Entity definition using either its uid (Int) or identifier (String)
	**/
	public inline function getEntityDef(?uid:Int, ?identifier:String) : Null<ldtk.Json.EntityDefJson> {
		return searchDef( defs.entities, uid, identifier );
	}

	/**
		Get a Tileset definition using either its uid (Int) or identifier (String)
	**/
	public inline function getTilesetDef(?uid:Int, ?identifier:String) : Null<ldtk.Json.TilesetDefJson> {
		return searchDef( defs.tilesets, uid, identifier );
	}

	/**
		Get an Enum definition using either its uid (Int) or identifier (String)
	**/
	public inline function getEnumDef(?uid:Int, ?identifier:String) : Null<ldtk.Json.EnumDefJson> {
		var e = searchDef( defs.enums, uid, identifier );
		if( e!=null )
			return e;
		else
			return searchDef( defs.externalEnums, uid, identifier );
	}

	/**
		Get an Enum definition using an Enum value
	**/
	public function getEnumDefFromValue(v:EnumValue) : Null<ldtk.Json.EnumDefJson> {
		try {
			var name = Type.getEnum(v).getName();
			var defId = name.substr( name.indexOf("_")+1 ); // get rid of the Macro prefix
			defId = defId.substr( defId.lastIndexOf(".")+1 );
			return getEnumDef(defId);
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

		var tileset = tilesets.get(tileInfos.tilesetUid);
		if( tileset==null )
			return null;

		return tileset.getFreeTile(tileInfos.x, tileInfos.y, tileInfos.w, tileInfos.h);
	}
	#end


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
