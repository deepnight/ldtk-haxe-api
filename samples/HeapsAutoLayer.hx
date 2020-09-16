class HeapsAutoLayer extends hxd.App {

	static function main() {
		// Boot
		new HeapsAutoLayer();
	}

	override function init() {
		super.init();

		// Init general stuff
		hxd.Res.initEmbed();
		s2d.setScale(3);

		// Read project JSON
		var project = new _Project();

		// Layer data
		var layer = project.all_levels.LevelTest.l_AutoLayerTest;

		// Load atlas h2d.Tile from the disk
		var atlasTile = layer.tileset.loadAtlasTile(project);

		for( cx in 0...layer.cWid )
		for( cy in 0...layer.cHei )
		for( at in layer.getAutoTiles(cx,cy) ) { // get all the generated auto-layer tiles in this cell
			// Get corresponding H2D tile from tileset
			var tile = layer.tileset.getAutoLayerHeapsTile(atlasTile, at);

			// Display it
			var bitmap = new h2d.Bitmap(tile, s2d);
			bitmap.x = cx*layer.gridSize;
			bitmap.y = cy*layer.gridSize;
		}
	}
}

