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
	public var cWid : Int;
	public var cHei : Int;
	public var pxOffsetX: Int;
	public var pxOffsetY : Int;

	public function new(json:led.JsonTypes.LayerInstJson) {
		identifier = json.__identifier;
		type =
			try LayerType.createByName(json.__type)
			catch(e:Dynamic) Unknown;
		// type = json.__type;
		cWid = json.__cWid;
		cHei = json.__cHei;
		pxOffsetX = json.pxOffsetX;
		pxOffsetY = json.pxOffsetY;
	}


	/**
		Return TRUE if coordinates are within layer bounds.
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
