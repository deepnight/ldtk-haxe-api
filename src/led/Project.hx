package led;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
#end

import led.ApiTypes;

class Project {
	public var name : String;
	var _levels : Array<led.Level>;

	public function new() {
	}

	public function parse(projectFileContent:String) {
		var json : ProjectJson = haxe.Json.parse(projectFileContent);
		name = json.name;

		_levels = [];
		for(json in json.levels)
			_levels.push( new Level(json) );
	}

	public static function build(projectFilePath:String) {
		#if !macro
		throw "Should only be used in macros";
		#else
		return Macros.buildTypes(projectFilePath);
		#end
	}
}
