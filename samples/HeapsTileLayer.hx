class HeapsTileLayer extends hxd.App {

	static function main() {
		// Boot
		new HeapsTileLayer();
	}

	override function init() {
		super.init();

		// Init general stuff
		hxd.Res.initEmbed();
		s2d.setScale(3);

		// Read project JSON
		var project = new _Project();

		// Layer data
		var layer = project.all_levels.MyFirstLevel.l_TileTest;

		// Load atlas h2d.Tile from the disk
		var atlasTile = hxd.Res.Minecraft_texture_pack.toTile();

		for( cx in 0...layer.cWid )
		for( cy in 0...layer.cHei ) {
			if( !layer.hasTileAt(cx,cy) )
				continue;

			// Get corresponding H2D tile from tileset
			var tile = layer.tileset.getHeapsTile(atlasTile, layer.getTileIdAt(cx,cy), 0);

			// Display it
			var bitmap = new h2d.Bitmap(tile, s2d);
			bitmap.x = cx*layer.gridSize;
			bitmap.y = cy*layer.gridSize;
		}
	}
}

