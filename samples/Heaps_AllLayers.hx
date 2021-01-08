/**
	This sample for Heaps.io engine demonstrates how to render any layer using the
	provided render() method.
**/
class Heaps_AllLayers extends hxd.App {

	static function main() {
		// Boot
		new Heaps_AllLayers();
	}

	override function init() {
		super.init();

		// Init general heaps stuff
		hxd.Res.initEmbed();
		s2d.setScale( dn.heaps.Scaler.bestFit_i(256,256) ); // scale view to fit

		// Read project JSON
		var project = new _Project();
		var level = project.all_levels.West;

		// Pure auto-layer (background walls)
		s2d.addChild( level.l_Background.render() );

		// IntGrid Auto-layer (walls, ladders, etc.)
		s2d.addChild( level.l_Collisions.render() );

		// Tiles layer (manually added details)
		s2d.addChild( level.l_Custom_tiles.render() );
	}
}

