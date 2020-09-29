package led;

typedef AutoTile = {
	/**
		X coordinate to place this tile in your render
	**/
	var renderX: Int;

	/**
		Y coordinate to place this tile in your render
	**/
	var renderY: Int;

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
		A single array containing all AutoLayer tiles informations, in "render" order
	**/
	public var autoTiles : Array<AutoTile>;


	public function new(json) {
		super(json);

		autoTiles = [];

		for(jsonAutoTile in json.autoTiles)
		for(res in jsonAutoTile.results)
		for(t in res.tiles) {
			autoTiles.push({
				tileId: t.tileId,
				renderX: t.__x,
				renderY: t.__y,
				flips: res.flips,
			});
		}

		// Array order is reversed to match the display order
		autoTiles.reverse();
	}
}
