package ldtk;

class Tileset {
	var untypedProject: ldtk.Project;

	/** Original parsed JSON object **/
	public var json(default,null) : ldtk.Json.TilesetDefJson;


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

	/** Untyped Enum based tags (stored as String). The "typed" getter method is created in macro. **/
	var untypedTags : Map< String, Map<Int,Int> >;


	public function new(p:ldtk.Project, json:ldtk.Json.TilesetDefJson) {
		this.json = json;
		untypedProject = p;
		identifier = json.identifier;
		tileGridSize = json.tileGridSize;
		relPath = json.relPath;
		pxWid = json.pxWid;
		pxHei = json.pxHei;

		// Init untyped enum tags
		untypedTags = new Map();
		if( json.enumTags!=null ) {
			for(t in json.enumTags) {
				untypedTags.set( p.capitalize(t.enumValueId), [] );
				for(tid in t.tileIds)
					untypedTags.get( p.capitalize(t.enumValueId) ).set(tid,tid);
			}
		}
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



	/***************************************************************************
		HEAPS API
	***************************************************************************/

	#if( !macro && heaps )
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

	/**
		Get a h2d.Tile using given rectangle pixel coords.
	**/
	public inline function getFreeTile(x:Int, y:Int, wid:Int, hei:Int) : Null<h2d.Tile> {
		var atlas = getAtlasTile();
		return atlas==null ? null : atlas.sub(x,y,wid,hei);
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

	#end // End of Heaps API




	/***************************************************************************
		Flixel API
	***************************************************************************/

	#if( !macro && flixel )

	var _tileFrames: Null< flixel.graphics.frames.FlxTileFrames >;
	var _atlas: Null< flixel.graphics.FlxGraphic >;

	/** Read Atlas and cache it locally **/
	function readAtlas() {
		if( _tileFrames==null ) {
			_atlas = untypedProject.getFlxGraphicAsset(relPath);
			_tileFrames = flixel.graphics.frames.FlxTileFrames.fromBitmapAddSpacesAndBorders(
				_atlas,
				flixel.math.FlxPoint.weak( tileGridSize, tileGridSize )
			);
		}
	}

	/** Get the main tileset FlxTileFrames **/
	public inline function getTileFrames() : flixel.graphics.frames.FlxTileFrames {
		readAtlas();
		return _tileFrames;
	}

	/** Get the main tileset FlxGraphic **/
	public inline function getAtlasGraphic() : flixel.graphics.FlxGraphic {
		readAtlas();
		return _atlas;
	}

	/** Get a FlxFrame using its ID **/
	public inline function getFrame(tileId:Int) : flixel.graphics.frames.FlxFrame {
		return getTileFrames().getByIndex(tileId);
	}

	#end // End of Flixel API
}
