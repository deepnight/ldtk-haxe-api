class BootHl extends hxd.App {
	// Boot
	static function main() {
		new BootHl();
	}

	// Engine ready
	override function init() {
		hxd.Res.initEmbed();
	}
}

