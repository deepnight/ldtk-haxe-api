/**
	This sample for Heaps.io engine demonstrates how to manually render a "raw" IntGrid layer (ie. "without tiles")
	using Heaps API.
**/

import LdtkProject;

class Heaps_IntGrid extends hxd.App {
	static function main() {
		// Boot
		new Heaps_IntGrid();
	}

	override function init() {
		super.init();

		// Init general stuff
		hxd.Res.initEmbed();
		s2d.setScale( dn.heaps.Scaler.bestFit_i(256,256) ); // scale view to fit

		// Read project JSON
		var project = new LdtkProject();

		// Layer data
		var layer = project.all_worlds.SampleWorld.all_levels.West.l_Collisions;

		// Prepare a h2d.Graphics to render layer
		var g = new h2d.Graphics(s2d);

		// Render background
		g.beginFill(project.bgColor_int);
		g.drawRect(0, 0, layer.cWid*layer.gridSize, layer.cHei*layer.gridSize);
		g.endFill();

		// Render IntGrid layer cells
		for(cx in 0...layer.cWid)
		for(cy in 0...layer.cHei) {
			if( !layer.hasValue(cx,cy) ) // skip empty cells
				continue;

			var color = layer.getColorInt(cx,cy);
			g.beginFill(color);
			g.drawRect(cx*layer.gridSize, cy*layer.gridSize, layer.gridSize, layer.gridSize);
		}
	}
}

