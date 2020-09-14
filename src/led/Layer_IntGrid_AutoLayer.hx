package led;

typedef AutoTile = {
	/**
		Tile ID in the tileset
	**/
	var tileId: Int;

	/**
		Possible values: 0=> no flipping, 1=> X flip, 2=> Y flip, 3=> X and Y flips
	**/
	var flips: Int;
}

class Layer_IntGrid_AutoLayer extends led.Layer_IntGrid {
	/**
		AutoLayer tile informations, map is based on coordIds
	**/
	var autoTiles : Map<Int, Array<AutoTile>>;


	public function new(json) {
		super(json);

		autoTiles = new Map();
		for(jsonAutoTile in json.autoTiles)
		for(t in jsonAutoTile.tiles) {
			if( !autoTiles.exists(t.coordId) )
				autoTiles.set(t.coordId, []);
			autoTiles.get(t.coordId).push({
				tileId: t.tileId,
				flips: t.flips,
			});
		}

		for( at in autoTiles )
			at.reverse(); // Array order is reversed to match the display order
	}


	/**
		Return TRUE if there are auto-generated tiles at these coords
	**/
	public inline function hasAutoTiles(cx:Int, cy:Int) : Bool {
		return isCoordValid(cx,cy) && autoTiles.exists( getCoordId(cx,cy) );
	}

	/**
		Return the Array of auto-generated tiles at these coords.
	**/
	public function getAutoTiles(cx:Int, cy:Int) : Array<AutoTile> {
		if( !isCoordValid(cx,cy) )
			return [];
		else
			return autoTiles.exists( getCoordId(cx,cy) )
				? autoTiles.get( getCoordId(cx,cy) )
				: [];
	}
}
