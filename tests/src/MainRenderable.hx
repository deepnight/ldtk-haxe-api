class MainRenderable extends hxd.App {
	public static var ME : MainRenderable;

	// Boot
	static function main() {
		new MainRenderable();
	}

	// Engine ready
	override function init() {
		ME = this;

		// Init resources
		#if js
		hxd.Res.initEmbed();
		#else
		hxd.Res.initLocal();
		#end

		// Run
		new Test();
	}
}

