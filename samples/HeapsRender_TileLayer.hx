/**
	This sample demonstrates how to manually render a "Tile" layer
	using Heaps API.

	For reference, the auto-layers are also rendered, but are blurred.
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
		var level = project.all_levels.Test_level;

		// Load atlas h2d.Tile from the disk
		var tilesetAtlasTile = hxd.Res.Cavernas_by_Adam_Saltsman.toTile();

		// Render auto-layers for reference in the background
		var bg = new h2d.Object(s2d);
		level.l_Background.render(tilesetAtlasTile, bg);
		level.l_Collisions.render(tilesetAtlasTile, bg);
		bg.filter = new h2d.filter.Blur(4,1,2);
		bg.alpha = 0.66;

		// Prepare a h2d.TileGroup for render (MUCH faster than using individual Bitmaps)
		var tileGroup = new h2d.TileGroup(tilesetAtlasTile, s2d);

		// Layer data
		var layer = level.l_Custom_tiles;

		// Render
		for( cx in 0...layer.cWid )
		for( cy in 0...layer.cHei ) {
			if( !layer.hasAnyTileAt(cx,cy) )
				continue;

			// Get corresponding h2d.Tile from tileset
			for( tileId in layer.getTileIdStackAt(cx,cy) ) {
				var tile = layer.tileset.getHeapsTile(tilesetAtlasTile, tileId, 0);

				// Display it
				tileGroup.add(
					cx*layer.gridSize + layer.pxTotalOffsetX,
					cy*layer.gridSize + layer.pxTotalOffsetY,
					tile
				);
			}
		}
	}
}

