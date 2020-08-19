package led;

class Entity {
	public var identifier : String;
	public var cx : Int;
	public var cy : Int;
	public var pixelX : Int;
	public var pixelY : Int;
	var _fields : Map<String, Dynamic> = new Map();

	public function new(json:led.JsonTypes.EntityInstJson) {
		identifier = json.__identifier;
		cx = json.__cx;
		cy = json.__cy;
		pixelX = json.x;
		pixelY = json.y;

		for(f in json.fieldInstances) {
			Reflect.setField(this, "f_"+f.__identifier,
				f.__value==null
					? null
					: switch f.__type {
						case "Int", "Float", "Bool", "String" : f.__value;
						case _ :
							null; // HACK
							// trace("Unknown field type "+f.__type+" for "+identifier+"."+f.__identifier); null;
					}
			);
		}
	}
}
