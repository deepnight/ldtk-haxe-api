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


class Layer_AutoLayer extends led.Layer {
	/**
		A single array containing all AutoLayer tiles informations, in "render" order
	**/
	public var autoTiles : Array<AutoTile>;


	public function new(json) {
		super(json);

		autoTiles = [];

		for(jsonAutoTile in json.autoLayerTiles)
			autoTiles.push({
				tileId: jsonAutoTile.d[2],
				flips: jsonAutoTile.f,
				renderX: jsonAutoTile.px[0],
				renderY: jsonAutoTile.px[1],
			});
	}
}
