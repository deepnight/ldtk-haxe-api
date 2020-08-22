package led;

class Layer_IntGrid extends led.Layer {
	var valueInfos : Array<{ identifier:Null<String>, color:UInt }> = [];

	/**
		IntGrid integer values
	**/
	public var intGrid : Map<Int,Int> = new Map();

	public function new(json) {
		super(json);

		for(ig in json.intGrid)
			intGrid.set(ig.coordId, ig.v);
	}

	/**
		Get the Integer value at selected coordinates (return -1 if none).
	**/
	public inline function getInt(cx:Int, cy:Int) {
		return !isCoordValid(cx,cy) || !intGrid.exists( getCoordId(cx,cy) ) ? -1 : intGrid.get( getCoordId(cx,cy) );
	}

	/**
		Return TRUE if there is any value at selected coordinates.

		Optional parameter "val" allows to check for a specific integer value.
	**/
	public inline function has(cx:Int, cy:Int, ?val:Int) {
		return val==null && getInt(cx,cy)!=-1 || val!=null && getInt(cx,cy)==val;
	}

	/**
		Get the value String identifier at selected coordinates (return null if none).
	**/
	public inline function getName(cx:Int, cy:Int) : Null<String> {
		return !has(cx,cy) ? null : valueInfos[ getInt(cx,cy) ].identifier;
	}

	/**
		Get the value UInt color code (0xRRGGBB format) at selected coordinates (return null if none).
	**/
	public inline function getColor(cx:Int, cy:Int) : Null<UInt> {
		return !has(cx,cy) ? null : valueInfos[ getInt(cx,cy) ].color;
	}
}
