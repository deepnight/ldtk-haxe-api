package ldtk;

class Layer_Tiles extends ldtk.Layer {
	var tiles : Map<Int, Array<{ tileId:Int, flipBits:Int }>>;

	/** Getter to layer Tileset instance **/
	public var tileset(get,never) : ldtk.Tileset;
		inline function get_tileset() return untypedProject.tilesets.get(tilesetUid);
	var tilesetUid : Int;


	public function new(p,json) {
		super(p,json);

		tilesetUid = json.__tilesetDefUid;

		tiles = new Map();
		for(t in json.gridTiles)
			if( !tiles.exists(t.d[0]) )
				tiles.set(t.d[0], [{ tileId:t.t, flipBits:t.f }]);
			else
				tiles.get(t.d[0]).push({ tileId:t.t, flipBits:t.f });

	}

	/**
		Return the stack of tiles at coords, or empty array if there is none. To avoid useless memory allocations, you should check `hasAnyTileAt` before using this method.
	**/
	public inline function getTileStackAt(cx:Int,cy:Int) : Array<{ tileId:Int, flipBits:Int }> {
		return isCoordValid(cx,cy) && tiles.exists(getCoordId(cx,cy))
			? tiles.get( getCoordId(cx,cy) )
			: [];
	}

	/**
		Return TRUE if any tile exists at specified coords
	**/
	public inline function hasAnyTileAt(cx,cy) {
		return tiles.exists( getCoordId(cx,cy) );
	}


	#if !macro

		#if heaps
		/**
			Render layer using provided Tileset atlas tile
		**/
		public function render(tilesetAtlasTile:h2d.Tile, ?parent:h2d.Object) {
			if( parent==null )
				parent = new h2d.Object();

			var tg = new h2d.TileGroup(tilesetAtlasTile, parent);
			renderInTileGroup(tg,false);

			return parent;
		}

		public inline function renderInTileGroup(tg:h2d.TileGroup, clearContent:Bool) {
			if( clearContent )
				tg.clear();

			for( cy in 0...cHei )
			for( cx in 0...cWid ) {
				if( hasAnyTileAt(cx,cy) ) {
					for( tile in getTileStackAt(cx,cy) ) {
						tg.add(
							cx*gridSize + pxTotalOffsetX,
							cy*gridSize + pxTotalOffsetY,
							tileset.getTile(tile.tileId, tile.flipBits)
						);
					}
				}
			}
		}
		#end

	#end

}