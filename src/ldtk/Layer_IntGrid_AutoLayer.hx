package ldtk;

class Layer_IntGrid_AutoLayer extends ldtk.Layer_IntGrid {
	/**
		A single array containing all AutoLayer tiles informations, in "render" order
	**/
	public var autoTiles : Array<ldtk.Layer_AutoLayer.AutoTile>;


	public function new(json) {
		super(json);

		autoTiles = [];

		for(jsonAutoTile in json.autoLayerTiles)
			autoTiles.push({
				tileId: jsonAutoTile.t,
				flips: jsonAutoTile.f,
				renderX: jsonAutoTile.px[0],
				renderY: jsonAutoTile.px[1],
			});
	}

	function _getTileset() : Tileset return null; // replaced by Macros.hx


	#if( !macro && heaps )

	/**
		Render layer using provided Tileset atlas tile
	**/
	public function render(tilesetAtlasTile:h2d.Tile, ?parent:h2d.Object) {
		if( parent==null )
			parent = new h2d.Object();

		var tg = new h2d.TileGroup(tilesetAtlasTile, parent);
		renderInTileGroup(tg,false);

		return parent;
	}

	public inline function renderInTileGroup(tg:h2d.TileGroup, clearContent:Bool) {
		if( clearContent )
			tg.clear();

		for( autoTile in autoTiles ) {
			tg.add(
				autoTile.renderX + pxTotalOffsetX,
				autoTile.renderY + pxTotalOffsetY,
				_getTileset().getAutoLayerHeapsTile(tg.tile, autoTile)
			);
		}
	}

	#end
}
