class Boot extends hxd.App {
	public static var ME : Boot;

	// Boot
	static function main() new Boot();

	// Engine ready
	override function init() {
		ME = this;

		hxd.Res.initEmbed();

		#if deepnightLibs
		new Main();
		#end
	}

	override function onResize() {
		super.onResize();

		#if deepnightLibs
		dn.Process.resizeAll();
		#end
	}

	override function update(deltaTime:Float) {
		super.update(deltaTime);
		#if deepnightLibs
		dn.Process.updateAll(hxd.Timer.tmod);
		#end
	}
}

