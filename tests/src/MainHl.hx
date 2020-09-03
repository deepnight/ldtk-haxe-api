class MainHl extends hxd.App {
	public static var ME : MainHl;

	// Boot
	static function main() {
		new MainHl();
	}

	// Engine ready
	override function init() {
		ME = this;
		hxd.Res.initLocal();
		new Test();
	}
}

