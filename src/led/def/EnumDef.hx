package led.def;

class EnumDef {
	public var uid(default,null) : Int;
	public var name(default,set) : String;
	public var values : Array<String> = [];

	public function new(uid:Int, name:String) {
		this.uid = uid;
		this.name = name;
	}

	function set_name(v:String) {
		name = cleanUpString(v);
		return name;
	}

	@:keep public function toString() {
		return '$name(' + values.join(",")+")";
	}

	public static function fromJson(dataVersion:Int, json:Dynamic) {
		var ed = new EnumDef(JsonTools.readInt(json.uid), json.name);

		for(v in JsonTools.readArray(json.values))
			ed.values.push(v);

		return ed;
	}

	public function toJson() {
		return {
			uid: uid,
			name: name,
			values: values,
		};
	}

	public static inline function cleanUpString(str:String) {
		return StringTools.trim(str);
	}

	function hasValue(v:String) {
		v = cleanUpString(v);
		for(ev in values)
			if( ev==v )
				return true;
		return false;
	}

	public function addValue(v:String) {
		if( hasValue(v) )
			return false;

		v = cleanUpString(v);
		values.push(v);
		return true;
	}


	public function tidy(p:Project) {
	}
}
