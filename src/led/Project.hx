package led;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
#end

class Project {
	public var name : String;
	var _untypedLevels : Array<led.Level>;

	public function new() {
	}

	/**
		Replace current project using another project JSON structure. WARNING: types and classes are generated at compilation-time, not at runtime.
	**/
	public function fromJson(json:led.JsonTypes.ProjectJson) {
		name = json.name;

		_untypedLevels = [];
		for(json in json.levels)
			_untypedLevels.push( _instanciateLevel(json) );
	}

	function _instanciateLevel(json:led.JsonTypes.LevelJson) {
		return null; // overriden by Macros.hx
	}

	public static function build(projectFilePath:String) {
		#if !macro
		throw "Should only be used in macros";
		#else
		return Macros.buildTypes(projectFilePath);
		#end
	}
}
