/**
	This sample for Heaps.io engine demonstrates how to manually render a "raw" IntGrid layer (ie. "without tiles")
	using Heaps API.
**/

class Heaps_IntGrid extends hxd.App {
	static function main() {
		// Boot
		new Heaps_IntGrid();
	}

	override function init() {
		super.init();

		// Init general stuff
		hxd.Res.initEmbed();
		s2d.setScale(3);

		// Read project JSON
		var project = new _Project();

		// Layer data
		var layer = project.all_levels.West.l_Collisions;

		// Render background
		var g = new h2d.Graphics(s2d);
		g.beginFill(project.bgColor_int);
		g.drawRect(0, 0, layer.cWid*layer.gridSize, layer.cHei*layer.gridSize);
		g.endFill();

		// Display IntGrid layer
		for(cx in 0...layer.cWid)
		for(cy in 0...layer.cHei) {
			if( !layer.hasValue(cx,cy) )
				continue;

			var c = layer.getColorInt(cx,cy);
			g.beginFill(c);
			g.drawRect(cx*layer.gridSize, cy*layer.gridSize, layer.gridSize, layer.gridSize);
		}
	}
}

