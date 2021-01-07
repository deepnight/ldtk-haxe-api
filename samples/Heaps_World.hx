/**
	This sample for Heaps.io engine demonstrates how to render all layers and all levels in the project world.
**/
class Heaps_World extends hxd.App {

	static function main() {
		// Boot
		new Heaps_World();
	}

	override function init() {
		super.init();

		// Init general heaps stuff
		hxd.Res.initEmbed();
		s2d.setScale(3);

		// Read project JSON
		var project = new _Project();

		// Load atlas h2d.Tile from the Heaps resources (could be loaded in other ways)
		var cavernasAtlasTile = hxd.Res.Cavernas_by_Adam_Saltsman.toTile();

		// Create a single wrapper for all levels
		var worldWrapper = new h2d.Object( s2d );
		worldWrapper.scale(0.66); // scale it down so we can fit it on screen

		for( level in project.levels ) {
			// This wrapper will contain all layers
			var levelWrapper = new h2d.Object( worldWrapper );
			levelWrapper.x = level.worldX;
			levelWrapper.y = level.worldY;

			// Pure auto-layer (background walls)
			level.l_Background.render(cavernasAtlasTile, levelWrapper);

			// IntGrid Auto-layer (walls, ladders, etc.)
			level.l_Collisions.render(cavernasAtlasTile, levelWrapper);

			// Tiles layer (manually added details)
			level.l_Custom_tiles.render(cavernasAtlasTile, levelWrapper);
		}

	}
}

