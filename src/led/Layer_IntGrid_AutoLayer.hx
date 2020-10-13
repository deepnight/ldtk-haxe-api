package led;

class Layer_IntGrid_AutoLayer extends led.Layer_IntGrid {
	/**
		A single array containing all AutoLayer tiles informations, in "render" order
	**/
	public var autoTiles : Array<led.Layer_AutoLayer.AutoTile>;


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
