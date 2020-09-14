package test;

#if( !hl && !js )
#error "Not available on this build target"
#end

class HeapsRender {
	var project : data.CiTest;
	var root : h2d.Object;


	public function new() {
		project = new data.CiTest( #if hl hxd.Res.ciTest.entry.getText() #end );
		root = new h2d.Object( MainRenderable.ME.s2d );

		intGridDemo();
		autoLayerDemo();
		tileLayerDemo();

		#if !js
		hotReloadDemo();
		#end
	}


	/**
		Demo rendering of Tiles layer
	**/
	function tileLayerDemo() {
		// Layer data
		var layer = project.all_levels.LevelTest.l_TileTest;

		// H2D atlas tile
		var atlasTile = hxd.Res.atlas.gif87a.toTile();

		for(cx in 0...layer.cWid)
		for(cy in 0...layer.cHei) {
			if( !layer.hasTileAt(cx,cy) )
				continue;

			var tile = layer.tileset.getH2dTile(atlasTile, layer.getTileIdAt(cx,cy));
			var bitmap = new h2d.Bitmap(tile, root);
			bitmap.x = cx*layer.gridSize;
			bitmap.y = cy*layer.gridSize;
		}
	}



	/**
		Demo rendering of an Auto-Layer (IntGrid layer with tiles)
	**/
	function autoLayerDemo() {
		// Layer data
		var layer = project.all_levels.LevelTest.l_AutoLayerTest;

		// H2D atlas tile
		var atlasTile = hxd.Res.atlas.Cavernas_by_Adam_Saltsman.toTile();

		for(cx in 0...layer.cWid)
		for(cy in 0...layer.cHei) {
			if( !layer.hasAutoTiles(cx,cy) )
				continue;


			var autoTiles = layer.getAutoTiles(cx,cy);
			for(at in autoTiles) {
				var tile = layer.autoLayerTileset.getH2dTile(atlasTile, at.tileId, at.flips);

				var bitmap = new h2d.Bitmap(tile, root);
				bitmap.x = cx*layer.gridSize;
				bitmap.y = cy*layer.gridSize;
			}
		}
	}



	/**
		Demo rendering of an IntGrid layer
	**/
	function intGridDemo() {
		var layer = project.all_levels.LevelTest.l_IntGridTest;

		var off = 500;
		// Bg
		var g = new h2d.Graphics(root);
		g.beginFill(0xffffff);
		g.drawRect(off,0, layer.cWid*layer.gridSize, layer.cHei*layer.gridSize);

		// Layer render
		for(cx in 0...layer.cWid)
		for(cy in 0...layer.cHei) {
			if( !layer.hasValue(cx,cy) )
				continue;

			var c = layer.getColorInt(cx,cy);
			g.beginFill(c);
			g.drawRect(off+cx*layer.gridSize, cy*layer.gridSize, layer.gridSize, layer.gridSize);
		}
	}



	/**
		Demo of hot-reloading using Heaps resource system
	**/
	#if !js
	function hotReloadDemo() {
		hxd.Res.ciTest.watch( function() {
			// File changed on the disk
			trace("Hot-reloaded!");
			root.removeChildren();
			project.parseJson( hxd.Res.ciTest.entry.getText() );
			intGridDemo();
			tileLayerDemo();
		});
	}
	#end
}

