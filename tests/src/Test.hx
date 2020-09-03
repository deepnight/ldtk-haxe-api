class Test {
	var gt : test.GameTest;

	public function new() {
		gt = new test.GameTest( #if hl hxd.Res.gameTest.entry.getText() #end );

		#if( hl || js )
		new TestRender();
		#end
	}
}

