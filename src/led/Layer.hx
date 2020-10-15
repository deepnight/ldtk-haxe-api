package led;

enum LayerType {
	IntGrid;
	Tiles;
	Entities;
	AutoLayer;
	Unknown;
}

class Layer {
	public var identifier : String;
	public var type : LayerType;

	/**
		Grid size in pixels
	**/
	public var gridSize : Int;

	/**
		Grid-based layer width
	**/
	public var cWid : Int;

	/**
		Grid-based layer height
	**/
	public var cHei : Int;

	/**
		Pixel-based layer X offset
	**/
	public var pxOffsetX: Int;

	/**
		Pixel-based layer Y offset
	**/
	public var pxOffsetY : Int;

	/** Layer opacity (0-1) **/
	public var opacity : Float;

	public function new(json:led.Json.LayerInstanceJson) {
		identifier = json.__identifier;
		type =
			try LayerType.createByName(json.__type)
			catch(e:Dynamic) Unknown;
		gridSize = json.__gridSize;
		cWid = json.__cWid;
		cHei = json.__cHei;
		pxOffsetX = json.pxOffsetX;
		pxOffsetY = json.pxOffsetY;
		opacity = json.__opacity;
	}


	/**
		Return TRUE if grid-based coordinates are within layer bounds.
	**/
	public inline function isCoordValid(cx,cy) {
		return cx>=0 && cx<cWid && cy>=0 && cy<cHei;
	}


	inline function getCx(coordId:Int) {
		return coordId - Std.int(coordId/cWid)*cWid;
	}

	inline function getCy(coordId:Int) {
		return Std.int(coordId/cWid);
	}

	inline function getCoordId(cx,cy) return cx+cy*cWid;
}
