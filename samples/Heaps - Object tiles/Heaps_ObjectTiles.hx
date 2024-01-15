/**
	This sample for Heaps.io engine demonstrates how to render any layer using the
	provided render() method.
**/

import LdtkProject;

class Heaps_ObjectTiles extends hxd.App {

	static function main() {
		// Boot
		new Heaps_ObjectTiles();
	}

	override function init() {
		super.init();

		// Init general heaps stuff
		hxd.Res.initEmbed();
		s2d.setScale( dn.heaps.Scaler.bestFit_i(256,256) ); // scale view to fit

		// Read project JSON
		var project = new LdtkProject();

		// Get level data
		var level = project.all_worlds.SampleWorld.all_levels.West;

		// Prepare a container for the level layers
		var levelBg = new h2d.Object();
		s2d.addChild(levelBg);
		levelBg.alpha = 0.5; // opacity
		levelBg.filter = new h2d.filter.Blur(4,1,2);  // blur it a little bit

		// Render IntGrid layer named "Collisions"
		levelBg.addChild( level.l_Collisions.render() );

		// Render tiles layer named "Custom_tiles"
		levelBg.addChild( level.l_Custom_tiles.render() );


		// Render each "Item" entity
		for( item in level.l_Entities.all_Item ) {
			// Read h2d.Tile based on the "type" enum value from the entity
			var tile = project.getEnumTile( item.f_type );

			// Apply the same pivot coord as the Entity to the Tile
			// (in this case, the pivot is the bottom-center point of the tile)
			tile.setCenterRatio( item.pivotX, item.pivotY );

			// Display it
			var bitmap = new h2d.Bitmap(tile);
			s2d.addChild(bitmap);
			bitmap.x = item.pixelX;
			bitmap.y = item.pixelY;
		}
	}
}

