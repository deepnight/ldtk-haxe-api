/**
	This sample for Heaps.io engine demonstrates how to MANUALLY render a Tile layer using Heaps API. In this example, the auto-layer is an IntGrid layer with rules.

	It is recommended to use the .render() methods of layers that will do all the dirty work for you.

	For reference, the auto-layers are also rendered, but are blurred.
**/

class Heaps_TileLayer extends hxd.App {

	static function main() {
		// Boot
		new Heaps_TileLayer();
	}

	override function init() {
		super.init();

		// Init general stuff
		hxd.Res.initEmbed();
		s2d.setScale( dn.heaps.Scaler.bestFit_i(256,256) ); // scale view to fit

		// Read project JSON
		var project = new _Project();
		var level = project.all_levels.West;

		// Render auto-layers for reference in the background
		var bg = new h2d.Object(s2d);
		bg.addChild( level.l_Background.render() );
		bg.addChild( level.l_Collisions.render() );
		bg.filter = new h2d.filter.Blur(8,1,2);
		bg.alpha = 0.5;

		// Get layer data
		var layer = level.l_Custom_tiles;


		// Render method 1: just use layer.render()
		var tileGroup = layer.render();
		s2d.addChild(tileGroup);

		// Render method 2: render each tile manually
		var tileGroup = new h2d.TileGroup( layer.tileset.getAtlasTile(), s2d );

		for( cx in 0...layer.cWid )
		for( cy in 0...layer.cHei ) {
			if( !layer.hasAnyTileAt(cx,cy) )
				continue;

			// Get corresponding h2d.Tile from tileset
			for( tile in layer.getTileStackAt(cx,cy) )
				tileGroup.add(
					cx*layer.gridSize + layer.pxTotalOffsetX,
					cy*layer.gridSize + layer.pxTotalOffsetY,
					layer.tileset.getTile(tile.tileId, tile.flipBits) // get h2d.Tile
				);
		}

	}
}

