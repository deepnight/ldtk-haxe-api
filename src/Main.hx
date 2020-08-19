class Main {
	static function main() new Main();

	public function new() {
		// var p = new test.IntGrid();

		var p = new test.Mini();
		var l = p.levels.Level0.l_Objects;
		trace("Mobs=" + l.getAll(Mob).length );

		// var p = new test.Gmtk();

	}
}

