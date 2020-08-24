class Main {
	var p : test.GameTest;

	public function new() {
		p = new test.GameTest(#if hl hxd.Res.gameTest.entry.getText() #end);

		// var l = p.all_levels.Level0.l_Bg;

		// var p = new test.Mini();
		// // p.all_levels.Level0.l_Objects.
		// var l = p.all_levels.Level0.l_Objects;
		// var e = l.all_Hero[0];
		// trace(e.f_testA);
		// var v = switch e.f_inventory {
		// 	case Food: "f";
		// 	case Gold: "g";
		// 	case Ammo: "a";
		// 	case Key: "k";
		// }
		// trace(v);


		var p = new test.Gmtk();
		for(e in p.all_levels.Credits.l_Entities.all_Label)  trace(e.f_Text+" col="+e.f_Color_hex+"/"+e.f_Color_int);


		tilesetRender();
		intGridRender();
		hotReloadTest();
	}

	function tilesetRender() {
		#if hl
		var l = p.all_levels.Level0.l_Bg;
		var atlas = hxd.Res.atlas.gif87a.toTile();
		for(cx in 0...l.cWid)
		for(cy in 0...l.cHei) {
			if( !l.hasTileAt(cx,cy) )
				continue;

			var t = l.tileset.getH2dTile(atlas, l.getTileIdAt(cx,cy));
			var b = new h2d.Bitmap(t, BootHl.ME.s2d);
			b.x = cx*l.gridSize;
			b.y = cy*l.gridSize;
		}
		#end
	}

	function intGridRender() {
		var l = p.all_levels.Level0.l_Collisions;

		#if hl
		var off = 500;
		// Bg
		var g = new h2d.Graphics(BootHl.ME.s2d);
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
		#end
	}

	function hotReloadTest() {
		#if hl
		hxd.Res.gameTest.watch( function() {
			// File changed
			trace("reloaded!");
			BootHl.ME.s2d.removeChildren();
			p.parseJson( hxd.Res.gameTest.entry.getText() );
			intGridRender();
			tilesetRender();
		});
		#end
	}
}

