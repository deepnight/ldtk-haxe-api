class Main {
	static function main() new Main();

	public function new() {
		var p = LedParser.parse("../led/app/userFiles/mini.json");
		trace( p.levels );
		trace( p.levels_arr[0].identifier );
		// trace( p.levels.Level0.layers.Entities );
		var l = p.levels_arr[0];
		// trace(l.layers.IntGrid.intGrid[0][0]);
		// var layer = l.layers.IntGrid;
		// trace(layer.cWid);
		// trace(layer.intGrid);
		// layer.
		// trace(l.layers.IntGrid.intGrid);
		// trace(p.levelsAcc.Tutorial_intro.pxWid);
	}
}

