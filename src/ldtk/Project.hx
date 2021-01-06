package ldtk;

/**
	A LDtk Project can be imported by creating a single HX containing:

	private typedef _Tmp = haxe.macro.MacroType<[
		ldtk.Project.build("path/to/myLedProject.ldtk")
	]>;

	See documentation here: https://deepnight.net/tools/ldtk-2d-level-editor/
**/

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
#end

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

	public var worldLayout : WorldLayout;

	public function new() {}

	/**
		Replace current project using another project-JSON data.

		WARNING: types and classes are generated at compilation-time, not at runtime.
	**/
	public function parseJson(jsonString:String) {
		#if !macro
		var json : Dynamic = haxe.Json.parse(jsonString);
		bgColor_hex = json.bgColor;
		bgColor_int = ldtk.Project.hexToInt(json.bgColor);

		_untypedLevels = [];
		for(json in (cast json.levels : Array<Dynamic>))
			_untypedLevels.push( _instanciateLevel(this, json) );

		worldLayout = WorldLayout.createByName( Std.string(json.worldLayout) );

		defs = json.defs;
		#end
	}


	public dynamic function loadAsset(relativeFilePath:String) : haxe.io.Bytes {
		#if macro
			return null;
		#elseif heaps
			// Get project file name
			var p = StringTools.replace(projectFilePath, "\\", "/");
			var projectFileName = p.lastIndexOf("/")<0 ? p : p.substr( p.lastIndexOf("/")+1 );
			trace(projectFileName);

			// Explore all folders in Heaps res/ folder recursively, to locate Project file
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
						// Found project file!
						trace("found in "+f.directory);
						var resPath = ( f.directory.length==0 ? "" : f.directory+"/" ) + relativeFilePath;
						if( !hxd.Res.loader.exists(resPath) )
							throw 'Could not find file $relativeFilePath in Heaps res/ folder!';

						var res = hxd.Res.load(resPath);
						return res.entry.getBytes();
					}
				}
			}
			throw "Could not locate the project file in Heaps res/ folder!";
		#else
			throw "Asset loading is not supported on this Haxe target or framework. You should rebind the project.loadAsset() method to use your framework asset loading system.";
			return null;
		#end
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

	public inline function getLayerDef(?uid:Int, ?identifier:String) : Null<ldtk.Json.LayerDefJson> {
		return searchDef( defs.layers, uid, identifier );
	}

	public inline function getEntityDef(?uid:Int, ?identifier:String) : Null<ldtk.Json.EntityDefJson> {
		return searchDef( defs.entities, uid, identifier );
	}

	public inline function getTilesetDef(?uid:Int, ?identifier:String) : Null<ldtk.Json.TilesetDefJson> {
		return searchDef( defs.tilesets, uid, identifier );
	}

	public inline function getEnumDef(?uid:Int, ?identifier:String) : Null<ldtk.Json.EnumDefJson> {
		var e = searchDef( defs.enums, uid, identifier );
		if( e!=null )
			return e;
		else
			return searchDef( defs.externalEnums, uid, identifier );
	}

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

	public function getEnumTileInfosFromValue(v:EnumValue) : Null<{ x:Int, y:Int, w:Int, h:Int, tileset:ldtk.Json.TilesetDefJson }> {
		var ed = getEnumDefFromValue(v);
		if( ed==null )
			return null;

		for(ev in ed.values)
			if( ev.id==v.getName() && ev.__tileSrcRect!=null )
				return {
					tileset: getTilesetDef(ed.iconTilesetUid),
					x: ev.__tileSrcRect[0],
					y: ev.__tileSrcRect[1],
					w: ev.__tileSrcRect[2],
					h: ev.__tileSrcRect[3],
				};

		return null;
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


	public static function build(projectFilePath:String) {
		#if !macro
		throw "Should only be used in macros";
		#else
		return ldtk.macro.TypeBuilder.buildTypes(projectFilePath);
		#end
	}
}
