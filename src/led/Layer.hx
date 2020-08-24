package led;

enum LayerType {
	IntGrid;
	Tiles;
	Entities;
	Unknown;
}

class Layer {
	public var identifier : String;
	public var type : LayerType;

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

	public function new(json:led.JsonTypes.LayerInstJson) {
		identifier = json.__identifier;
		type =
			try LayerType.createByName(json.__type)
			catch(e:Dynamic) Unknown;
		cWid = json.__cWid;
		cHei = json.__cHei;
		pxOffsetX = json.pxOffsetX;
		pxOffsetY = json.pxOffsetY;
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
