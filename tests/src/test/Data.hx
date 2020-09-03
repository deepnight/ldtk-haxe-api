package test;

class Data {
	var project : data.GameTest;

	public function new() {
		project = new data.GameTest();

		var v = true;
		Assert.check( v==true );
		Assert.check( project.all_levels!=null );
		Assert.check( project.all_levels.Level0!=null );
		Assert.check( project.resolveLevel("Level0")!=null );
	}
}

