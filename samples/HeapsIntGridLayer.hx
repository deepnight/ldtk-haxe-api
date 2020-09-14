class HeapsIntGridLayer extends hxd.App {
	static function main() {
		new HeapsIntGridLayer();
	}

	override function init() {
		super.init();

		hxd.Res.initEmbed();
		var project = new _Project();

		// Layer data
		var layer = project.all_levels.LevelTest.l_IntGridTest;

		// Render background
		var g = new h2d.Graphics(s2d);
		g.beginFill(0x666666);
		g.drawRect(0, 0, layer.cWid*layer.gridSize, layer.cHei*layer.gridSize);
		g.endFill();

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

