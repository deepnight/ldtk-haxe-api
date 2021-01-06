package ldtk;

import ldtk.Json;

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
		Pixel-based layer X offset (includes both instance and definition offsets)
	**/
	public var pxTotalOffsetX: Int;

	/**
		Pixel-based layer Y offset (includes both instance and definition offsets)
	**/
	public var pxTotalOffsetY : Int;

	/** Layer opacity (0-1) **/
	public var opacity : Float;

	public function new(json:ldtk.Json.LayerInstanceJson) {
		identifier = json.__identifier;
		type =
			try LayerType.createByName(json.__type)
			catch(e:Dynamic) null; // TODO
		gridSize = json.__gridSize;
		cWid = json.__cWid;
		cHei = json.__cHei;
		pxTotalOffsetX = json.__pxTotalOffsetX;
		pxTotalOffsetY = json.__pxTotalOffsetY;
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
