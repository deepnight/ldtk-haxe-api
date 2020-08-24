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
		trace("new tileset "+identifier);
	}


	/**
		Return TRUE if the tileset atlas image is properly loaded and ready for tiles extraction
	**/
	// public function isAtlasLoaded() {
	// 	return false;
	// }

	// inline function _requireAtlas() {
	// 	if( !isAtlasLoaded() )
	// 		throw "Tileset atlas image should be loaded first!";
	// }

	// Search a file in all classPaths + sub folders
	// function locateResFile(searchFileName:String) : Null<String> {
	// 	var pending = [""];
	// 	var cur = pending.pop();
	// 	while( cur!=null ) {
	// 		var res = hxd.Res.load(cur=="" ? "." : cur);
	// 		for(f in res) {
	// 			if( f.name==searchFileName )
	// 				return ( cur.length>0 ? cur+"/"  : "" ) + searchFileName;

	// 			if( f.entry.isDirectory )
	// 				pending.push( ( cur.length>0 ? cur+"/"  : "" ) + f.name );
	// 		}
	// 		cur = pending.pop();
	// 	}

	// 	return null;
	// }


	/**
		Get X pixel coordinate (in atlas image) from a specified tile ID
	**/
	public inline function getAtlasX(tileId:Int) {
		return ( tileId - Std.int( tileId / cWid ) * cWid ) * tileGridSize;
	}

	/**
		Get Y pixel coordinate (in atlas image) from a specified tile ID
	**/
	public inline function getAtlasY(tileId:Int) {
		return Std.int( tileId / cWid ) * tileGridSize;
	}


	#if heaps
	/** HEAPS API *******************************************************/

	/**
		Get h2d.Tile from a Tile ID
	**/
	public inline function getTile(atlasTile:h2d.Tile, tileId:Int) : Null<h2d.Tile> {
		if( tileId<0 )
			return null;
		else
			return atlasTile.sub(getAtlasX(tileId), getAtlasY(tileId), tileGridSize, tileGridSize);
	}
	#end

}
