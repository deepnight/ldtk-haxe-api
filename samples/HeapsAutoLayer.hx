class HeapsAutoLayer extends hxd.App {
	static function main() {
		new HeapsAutoLayer();
	}

	override function init() {
		super.init();

		hxd.Res.initEmbed();
		s2d.setScale(3);

		var project = new _Project();

		// Layer data
		var layer = project.all_levels.LevelTest.l_AutoLayerTest;

		// H2D atlas tile
		var atlasTile = hxd.Res.Cavernas_by_Adam_Saltsman.toTile();

		for(cx in 0...layer.cWid)
		for(cy in 0...layer.cHei) {
			if( !layer.hasAutoTiles(cx,cy) )
				continue;

			var autoTiles = layer.getAutoTiles(cx,cy);

			for(at in autoTiles) {
				// Get corresponding H2D tile from tileset
				var tile = layer.autoLayerTileset.getH2dTile(atlasTile, at.tileId, at.flips);

				// Display it
				var bitmap = new h2d.Bitmap(tile, s2d);
				bitmap.x = cx*layer.gridSize;
				bitmap.y = cy*layer.gridSize;
			}
		}
	}
}

