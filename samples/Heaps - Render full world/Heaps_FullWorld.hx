/**
	This sample for Heaps.io engine demonstrates how to render all layers and all levels in the project world.
**/

import LdtkProject;

class Heaps_FullWorld extends hxd.App {

	static function main() {
		// Boot
		new Heaps_FullWorld();
	}

	override function init() {
		super.init();

		// Init general heaps stuff
		hxd.Res.initEmbed();
		s2d.setScale( dn.heaps.Scaler.bestFit_i(650,256) ); // scale view to fit

		// Read project JSON
		var project = new LdtkProject();

		// Render each level
		for( level in project.all_worlds.SampleWorld.levels ) {
			// Create a wrapper to render all layers in it
			var levelWrapper = new h2d.Object( s2d );

			// Position accordingly to world pixel coords
			levelWrapper.x = level.worldX;
			levelWrapper.y = level.worldY;

			// Level background image
			if( level.hasBgImage() )
				levelWrapper.addChild( level.getBgBitmap() );

			// Render background layer
			levelWrapper.addChild( level.l_Cavern_background.render() );

			// Render collision layer tiles
			levelWrapper.addChild( level.l_Collisions.render() );

			// Render custom tiles layer
			levelWrapper.addChild( level.l_Custom_tiles.render() );
		}

	}
}

