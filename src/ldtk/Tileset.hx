package ldtk;

class Tileset {
	var untypedProject: ldtk.Project;

	public var identifier : String;

	/**
		Path to the atlas image file, relative to the Project file
	**/
	public var relPath : String;

	public var tileGridSize : Int;
	var pxWid : Int;
	var pxHei : Int;
	var cWid(get,never) : Int; inline function get_cWid() return Math.ceil(pxWid/tileGridSize);

	// Atlas image data
	public var atlasBytes : haxe.io.Bytes;
	#if !macro
		#if heaps
		var atlasTile : Null<h2d.Tile>;
		#end
	#end


	public function new(p:ldtk.Project, json:ldtk.Json.TilesetDefJson) {
		untypedProject = p;
		identifier = json.identifier;
		tileGridSize = json.tileGridSize;
		relPath = json.relPath;
		pxWid = json.pxWid;
		pxHei = json.pxHei;

		// Load atlas
		atlasBytes = untypedProject.loadAsset(relPath);
		#if heaps

			atlasTile = h3d.Engine.getCurrent()==null ? null : dn.ImageDecoder.decodeTile(atlasBytes);

		#elseif openfl

			// TODO

		#end
	}

	function decodeAtlas() {
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

	/**
		Get a h2d.Tile from a Tile ID.

		"flipBits" can be: 0=no flip, 1=flipX, 2=flipY, 3=bothXY
	**/
	public inline function getTile(tileId:Int, flipBits:Int=0) : Null<h2d.Tile> {
		if( tileId<0 )
			return null;
		else {
			var t = atlasTile.sub( getAtlasX(tileId), getAtlasY(tileId), tileGridSize, tileGridSize );
			return switch flipBits {
				case 0: t;
				case 1: t.flipX(); t.setCenterRatio(0,0); t;
				case 2: t.flipY(); t.setCenterRatio(0,0); t;
				case 3: t.flipX(); t.flipY(); t.setCenterRatio(0,0); t;
				case _: Project.error("Unsupported flipBits value"); null;
			};
		}
	}

	/**
		Get a h2d.Tile from a Auto-Layer tile.
	**/
	public inline function getAutoLayerTile(autoLayerTile:ldtk.Layer_AutoLayer.AutoTile) : Null<h2d.Tile> {
		if( autoLayerTile.tileId<0 )
			return null;
		else
			return getTile(autoLayerTile.tileId, autoLayerTile.flips);
	}

	#end

}
