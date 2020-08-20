class Main {
	static function main() new Main();

	public function new() {
		// var p = new test.IntGrid();


		var p = new test.Mini();
		var l = p.levels.Level0.l_Objects;
		for(e in l.all_Mob)
			trace(e.identifier+" is "+e.f_mobType+" elite="+e.f_elite);


		// var p = new test.Gmtk();
		// for(e in p.levels.Credits.l_Entities.all_Label)  trace(e.f_Text);
	}
}

