package led;

/**
	A LEd Project can be imported by creating a single file containing:

	private typedef _Tmp = haxe.macro.MacroType<[
		led.Project.build("path/to/myLedProject.json")
	]>;

	See documentation here: https://deepnight.net/tools/led-2d-level-editor/
**/

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
#end

class Project {
	/** Contains the full path to the project JSON, as provided to the macro (using slashes) **/
	public var projectFilePath : String;

	/** Contains the directory of the project JSON (using slashes, no trailing slash) **/
	public var projectDir : Null<String>;

	/** Project background color (as Int 0xrrggbb) **/
	public var bgColor_int: UInt;

	/** Project background color (as Hex "#rrggbb") **/
	public var bgColor_hex: String;

	var _untypedLevels : Array<led.Level>;

	/** Full access to the JSON project definitions **/
	public var defs : led.Json.DefinitionsJson;

	public function new() {}

	/**
		Replace current project using another project-JSON data.

		WARNING: types and classes are generated at compilation-time, not at runtime.
	**/
	public function parseJson(jsonString:String) {
		#if !macro
		var json : led.Json.ProjectJson = haxe.Json.parse(jsonString);
		bgColor_hex = json.bgColor;
		bgColor_int = led.Project.hexToInt(json.bgColor);

		_untypedLevels = [];
		for(json in json.levels)
			_untypedLevels.push( _instanciateLevel(json) );

		defs = json.defs;
		#end
	}

	function _instanciateLevel(json:led.Json.LevelJson) {
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

	public inline function getLayerDef(?uid:Int, ?identifier:String) : Null<led.Json.LayerDefJson> {
		return searchDef( defs.layers, uid, identifier );
	}

	public inline function getEntityDef(?uid:Int, ?identifier:String) : Null<led.Json.EntityDefJson> {
		return searchDef( defs.entities, uid, identifier );
	}

	public inline function getTilesetDef(?uid:Int, ?identifier:String) : Null<led.Json.TilesetDefJson> {
		return searchDef( defs.tilesets, uid, identifier );
	}

	public inline function getEnumDef(?uid:Int, ?identifier:String) : Null<led.Json.EnumDefJson> {
		var e = searchDef( defs.enums, uid, identifier );
		if( e!=null )
			return e;
		else
			return searchDef( defs.externalEnums, uid, identifier );
	}


	@:noCompletion
	public static inline function hexToInt(hex:String) {
		return Std.parseInt( "0x"+hex.substr(1,999) );
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
		return Macros.buildTypes(projectFilePath);
		#end
	}
}
