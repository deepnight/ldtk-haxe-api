package test;

import dn.CiAssert;

class Data {
	var project : data.GameTest;

	public function new() {
		project = new data.GameTest();

		CiAssert.isNotNull( project );
		CiAssert.isNotNull( project.all_levels );
		CiAssert.isNotNull( project.all_levels.Level0 );
		CiAssert.isNotNull( project.resolveLevel("Level0") );
	}
}

