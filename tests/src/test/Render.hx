package test;

#if( !hl && !js )
#error "Not available on this build target"
#end

class Render {
	var root : h2d.Object;
	var project : data.GameTest;

	public function new() {
		root = new h2d.Object( MainRenderable.ME.s2d );

		project = new data.GameTest( #if hl hxd.Res.gameTest.entry.getText() #end );

		tilesetRender();
		intGridRender();

		#if !js
		hotReloadTest();
		#end
	}

	function tilesetRender() {
		var level = project.all_levels.Level0.l_Bg;
		var atlas = hxd.Res.atlas.gif87a.toTile();
		for(cx in 0...level.cWid)
		for(cy in 0...level.cHei) {
			if( !level.hasTileAt(cx,cy) )
				continue;

			var tile = level.tileset.getH2dTile(atlas, level.getTileIdAt(cx,cy));
			var bitmap = new h2d.Bitmap(tile, root);
			bitmap.x = cx*level.gridSize;
			bitmap.y = cy*level.gridSize;
		}
	}

	function intGridRender() {
		var l = project.all_levels.Level0.l_Collisions;

		var off = 500;
		// Bg
		var g = new h2d.Graphics(root);
		g.beginFill(0xffffff);
		g.drawRect(off,0, l.cWid*l.gridSize, l.cHei*l.gridSize);

		// Layer render
		for(cx in 0...l.cWid)
		for(cy in 0...l.cHei) {
			if( !l.hasValue(cx,cy) )
				continue;

			var c = l.getColorInt(cx,cy);
			g.beginFill(c);
			g.drawRect(off+cx*l.gridSize, cy*l.gridSize, l.gridSize, l.gridSize);
		}
	}

	function hotReloadTest() {
		hxd.Res.gameTest.watch( function() {
			// File changed
			trace("Hot-reloaded!");
			root.removeChildren();
			project.parseJson( hxd.Res.gameTest.entry.getText() );
			intGridRender();
			tilesetRender();
		});
	}
}

