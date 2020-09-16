package led;

class Tileset {
	public var identifier : String;

	/**
		Path to the atlas image file, relative to the Project file
	**/
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

	#if sys
	/**
		Read the atlas image haxe.io.Bytes from the disk
	**/
	public function loadAtlasBytes(project:led.Project) : Null<haxe.io.Bytes> {
		try {
			var path = dn.FilePath.fromFile(project.projectDir+"/"+relPath);
			var fi = sys.io.File.read(path.full,true);
			return fi.readAll();
		}
		catch(e:Dynamic) {
			return null;
		}
	}
	#end


	#if heaps

	/**
		Read the atlas h2d.Tile directly from the file
	**/
	public function loadAtlasTile(project:led.Project) : Null<h2d.Tile> {
		var bytes = loadAtlasBytes(project);
		var tile = dn.ImageDecoder.decodeTile(bytes);
		return tile;
	}

	/**
		Get a h2d.Tile from a Tile ID.

		"flipBits" can be: 0=no flip, 1=flipX, 2=flipY, 3=bothXY
	**/
	public inline function getH2dTile(atlasTile:h2d.Tile, tileId:Int, flipBits:Int=0) : Null<h2d.Tile> {
		if( tileId<0 )
			return null;
		else {
			var t = atlasTile.sub( getAtlasX(tileId), getAtlasY(tileId), tileGridSize, tileGridSize );
			return switch flipBits {
				case 0: t;
				case 1: t.flipX(); t.setCenterRatio(0,0); t;
				case 2: t.flipY(); t.setCenterRatio(0,0); t;
				case 3: t.flipX(); t.flipY(); t.setCenterRatio(0,0); t;
				case _: throw "Unsupported flipBits value";
			};
		}
	}
	#end

}
