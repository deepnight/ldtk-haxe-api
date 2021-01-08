package ldtk;

class Tileset {
	var untypedProject: ldtk.Project;

	/** Tileset unique identifier **/
	public var identifier : String;

	/** Path to the atlas image file, relative to the Project file **/
	public var relPath : String;

	/** Tile size in pixels **/
	public var tileGridSize : Int;
	// TODO support tile spacing

	/** Tileset width in pixels **/
	public var pxWid : Int;

	/** Tileset height in pixels **/
	public var pxHei : Int;

	var cWid(get,never) : Int; inline function get_cWid() return Math.ceil(pxWid/tileGridSize);


	public function new(p:ldtk.Project, json:ldtk.Json.TilesetDefJson) {
		untypedProject = p;
		identifier = json.identifier;
		tileGridSize = json.tileGridSize;
		relPath = json.relPath;
		pxWid = json.pxWid;
		pxHei = json.pxHei;
	}

	/** Print class debug info **/
	@:keep public function toString() {
		return 'ldtk.Tileset[#$identifier, path=$relPath]';
	}


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



	#if( !macro && heaps )
	/***************************************************************************
		HEAPS API
	***************************************************************************/

	var _cachedAtlasTile : Null<h2d.Tile>;

	/** Get the main tileset h2d.Tile **/
	public inline function getAtlasTile() : Null<h2d.Tile> {
		if( _cachedAtlasTile!=null )
			return _cachedAtlasTile;
		else {
			var bytes = untypedProject.getAsset(relPath);
			_cachedAtlasTile = dn.ImageDecoder.decodeTile(bytes);
			if( _cachedAtlasTile==null )
				_cachedAtlasTile = h2d.Tile.fromColor(0xff0000, pxWid, pxHei);
			return _cachedAtlasTile;
		}
	}

	/**
		Get a h2d.Tile from a Tile ID.

		"flipBits" can be: 0=no flip, 1=flipX, 2=flipY, 3=bothXY
	**/
	public inline function getTile(tileId:Int, flipBits:Int=0) : Null<h2d.Tile> {
		if( tileId<0 )
			return null;
		else {
			var atlas = getAtlasTile();
			var t = atlas.sub( getAtlasX(tileId), getAtlasY(tileId), tileGridSize, tileGridSize );
			return switch flipBits {
				case 0: t;
				case 1: t.flipX(); t.setCenterRatio(0,0); t;
				case 2: t.flipY(); t.setCenterRatio(0,0); t;
				case 3: t.flipX(); t.flipY(); t.setCenterRatio(0,0); t;
				case _: Project.error("Unsupported flipBits value"); null;
			}
		}
	}

	@:deprecated("Use getTile() instead") @:noCompletion
	public inline function getHeapsTile(oldAtlasTile:h2d.Tile, tileId:Int, flipBits:Int=0) {
		return getTile(tileId, flipBits);
	}


	/** Get a h2d.Tile from a Auto-Layer tile. **/
	public inline function getAutoLayerTile(autoLayerTile:ldtk.Layer_AutoLayer.AutoTile) : Null<h2d.Tile> {
		if( autoLayerTile.tileId<0 )
			return null;
		else
			return getTile(autoLayerTile.tileId, autoLayerTile.flips);
	}

	@:deprecated("Use getAutoLayerTile() instead") @:noCompletion
	public inline function getAutoLayerHeapsTile(oldAtlasTile:h2d.Tile, autoLayerTile:ldtk.Layer_AutoLayer.AutoTile) {
		return getAutoLayerTile(autoLayerTile);
	}

	#end

}
