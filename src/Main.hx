class Main {
	static function main() new Main();

	public function new() {
		var p = new test.IntGrid();
		var l = p.levels.Level0.l_Colls;
		for(cx in 0...5)
			if( l.has(cx,0) )
				trace( dn.Color.intToHex( l.getColor(cx,0) ) );

		// var p = new test.Mini();

		// var p = new test.Gmtk();

	}
}

