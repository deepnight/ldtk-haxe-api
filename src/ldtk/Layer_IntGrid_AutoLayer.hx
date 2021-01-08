package ldtk;

class Layer_IntGrid_AutoLayer extends ldtk.Layer_IntGrid {
	/**
		A single array containing all AutoLayer tiles informations, in "render" order (ie. 1st is behind, last is on top)
	**/
	public var autoTiles : Array<ldtk.Layer_AutoLayer.AutoTile>;


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



	#if !macro

		#if heaps
		/**
			Render layer to a `h2d.TileGroup`. If `target` isn't provided, a new h2d.TileGroup is created.
		**/
		public inline function render(?target:h2d.TileGroup) : h2d.TileGroup {
			if( target==null )
				target = new h2d.TileGroup( tileset.getAtlasTile() );

			for( autoTile in autoTiles )
				target.add(
					autoTile.renderX + pxTotalOffsetX,
					autoTile.renderY + pxTotalOffsetY,
					tileset.getAutoLayerTile(autoTile)
				);

			return target;
		}
		#end

	#end
}
