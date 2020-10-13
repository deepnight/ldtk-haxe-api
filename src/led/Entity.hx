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

	public function new(json:led.Json.EntityInstanceJson) {
		identifier = json.__identifier;
		cx = json.__grid[0];
		cy = json.__grid[1];
		pixelX = json.px[0];
		pixelY = json.px[1];

		// Assign values to fields created in Macros
		var arrayReg = ~/Array<(.*)>/gi;
		for(f in json.fieldInstances) {
			if( f.__value==null )
				continue;

			var isArray = arrayReg.match(f.__type);
			var typeName = isArray ? arrayReg.matched(1) : f.__type;

			switch typeName {
				case "Int", "Float", "Bool", "String" :
					Reflect.setField(this, "f_"+f.__identifier, f.__value);

				case "Color":
					Reflect.setField(this, "f_"+f.__identifier+"_hex", f.__value);
					if( !isArray )
						Reflect.setField(this, "f_"+f.__identifier+"_int", led.Project.hexToInt(f.__value));
					else {
						var arr : Array<String> = f.__value;
						Reflect.setField(this, "f_"+f.__identifier+"_int", arr.map( (c)->led.Project.hexToInt(c) ) );
					}

				case "Point":
					if( !isArray )
						Reflect.setField(this, "f_"+f.__identifier, new led.Point(f.__value.cx, f.__value.cy));
					else {
						var arr : Array<{ cx:Int, cy:Int }> = f.__value;
						Reflect.setField(this, "f_"+f.__identifier, arr.map( (pt)->new led.Point(pt.cx, pt.cy) ) );
					}

				case _.indexOf("LocalEnum.") => 0:
					var type = _enumTypePrefix + typeName.substr( typeName.indexOf(".")+1 );
					var e = Type.resolveEnum( type );
					if( !isArray )
						Reflect.setField(this, "f_"+f.__identifier, Type.createEnum(e, f.__value) );
					else {
						var arr : Array<String> = f.__value;
						Reflect.setField(this, "f_"+f.__identifier, arr.map( (k)->Type.createEnum(e,k) ) );
					}


				case _.indexOf("ExternEnum.") => 0:
					var type = typeName.substr( typeName.indexOf(".")+1 );
					var e = _resolveExternalEnum(type);
					if( e==null )
						throw "Couldn't create an instance of enum "+type+"! Please check if the PROJECT enum still matches the EXTERNAL FILE declaring it.";
					if( !isArray )
						Reflect.setField(this, "f_"+f.__identifier, Type.createEnum(e, f.__value) );
					else {
						var arr : Array<String> = f.__value;
						Reflect.setField(this, "f_"+f.__identifier, arr.map( (k)->Type.createEnum(e,k) ) );
					}

				case _ :
					throw "Unknown field type "+typeName+" for "+identifier+"."+f.__identifier;
			}
		}
	}

	function _resolveExternalEnum<T>(name:String) : Enum<T> {
		return null;
	}
}
