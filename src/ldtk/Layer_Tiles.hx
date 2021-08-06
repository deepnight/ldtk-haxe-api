package ldtk;

class Layer_Tiles extends ldtk.Layer {
	var tiles : Map<Int, Array<{ tileId:Int, flipBits:Int }>>;

	/** Getter to layer untyped Tileset instance. The typed value is created in macro. **/
	var untypedTileset(get,never) : ldtk.Tileset;
		inline function get_untypedTileset() return untypedProject._untypedTilesets.get(tilesetUid);

	/** Tileset UID **/
	public var tilesetUid(default,null) : Int;


	public function new(p,json) {
		super(p,json);

		tilesetUid = json.__tilesetDefUid;

		tiles = new Map();
		for(t in json.gridTiles)
			if( !tiles.exists(t.d[0]) )
				tiles.set(t.d[0], [{ tileId:t.t, flipBits:t.f }]);
			else
				tiles.get(t.d[0]).push({ tileId:t.t, flipBits:t.f });

	}

	/**
		Return the stack of tiles at coords, or empty array if there is none. To avoid useless memory allocations, you should check `hasAnyTileAt` before using this method.
	**/
	public inline function getTileStackAt(cx:Int,cy:Int) : Array<{ tileId:Int, flipBits:Int }> {
		return isCoordValid(cx,cy) && tiles.exists(getCoordId(cx,cy))
			? tiles.get( getCoordId(cx,cy) )
			: [];
	}

	/**
		Return TRUE if any tile exists at specified coords
	**/
	public inline function hasAnyTileAt(cx,cy) {
		return tiles.exists( getCoordId(cx,cy) );
	}


	#if !macro

		#if heaps
		/**
			Render layer to a `h2d.TileGroup`. If `target` isn't provided, a new h2d.TileGroup is created. If `target` is provided, it **must** have the same tile source as the layer tileset!
		**/
		public inline function render(?target:h2d.TileGroup) : h2d.TileGroup {
			if( target==null )
				target = new h2d.TileGroup( untypedTileset.getAtlasTile() );

			for( cy in 0...cHei )
			for( cx in 0...cWid )
				if( hasAnyTileAt(cx,cy) ) {
					for( tile in getTileStackAt(cx,cy) ) {
						target.add(
							cx*gridSize + pxTotalOffsetX,
							cy*gridSize + pxTotalOffsetY,
							untypedTileset.getTile(tile.tileId, tile.flipBits)
						);
					}
				}

			return target;
		}
		#end


		#if flixel
		/**
			Render layer to a `FlxGroup`. If `target` isn't provided, a new one is created.
		**/
		public function render(?target:flixel.group.FlxSpriteGroup) : flixel.group.FlxSpriteGroup {
			if( target==null ) {
				target = new flixel.group.FlxSpriteGroup();
				target.active = false;
			}


			for( cy in 0...cHei )
			for( cx in 0...cWid )
				if( hasAnyTileAt(cx,cy) )
					for( tile in getTileStackAt(cx,cy) ) {
						var s = new flixel.FlxSprite(cx*gridSize + pxTotalOffsetX, cy*gridSize + pxTotalOffsetY);
						s.flipX = tile.flipBits & 1 != 0;
						s.flipY = tile.flipBits & 2 != 0;
						s.frame = untypedTileset.getFrame(tile.tileId);
						s.width = gridSize;
						s.height = gridSize;
						target.add(s);
					}

			return target;
		}
		#end
	#end

}