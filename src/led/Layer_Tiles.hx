package led;

class Layer_Tiles extends led.Layer {
	var tiles : Map<Int,Int>;

	public function new(json) {
		super(json);
		tiles = new Map();
		for(t in json.gridTiles)
			tiles.set(t.coordId, t.v);
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
		Return TRUE if the tileset atlas image is properly loaded and ready for tiles extraction
	**/
	public function isAtlasLoaded() {
		#if heaps
		return atlas!=null;
		#else
		return false;
		#end
	}


	#if heaps
	var atlas : Null<h2d.Tile>;

	/**
		Get h2d.Tile at coords
	**/
	public function getTileAt(cx,cy) : Null<h2d.Tile> {
		var tid = getTileIdAt(cx,cy);
		if( tid<0 )
			return null;

		return atlas.sub(0,0, 16,16); // TODO tile extraction
	}
	#end
}