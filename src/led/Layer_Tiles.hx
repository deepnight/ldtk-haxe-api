package led;

class Layer_Tiles extends led.Layer {
	var tiles : Map<Int,Int>;
	var atlasPath : String;

	public function new(json) {
		super(json);

		tiles = new Map();
		for(t in json.gridTiles)
			tiles.set(t.d[0], t.d[1]);
	}

	/**
		Return the tile ID at coords, or -1 if there is none.
	**/
	public inline function getTileIdAt(cx:Int,cy:Int) : Int {
		return isCoordValid(cx,cy) && tiles.exists(getCoordId(cx,cy))
			? tiles.get( getCoordId(cx,cy) )
			: -1;
	}

	/**
		Return TRUE if any tile exists at specified coords
	**/
	public inline function hasTileAt(cx,cy) {
		return getTileIdAt(cx,cy)>=0;
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
			if( hasTileAt(cx,cy) ) {
				var tileId = getTileIdAt(cx,cy);
				tg.add(
					cx*gridSize + pxOffsetX,
					cy*gridSize + pxOffsetY,
					_getTileset().getHeapsTile(tg.tile, tileId)
				);
			}
		}
	}

	#end

}