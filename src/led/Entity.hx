package led;

class Entity {
	var _enumTypePrefix : String;
	public var identifier : String;

	/**
		Grid-based X coordinate
	**/
	public var cx : Int;

	/**
		Grid-based Y coordinate
	**/
	public var cy : Int;

	/**
		Pixel-based X coordinate
	**/
	public var pixelX : Int;

	/**
		Pixel-based Y coordinate
	**/
	public var pixelY : Int;
	
	var _fields : Map<String, Dynamic> = new Map();

	public function new(json:led.JsonTypes.EntityInstJson) {
		identifier = json.__identifier;
		cx = json.__cx;
		cy = json.__cy;
		pixelX = json.x;
		pixelY = json.y;

		// Assign values to fields created in Macros
		for(f in json.fieldInstances) {
			if( f.__value==null )
				continue;

			switch f.__type {
				case "Int", "Float", "Bool", "String" :
					Reflect.setField(this, "f_"+f.__identifier, f.__value);

				case "Color":
					Reflect.setField(this, "f_"+f.__identifier+"_hex", f.__value);
					Reflect.setField(this, "f_"+f.__identifier+"_int", dn.Color.hexToInt(f.__value));

				case _.indexOf("LocalEnum.") => 0:
					var type = _enumTypePrefix + f.__type.substr( f.__type.indexOf(".")+1 );
					var e = Type.resolveEnum( type );
					Reflect.setField(this, "f_"+f.__identifier, Type.createEnum(e, f.__value) );


				case _.indexOf("ExternEnum.") => 0:
					var type = f.__type.substr( f.__type.indexOf(".")+1 );
					var e = _resolveExternalEnum(type);
					if( e==null )
						throw "Couldn't create an instance of enum "+type+"! Please check if the PROJECT enum still matches the EXTERNAL FILE declaring it.";
					Reflect.setField(this, "f_"+f.__identifier, Type.createEnum(e, f.__value) );

				case _ :
					throw "Unknown field type "+f.__type+" for "+identifier+"."+f.__identifier;
			}
		}
	}

	function _resolveExternalEnum<T>(name:String) : Enum<T> {
		return null;
	}
}
