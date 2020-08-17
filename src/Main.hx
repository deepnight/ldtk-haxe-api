class Main {
	static function main() new Main();

	public function new() {
		var p = LedParser.parse("../led/app/userFiles/mini.json");
		trace( p.levels );
		trace( p.levels_arr[0].identifier );
		trace( p.levels.Level0.layers.Entities );
		// trace(p.levelsAcc.Tutorial_intro.pxWid);
	}
}

