/**
	This sample for Heaps.io engine demonstrates how to MANUALLY render an AutoLayer using Heaps API. In this example, the auto-layer is an IntGrid layer with rules.

	It is recommended to use the .render() methods of layers that will do all the dirty work for you.
**/
class Heaps_AutoLayer extends hxd.App {

	static function main() {
		// Boot
		new Heaps_AutoLayer();
	}

	override function init() {
		super.init();

		// Init general stuff
		hxd.Res.initEmbed();
		s2d.setScale( dn.heaps.Scaler.bestFit_i(256,256) ); // scale view to fit

		// Read project JSON
		var project = new _Project();

		// Get "background" layer data
		var layer = project.all_levels.West.l_Background;


		// Render method 1: let the render() method create the TileGroup object
		var tileGroup = layer.render();
		s2d.addChild(tileGroup);

		// Render method 2: prepare your own TileGroup object and render into it
		var layer = project.all_levels.West.l_Collisions; // Get "collisions" layer data
		var tg = new h2d.TileGroup(layer.tileset.getAtlasTile(), s2d);
		layer.render(tg);
	}
}

