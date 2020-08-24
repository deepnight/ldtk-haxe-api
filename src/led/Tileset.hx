package led;

class Tileset {
	public var identifier : String;
	public var relPath : String;
	public var tileGridSize : Int;

	public function new(json:led.JsonTypes.TilesetDefJson) {
		identifier = json.identifier;
		tileGridSize = json.tileGridSize;
		relPath = json.relPath;

		loadAtlas();
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

	/**
		Load atlas image file using the internal relPath value
	**/
	public function loadAtlas() {
		#if heaps
		if( atlas!=null )
			atlas.dispose();

		try hxd.Res.loader
		catch( e:Dynamic ) throw "hxd.Res wasn't initialized!";

		// Locate atlas in res
		var file = dn.FilePath.extractFileWithExt(relPath);
		trace( locateResFile(file) );

		#end
		return isAtlasLoaded();
	}


	// Search a file in all classPaths + sub folders
	static function locateResFile(searchFileName:String) : Null<String> {
		// var pending = Context.getClassPath().map( function(p) return StringTools.replace(p,"\\","/") );
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
		Return atlas as h2d.Tile
	**/
	public function getAtlasTile() return atlas;

	/**
		Get h2d.Tile at coords
	**/
	public function getTile(tid:Int) : Null<h2d.Tile> {
		if( !isAtlasLoaded() )
			return null;

		if( tid<0 )
			return null;

		return atlas.sub(0,0, 16,16); // TODO tile extraction
	}
	#end

}
