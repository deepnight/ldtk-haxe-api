/**
	This sample demonstrates how to manually render an AutoLayer
	using Heaps API. In this example, the auto-layer is an IntGrid layer
	with rules.
**/
class HeapsRender_AutoLayer extends hxd.App {

	static function main() {
		// Boot
		new HeapsRender_AutoLayer();
	}

	override function init() {
		super.init();

		// Init general stuff
		hxd.Res.initEmbed();
		s2d.setScale(3);

		// Read project JSON
		var project = new _Project();

		// Load atlas h2d.Tile from the Heaps resources (could be loaded in other ways)
		var atlasTile = hxd.Res.Cavernas_by_Adam_Saltsman.toTile();

		// Layer data
		var layer = project.all_levels.MyFirstLevel.l_IntGrid_AutoLayer;

		// Get all the generated auto-layer tiles in this layer
		for( autoTile in layer.autoTiles ) {
			// Get corresponding H2D.Tile from tileset
			var tile = layer.tileset.getAutoLayerHeapsTile(atlasTile, autoTile);

			// Display it
			var bitmap = new h2d.Bitmap(tile, s2d);
			bitmap.x = autoTile.renderX; // we use the auto-generated coords directly, because it's easier :)
			bitmap.y = autoTile.renderY;
		}
	}
}

