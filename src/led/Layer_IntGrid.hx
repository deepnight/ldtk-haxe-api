package led;

class Layer_IntGrid extends led.Layer {
	public var intGrid : Map<Int,Int> = new Map();

	public function new(json) {
		super(json);

		for(ig in json.intGrid)
			intGrid.set(ig.coordId, ig.v);
	}

	public inline function getInt(cx:Int, cy:Int) {
		return !isValid(cx,cy) || !intGrid.exists( getCoordId(cx,cy) ) ? -1 : intGrid.get( getCoordId(cx,cy) );
	}

	public inline function has(cx:Int, cy:Int, ?val:Int) {
		return val==null && getInt(cx,cy)!=-1 || val!=null && getInt(cx,cy)==val;
	}

	public inline function isValid(cx,cy) {
		return cx>=0 && cx<cWid && cy>=0 && cy<cHei;
	}

	inline function getCoordId(cx,cy) return cx+cy*cWid;

	inline function getCx(coordId:Int) {
		return coordId - Std.int(coordId/cWid)*cWid;
	}

	inline function getCy(coordId:Int) {
		return Std.int(coordId/cWid);
	}
}
