package ldtk;


typedef AutoTile = {
	/**
		X coordinate to place this tile in your render
	**/
	var renderX: Int;

	/**
		Y coordinate to place this tile in your render
	**/
	var renderY: Int;

	/**
		Tile ID in the tileset
	**/
	var tileId: Int;

	/**
		Possible values: 0=> no flipping, 1=> X flip, 2=> Y flip, 3=> X and Y flips
	**/
	var flips: Int;
}


class Layer_AutoLayer extends ldtk.Layer {
	/**
		A single array containing all AutoLayer tiles informations, in "render" order
	**/
	public var autoTiles : Array<AutoTile>;


	/** Getter to layer Tileset instance **/
	public var tileset(get,never) : ldtk.Tileset;
		inline function get_tileset() return untypedProject.tilesets.get(tilesetUid);
	var tilesetUid : Int;


	public function new(p,json) {
		super(p,json);

		autoTiles = [];
		tilesetUid = json.__tilesetDefUid;

		for(jsonAutoTile in json.autoLayerTiles)
			autoTiles.push({
				tileId: jsonAutoTile.t,
				flips: jsonAutoTile.f,
				renderX: jsonAutoTile.px[0],
				renderY: jsonAutoTile.px[1],
			});
	}


	#if( !macro && heaps )

	/**
		Render layer using provided Tileset atlas tile
	**/
	public function render(?parent:h2d.Object) : h2d.TileGroup {
		if( parent==null )
			parent = new h2d.Object();

		var tg = new h2d.TileGroup(tileset.getAtlasTile(), parent);
		renderToTileGroup(tg,false);
		return tg;
	}


	public inline function renderToTileGroup(tg:h2d.TileGroup, clearContent:Bool) {
		if( clearContent )
			tg.clear();

		for( autoTile in autoTiles ) {
			tg.add(
				autoTile.renderX + pxTotalOffsetX,
				autoTile.renderY + pxTotalOffsetY,
				tileset.getAutoLayerTile(autoTile)
			);
		}
	}

	#end
}
