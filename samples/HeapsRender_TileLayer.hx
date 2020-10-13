/**
	This sample demonstrates how to manually render a "Tile" layer
	using Heaps API.
**/

class HeapsRender_TileLayer extends hxd.App {

	static function main() {
		// Boot
		new HeapsRender_TileLayer();
	}

	override function init() {
		super.init();

		// Init general stuff
		hxd.Res.initEmbed();
		s2d.setScale(3);

		// Read project JSON
		var project = new _Project();

		// Load atlas h2d.Tile from the disk
		var tilesetAtlasTile = hxd.Res.Minecraft_texture_pack.toTile();

		// Prepare a h2d.TileGroup for render (MUCH faster than using individual Bitmaps)
		var tileGroup = new h2d.TileGroup(tilesetAtlasTile, s2d);

		// Layer data
		var layer = project.all_levels.MyFirstLevel.l_TileTest;

		// Render
		for( cx in 0...layer.cWid )
		for( cy in 0...layer.cHei ) {
			if( !layer.hasTileAt(cx,cy) )
				continue;

			// Get corresponding h2d.Tile from tileset
			var tile = layer.tileset.getHeapsTile(tilesetAtlasTile, layer.getTileIdAt(cx,cy), 0);

			// Display it
			tileGroup.add(
				cx*layer.gridSize + layer.pxOffsetX,
				cy*layer.gridSize + layer.pxOffsetY,
				tile
			);
		}
	}
}

