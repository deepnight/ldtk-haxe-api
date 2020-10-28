package led;

class Layer_Tiles extends led.Layer {
	var tiles : Map<Int, Array<Int>>;
	var atlasPath : String;

	public function new(json) {
		super(json);

		tiles = new Map();
		for(t in json.gridTiles)
			if( !tiles.exists(t.d[0]) )
				tiles.set(t.d[0], [t.d[1]]);
			else
				tiles.get(t.d[0]).push( t.d[1] );

	}

	/**
		Return the stack of tile IDs at coords, or empty array if there is none. To avoid useless memory allocations, you should check `hasAnyTileAt` before using this method.
	**/
	public inline function getTileIdStackAt(cx:Int,cy:Int) : Array<Int> {
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

	function _getTileset() : Tileset return null; // replaced by Macros.hx



	#if( !macro && heaps )

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
				for( tileId in getTileIdStackAt(cx,cy) ) {
					tg.add(
						cx*gridSize + pxTotalOffsetX,
						cy*gridSize + pxTotalOffsetY,
						_getTileset().getHeapsTile(tg.tile, tileId)
					);
				}
			}
		}
	}

	#end

}