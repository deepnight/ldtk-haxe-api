package led;

class Layer_Tiles extends led.Layer {
	var tiles : Map<Int,Int>;
	var atlasPath : String;

	public function new(json) {
		super(json);
		tiles = new Map();
		for(t in json.gridTiles)
			tiles.set(t.coordId, t.v);

		loadAtlas();
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

	public function loadAtlas() {
		#if heaps
		if( atlas!=null )
			atlas.dispose();

		try hxd.Res.loader
		catch( e:Dynamic ) throw "hxd.Res wasn't initialized!";

		// var fp = dn.FilePath.fromFile();
		// hxd.Res.load()

		#end
		return isAtlasLoaded();
	}


	#if heaps
	var atlas : Null<h2d.Tile>;

	/**
		Return atlas as h2d.Tile
	**/
	public function getAtlasTile() return atlas;

	/**
		Get h2d.Tile at coords
	**/
	public function getTileAt(cx,cy) : Null<h2d.Tile> {
		if( !isAtlasLoaded() )
			return null;

		var tid = getTileIdAt(cx,cy);
		if( tid<0 )
			return null;

		return atlas.sub(0,0, 16,16); // TODO tile extraction
	}
	#end
}