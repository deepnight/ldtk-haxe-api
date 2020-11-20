/**
	This sample demonstrates how to render all layers and all levels in the
	project world.
**/
class HeapsRender_World extends hxd.App {

	static function main() {
		// Boot
		new HeapsRender_World();
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

		for( level in project.levels ) {
			// This wrapper will contain all layers
			var wrapper = new h2d.Object( s2d );
			wrapper.x = level.worldX;
			wrapper.y = level.worldY;

			// Pure auto-layer (background walls)
			level.l_Background.render(cavernasAtlasTile, wrapper);

			// IntGrid Auto-layer (walls, ladders, etc.)
			level.l_Collisions.render(cavernasAtlasTile, wrapper);

			// Tiles layer (manually added details)
			level.l_Custom_tiles.render(cavernasAtlasTile, wrapper);
		}

	}
}

