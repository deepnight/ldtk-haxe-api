enum Pouet {
	A;
	B;
}

typedef PouetAlias = Pouet;

class Main {
	static function main() new Main();

	public function new() {
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

