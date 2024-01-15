/**
	This sample for Heaps.io engine demonstrates how to render any layer using the
	provided render() method.
**/

import LdtkProject;

class Heaps_TileLayers extends hxd.App {

	static function main() {
		// Boot
		new Heaps_TileLayers();
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

		// Level background image
		s2d.addChild( level.getBgBitmap() );

		// Render "pure" auto-layer (ie. background walls)
		s2d.addChild( level.l_Cavern_background.render() );

		// Render IntGrid Auto-layer tiles (ie. walls, ladders, etc.)
		s2d.addChild( level.l_Collisions.render() );

		// Render traditional Tiles layer (ie. manually added details)
		s2d.addChild( level.l_Custom_tiles.render() );
	}
}

