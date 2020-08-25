class BootHl extends hxd.App {
	public static var ME : BootHl;

	// Boot
	static function main() {
		new BootHl();
	}

	// Engine ready
	override function init() {
		ME = this;
		hxd.Res.initLocal();
		new Main();
	}
}

