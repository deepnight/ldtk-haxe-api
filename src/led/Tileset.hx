package led;

class Tileset {
	public var identifier : String;
	public var relPath : String;
	public var tileGridSize : Int;
	var pxWid : Int;
	var pxHei : Int;
	var cWid(get,never) : Int; inline function get_cWid() return dn.M.ceil(pxWid/tileGridSize);

	public function new(json:led.JsonTypes.TilesetDefJson) {
		identifier = json.identifier;
		tileGridSize = json.tileGridSize;
		relPath = json.relPath;
		pxWid = json.pxWid;
		pxHei = json.pxHei;
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

	inline function _requireAtlas() {
		if( !isAtlasLoaded() )
			throw "Tileset atlas image should be loaded first!";
	}

	// Search a file in all classPaths + sub folders
	function locateResFile(searchFileName:String) : Null<String> {
		var pending = [""];
		var cur = pending.pop();
		while( cur!=null ) {
			var res = hxd.Res.load(cur=="" ? "." : cur);
			for(f in res) {
				if( f.name==searchFileName )
					return ( cur.length>0 ? cur+"/"  : "" ) + searchFileName;

				if( f.entry.isDirectory )
					pending.push( ( cur.length>0 ? cur+"/"  : "" ) + f.name );
			}
			cur = pending.pop();
		}

		return null;
	}



	#if heaps
	/** HEAPS API *******************************************************/
	var atlas : Null<h2d.Tile>;

	/**
		Use atlas from Heaps hxd.Res entry
	**/
	public function loadAtlasFromRes(res:hxd.res.Image) {
		if( atlas!=null )
			atlas.dispose();

		atlas = res.toTile();
	}


	/**
		Return atlas as h2d.Tile
	**/
	public function getAtlasTile() {
		_requireAtlas();
		return atlas.clone();
	}

	/**
		Get h2d.Tile from a Tile ID
	**/
	public inline function getTile(tileId:Int) : Null<h2d.Tile> {
		_requireAtlas();

		if( tileId<0 )
			return null;
		else
			return atlas.sub(getTileX(tileId), getTileY(tileId), tileGridSize, tileGridSize);
	}

	/**
		Get X pixel coordinate (in atlas image) from a specified tile ID
	**/
	public inline function getTileX(tileId:Int) {
		return ( tileId - Std.int( tileId / cWid ) * cWid ) * tileGridSize;
	}

	/**
		Get Y pixel coordinate (in atlas image) from a specified tile ID
	**/
	public inline function getTileY(tileId:Int) {
		return Std.int( tileId / cWid ) * tileGridSize;
	}
	#end

}
