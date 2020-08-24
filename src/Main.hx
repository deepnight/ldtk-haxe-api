class Main {
	public function new() {
		#if hl
		hxd.Res.initEmbed();
		#end

		// var p = new test.GameTest();
		// var l = p.all_levels.Level0.l_Bg;

		#if hl
		trace( hxd.Res.atlas.gif87a.getPixels().width );
		hxd.Res.atlas.gif87a.toTexture();
		// trace("ok");
		// trace( l.tileset.getTile(hxd.Res.atlas.SystemShock.toTile(), 0) );
		#end
		// for(tid in 0...15)
		// 	trace( tid+" => "+l.tileset.getAtlasX(tid)+","+l.tileset.getAtlasY(tid) );


		// var p = new test.Mini();
		// var l = p.all_levels.Level0.l_Bg;
		// trace(l.tileset.identifier);
		// trace(l.tileset.tileGridSize);
		// trace(l.tileset.relPath);
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


		// var p = new test.Gmtk();
		// for(e in p.all_levels.Credits.l_Entities.all_Label)  trace(e.f_Text+" col="+e.f_Color_hex+"/"+e.f_Color_int);
	}
}

