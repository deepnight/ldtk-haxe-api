class Main {
	public function new() {
		var p = new test.GameTest();
		var l = p.all_levels.Level0.l_Bg;

		#if hl
		var atlas = hxd.Res.atlas.gif87a.toTile();
		for(tid in 0...15) {
			var t = l.tileset.getH2dTile(atlas, tid);
			var b = new h2d.Bitmap(t, BootHl.ME.s2d);
			b.x = tid * 40;
		}
		#end


		var p = new test.Mini();
		var l = p.all_levels.Level0.l_Objects;
		var e = l.all_Hero[0];
		trace(e.f_testA);
		var v = switch e.f_inventory {
			case Food: "f";
			case Gold: "g";
			case Ammo: "a";
			case Key: "k";
		}
		trace(v);


		// var p = new test.Gmtk();
		// for(e in p.all_levels.Credits.l_Entities.all_Label)  trace(e.f_Text+" col="+e.f_Color_hex+"/"+e.f_Color_int);
	}
}

