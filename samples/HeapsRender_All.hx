/**
	This sample demonstrates how to render any layer using the
	provided render() method.
**/
class HeapsRender_All extends hxd.App {

	static function main() {
		// Boot
		new HeapsRender_All();
	}

	override function init() {
		super.init();

		// Init general heaps stuff
		hxd.Res.initEmbed();
		s2d.setScale(3);

		// Read project JSON
		var project = new _Project();
		var level = project.all_levels.MyFirstLevel;

		// Load atlas h2d.Tile from the Heaps resources (could be loaded in other ways)
		var cavernasAtlasTile = hxd.Res.Cavernas_by_Adam_Saltsman.toTile();

		// Pure auto-layer
		level.l_Pure_AutoLayer.render(cavernasAtlasTile, s2d);

		// IntGrid Auto-layer
		level.l_IntGrid_AutoLayer.render(cavernasAtlasTile, s2d);

		// Tiles layer
		var minecraftAtlasTile = hxd.Res.Minecraft_texture_pack.toTile();
		level.l_TileTest.render(minecraftAtlasTile, s2d);
	}
}

