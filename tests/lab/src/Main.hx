import dn.*;
import LdtkProject;

class Main extends dn.Process {
	var bmp : h2d.Bitmap;
	var lp : LdtkProject;

	public function new() {
		super();
		createRoot(Boot.ME.s2d);
		
		lp = new LdtkProject();
	}

	override function onResize() {
		super.onResize();
	}

	override function update() {
		super.update();
		trace(ftime);
	}
}