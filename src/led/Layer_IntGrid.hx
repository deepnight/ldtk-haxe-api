package led;

class Layer_IntGrid extends led.Layer {
	var valueInfos : Array<{ identifier:Null<String>, color:UInt }> = [];

	/**
		IntGrid integer values, map is based on coordIds
	**/
	public var intGrid : Map<Int,Int> = new Map();


	public function new(json) {
		super(json);

		for(ig in json.intGrid)
			intGrid.set(ig.coordId, ig.v);
	}

	/**
		Get the Integer value at selected coordinates

		Return -1 if none.
	**/
	public inline function getInt(cx:Int, cy:Int) {
		return !isCoordValid(cx,cy) || !intGrid.exists( getCoordId(cx,cy) ) ? -1 : intGrid.get( getCoordId(cx,cy) );
	}

	/**
		Return TRUE if there is any value at selected coordinates.

		Optional parameter "val" allows to check for a specific integer value.
	**/
	public inline function hasValue(cx:Int, cy:Int, ?val:Int) {
		return val==null && getInt(cx,cy)!=-1 || val!=null && getInt(cx,cy)==val;
	}

	/**
		Get the value String identifier at selected coordinates.

		Return null if none.
	**/
	public inline function getName(cx:Int, cy:Int) : Null<String> {
		return !hasValue(cx,cy) ? null : valueInfos[ getInt(cx,cy) ].identifier;
	}

	/**
		Get the value color (0xrrggbb Unsigned-Int format) at selected coordinates.

		Return null if none.
	**/
	public inline function getColorInt(cx:Int, cy:Int) : Null<UInt> {
		return !hasValue(cx,cy) ? null : valueInfos[ getInt(cx,cy) ].color;
	}

	/**
		Get the value color ("#rrggbb" string format) at selected coordinates.

		Return null if none.
	**/
	public inline function getColorHex(cx:Int, cy:Int) : Null<String> {
		return !hasValue(cx,cy) ? null : led.Project.intToHex( valueInfos[ getInt(cx,cy) ].color );
	}
}
