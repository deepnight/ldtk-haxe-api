package ldtk;


/**
	This is the root of any Project JSON file. It contains:

- the project settings,
- an array of levels
- and a definition object (that can probably be safely ignored for most users).
**/
@display("LDtk Json root")
typedef ProjectJson = {
	/** File format version **/
	var jsonVersion: String;

	/** Default X pivot (0 to 1) for new entities **/
	var defaultPivotX: Float;

	/** Default Y pivot (0 to 1) for new entities **/
	var defaultPivotY: Float;

	/** Default grid size for new layers **/
	var defaultGridSize: Int;

	/** Project background color **/
	@color
	var bgColor: String;

	/** Default background color of levels **/
	@added("0.6.0")
	@color
	var defaultLevelBgColor: String;

	/**
		An enum that describes how levels are organized in this project (ie. linearly or in a 2D space).
	**/
	@added("0.6.0")
	var worldLayout: WorldLayout;

	/** Width of the world grid in pixels. **/
	@only("'GridVania' layouts")
	@added("0.6.0")
	var worldGridWidth: Int;

	/** Height of the world grid in pixels. **/
	@only("'GridVania' layouts")
	@added("0.6.0")
	var worldGridHeight: Int;

	@internal
	var nextUid: Int;

	/** If TRUE, the Json is partially minified (no indentation, nor line breaks, default is FALSE) **/
	var minifyJson: Bool;

	/** If TRUE, one file will be saved the project (incl. all its definitions) and one file per-level in a sub-folder. **/
	var externalLevels: Bool;

	/** If TRUE, a Tiled compatible file will also be generated along with the LDtk JSON file (default is FALSE) **/
	var exportTiled: Bool;

	/** A structure containing all the definitions of this project **/
	var defs: DefinitionsJson;

	/**
		All levels. The order of this array is only relevant in `LinearHorizontal` and `linearVertical` world layouts (see `worldLayout` value). Otherwise, you should refer to the `worldX`,`worldY` coordinates of each Level.
	**/
	var levels: Array<LevelJson>;
}

/**
This section contains all the level data. It can be found in 2 distinct forms, depending on Project current settings:

- If "*Separate level files*" is **disabled** (default): full level data is *embedded* inside the main Project JSON file,
- If "*Separate level files*" is **enabled**: level data is stored in *separate* standalone `.ldtkl` files (one per level). In this case, the main Project JSON file will still contain most level data, except heavy sections, like the `layerInstances` array (which will be null). The `externalRelPath` string points to the `ldtkl` file.

A `ldtkl` file is just a JSON file containing exactly what is described below.
**/
@section("1")
@display("Level")
typedef LevelJson = {

	/** Unique Int identifier **/
	var uid: Int;

	/** Unique String identifier **/
	var identifier: String;

	/** World X coordinate in pixels **/
	@added("0.6.0")
	var worldX: Int;

	/** World Y coordinate in pixels **/
	@added("0.6.0")
	var worldY: Int;

	/** Width of the level in pixels **/
	var pxWid: Int;

	/** Height of the level in pixels **/
	var pxHei: Int;

	/** Background color of the level. If `null`, the project `defaultLevelBgColor` should be used.**/
	@added("0.6.0")
	@color
	var bgColor: Null<String>;

	/** Background color of the level (same as `bgColor`, except the default value is automatically used here if its value is `null`) **/
	@added("0.6.0")
	@color
	var __bgColor: String;

	/**
		An array containing all Layer instances. **IMPORTANT**: if the project option "*Save levels separately*" is enabled, this field will be `null`.
		This array is **sorted in display order**: the 1st layer is the top-most and the last is behind.
	**/
	@changed("0.6.3")
	var layerInstances: Null< Array<LayerInstanceJson> >;

	/**
		This value is not null if the project option "*Save levels separately*" is enabled. In this case, this **relative** path points to the level Json file.
	**/
	@added("0.6.3")
	var externalRelPath: Null<String>;

	/**
		An array listing all other levels touching this one on the world map. The `dir` is a single lowercase character tipping on the level location (`n`orth, `s`outh, `w`est, `e`ast). In "linear" world layouts, this array is populated with previous/next levels in array, and `dir` depends on the linear horizontal/vertical layout.
	**/
	@added("0.6.0")
	var __neighbours: Array<{ levelUid:Int, dir:String }>;
}



@section("1.1")
@display("Layer instance")
typedef LayerInstanceJson = {
	/** Layer definition identifier **/
	var __identifier: String;

	/** Layer type (possible values: IntGrid, Entities, Tiles or AutoLayer) **/
	var __type: String;

	/** Grid-based width **/
	var __cWid: Int;

	/** Grid-based height **/
	var __cHei: Int;

	/** Grid size **/
	var __gridSize: Int;

	/** Layer opacity as Float [0-1] **/
	@added("0.4.0")
	var __opacity: Float;

	/** Total layer X pixel offset, including both instance and definition offsets. **/
	@added("0.5.0")
	var __pxTotalOffsetX: Int;

	/** Total layer Y pixel offset, including both instance and definition offsets. **/
	@added("0.5.0")
	var __pxTotalOffsetY: Int;

	/** The definition UID of corresponding Tileset, if any. **/
	@only("Tile layers, Auto-layers")
	@added("0.6.0")
	var __tilesetDefUid: Null<Int>;

	/** The relative path to corresponding Tileset, if any. **/
	@only("Tile layers, Auto-layers")
	@added("0.6.0")
	var __tilesetRelPath: Null<String>;

	/** Reference to the UID of the level containing this layer instance **/
	var levelId: Int;

	/** Reference the Layer definition UID **/
	var layerDefUid: Int;

	/** X offset in pixels to render this layer, usually 0 (IMPORTANT: this should be added to the `LayerDef` optional offset, see `__pxTotalOffsetX`) **/
	@changed("0.5.0")
	var pxOffsetX: Int;

	/** Y offset in pixels to render this layer, usually 0 (IMPORTANT: this should be added to the `LayerDef` optional offset, see `__pxTotalOffsetY`)**/
	@changed("0.5.0")
	var pxOffsetY: Int;

	/** Random seed used for Auto-Layers rendering **/
	@only("Auto-layers")
	var seed: Int;

	@only("IntGrid layers")
	var intGrid: Array<{
		/** Coordinate ID in the layer grid **/
		var coordId:Int;

		/** IntGrid value **/
		var v:Int;
	}>;

	@only("Tile layers")
	var gridTiles: Array<Tile>;

	/**
		An array containing all tiles generated by Auto-layer rules. The array is already sorted in display order (ie. 1st tile is beneath 2nd, which is beneath 3rd etc.).

		Note: if multiple tiles are stacked in the same cell as the result of different rules, all tiles behind opaque ones will be discarded.
	**/
	@only("Auto-layers")
	@added("0.4.0")
	var autoLayerTiles: Array<Tile>;

	@only("Entity layers")
	var entityInstances: Array<EntityInstanceJson>;
}



@section("1.1.1")
@added("0.4.0")
@display("Tile instance")
typedef Tile = {
	/** Pixel coordinates of the tile in the **layer** (`[x,y]` format). Don't forget optional layer offsets, if they exist! **/
	@changed("0.5.0")
	var px: Array<Int>;

	/** Pixel coordinates of the tile in the **tileset** (`[x,y]` format) **/
	var src: Array<Int>;

	/**
		"Flip bits", a 2-bits integer to represent the mirror transformations of the tile.
		 - Bit 0 = X flip
		 - Bit 1 = Y flip
		 Examples: f=0 (no flip), f=1 (X flip only), f=2 (Y flip only), f=3 (both flips)
	**/
	var f: Int;

	/**
		The *Tile ID* in the corresponding tileset.
	**/
	@added("0.6.0")
	var t: Int;

	/**
		Internal data used by the editor.
		For auto-layer tiles: `[ruleId, coordId]`.
		For tile-layer tiles: `[coordId]`.
	**/
	@internal
	@changed("0.6.0")
	var d: Array<Int>;
}



@section("1.1.2")
@display("Entity instance")
typedef EntityInstanceJson = {
	/** Entity definition identifier **/
	var __identifier: String;

	/** Grid-based coordinates (`[x,y]` format) **/
	@changed("0.4.0")
	var __grid: Array<Int>;

	/** Pivot coordinates  (`[x,y]` format) of the Entity (Float values from 0 to 1) **/
	@added("0.6.3")
	var __pivot: Array<Float>;

	/**
		Optional Tile used to display this entity (it could either be the default Entity tile, or some tile provided by a field value, like an Enum).
	**/
	@added("0.4.0")
	var __tile: Null<{
		/** Tileset ID **/
		var tilesetUid: Int;

		/** An array of 4 Int values that refers to the tile in the tileset image: `[ x, y, width, height ]` **/
		var srcRect: Array<Int>;
	}>;

	/** Reference of the **Entity definition** UID **/
	var defUid: Int;

	/** Pixel coordinates (`[x,y]` format) in current level coordinate space. Don't forget optional layer offsets, if they exist! **/
	@changed("0.4.0")
	var px: Array<Int>;

	var fieldInstances: Array<FieldInstanceJson>;
}



@section("1.1.3")
@display("Field instance")
typedef FieldInstanceJson = {
	/** Field definition identifier **/
	var __identifier: String;

	/**
		Actual value of the field instance. The value type may vary, depending on `__type` (Integer, Boolean, String etc.)
		It can also be an `Array` of those same types.
	**/
	var __value: Dynamic;

	/** Type of the field, such as Int, Float, Enum(enum_name), Bool, etc. **/
	var __type: String;

	/** Reference of the **Field definition** UID **/
	var defUid: Int;

	@internal
	var realEditorValues: Array< Null<Enum<Dynamic>> >;
}



/**
If you're writing your own LDtk importer, you should probably just ignore *most* stuff in the `defs` section, as it contains data that are mostly useful to the editor. To keep you away from the `defs` section and avoid some unnecessary JSON parsing, important data from definitions is often duplicated in fields prefixed with a double underscore (eg. `__identifier` or `__type`).

The 2 only definition types you might need here are **Tilesets** and **Enums**.
**/
@section("2")
@display("Definitions")
typedef DefinitionsJson = {
	var layers : Array<LayerDefJson>;
	var entities : Array<EntityDefJson>;
	var tilesets : Array<TilesetDefJson>;
	var enums : Array<EnumDefJson>;

	/**
		Note: external enums are exactly the same as `enums`, except they have a `relPath` to point to an external source file.
	**/
	var externalEnums : Array<EnumDefJson>;
}



@section("2.1")
@display("Layer definition")
typedef LayerDefJson = {
	/** Unique String identifier **/
	var identifier: String;

	/** Type of the layer (*IntGrid, Entities, Tiles or AutoLayer*) **/
	var __type: String;

	/** Type of the layer as Haxe Enum **/
	@internal
	var type: LayerType;

	/** Unique Int identifier **/
	var uid: Int;

	/** Width and height of the grid in pixels **/
	var gridSize: Int;

	/** X offset of the layer, in pixels (IMPORTANT: this should be added to the `LayerInstance` optional offset) **/
	@added("0.5.0")
	var pxOffsetX: Int;

	/** Y offset of the layer, in pixels (IMPORTANT: this should be added to the `LayerInstance` optional offset) **/
	@added("0.5.0")
	var pxOffsetY: Int;

	/** Opacity of the layer (0 to 1.0) **/
	var displayOpacity: Float;

	@only("IntGrid layer")
	var intGridValues: Array<{
		var identifier:Null<String>;

		@color
		var color:String ;
	}>;

	/** Reference to the Tileset UID being used by this auto-layer rules **/
	@only("Auto-layers")
	var autoTilesetDefUid: Null<Int>;

	/** Contains all the auto-layer rule definitions. **/
	@only("Auto-layers")
	var autoRuleGroups: Array<{
		var uid: Int;
		var name: String;
		var active: Bool;
		var collapsed: Bool;
		var rules: Array<AutoRuleDef>;
	}>;
	@only("Auto-layers")
	var autoSourceLayerDefUid: Null<Int>;

	/** Reference to the Tileset UID being used by this tile layer **/
	@only("Tile layers")
	var tilesetDefUid: Null<Int>;

	/** If the tiles are smaller or larger than the layer grid, the pivot value will be used to position the tile relatively its grid cell. **/
	@only("Tile layers")
	var tilePivotX: Float;

	/** If the tiles are smaller or larger than the layer grid, the pivot value will be used to position the tile relatively its grid cell. **/
	@only("Tile layers")
	var tilePivotY: Float;

}

/**
	This complex section isn't meant to be used by game devs at all, as these rules are completely resolved internally by the editor before any saving. You should just ignore this part.
**/
@section("2.1.1")
@display("Auto-layer rule definition")
typedef AutoRuleDef = {
	/** Unique Int identifier **/
	var uid: Int;

	/** Pattern width & height. Should only be 1,3,5 or 7. **/
	var size: Int;

	/** Rule pattern (size x size) **/
	var pattern: Array<Int>;

	/** Array of all the tile IDs. They are used randomly or as stamps, based on `tileMode` value. **/
	var tileIds: Array<Int>;

	/** If FALSE, the rule effect isn't applied, and no tiles are generated. **/
	var active: Bool;

	/** When TRUE, the rule will prevent other rules to be applied in the same cell if it matches (TRUE by default). **/
	var breakOnMatch: Bool;

	/** Chances for this rule to be applied (0 to 1) **/
	var chance: Float;

	/** Defines how tileIds array is used **/
	var tileMode: AutoLayerRuleTileMode;

	/** If TRUE, allow rule to be matched by flipping its pattern horizontally **/
	var flipX: Bool;

	/** If TRUE, allow rule to be matched by flipping its pattern vertically **/
	var flipY: Bool;

	/** Checker mode **/
	var checker: AutoLayerRuleCheckerMode;

	/** X pivot of a tile stamp (0-1) **/
	@only("'Stamp' tile mode")
	var pivotX: Float;

	/** Y pivot of a tile stamp (0-1) **/
	@only("'Stamp' tile mode")
	var pivotY: Float;

	/** X cell coord modulo **/
	var xModulo: Int;

	/** Y cell coord modulo **/
	var yModulo: Int;

	/** If TRUE, enable Perlin filtering to only apply rule on specific random area **/
	var perlinActive: Bool;

	var perlinScale: Float;

	var perlinOctaves: Float;

	var perlinSeed: Float;
};



@section("2.2")
@display("Entity definition")
typedef EntityDefJson = {
	/** Unique String identifier **/
	var identifier: String;

	/** Unique Int identifier **/
	var uid: Int;

	/** Pixel width **/
	var width: Int;

	/** Pixel height **/
	var height: Int;

	/** Base entity color **/
	@color
	var color: String;

	@internal
	var renderMode: EntityRenderMode;

	/** Display entity name in editor **/
	@internal
	@added("0.4.0")
	var showName: Bool;

	/** Tileset ID used for optional tile display **/
	var tilesetId: Null<Int>;

	/** Tile ID used for optional tile display **/
	var tileId: Null<Int>;

	@internal
	var tileRenderMode: EntityTileRenderMode;

	/** Max instances per level **/
	var maxPerLevel: Int;

	@internal
	var limitBehavior: EntityLimitBehavior;

	/** Pivot X coordinate (from 0 to 1.0) **/
	var pivotX: Float;

	/** Pivot Y coordinate (from 0 to 1.0) **/
	var pivotY: Float;

	/** Array of field definitions **/
	var fieldDefs: Array<FieldDefJson>;
};


/**
	This section is mostly only intended for the LDtk editor app itself. You can safely ignore it.
**/
@added("0.6.0")
@section("2.2.1")
@display("Field definition")
typedef FieldDefJson = {
	/** Unique String identifier **/
	var identifier: String;

	/** Unique Intidentifier **/
	var uid: Int;

	/** Human readable value type (eg. `Int`, `Float`, `Point`, etc.). If the field is an array, this field will look like `Array<...>` (eg. `Array<Int>`, `Array<Point>` etc.) **/
	var __type: String;

	/** Internal type enum **/
	var type: Dynamic;

	/** TRUE if the value is an array of multiple values **/
	var isArray: Bool;

	/** TRUE if the value can be null. For arrays, TRUE means it can contain null values (exception: array of Points can't have null values). **/
	var canBeNull: Bool;

	/** Array min length **/
	@only("Array")
	var arrayMinLength: Null<Int>;

	/** Array max length **/
	@only("Array")
	var arrayMaxLength: Null<Int>;

	/** Min limit for value, if applicable **/
	@only("Int, Float")
	var min: Null<Float>;

	/** Max limit for value, if applicable **/
	@only("Int, Float")
	var max: Null<Float>;

	/** Optional regular expression that needs to be matched to accept values. Expected format: `/some_reg_ex/g`, with optional "i" flag. **/
	@added("0.6.2")
	@only("String")
	var regex: Null<String>;

	/** Optional list of accepted file extensions for FilePath value type. Includes the dot: `.ext`**/
	@only("FilePath")
	var acceptFileTypes: Null< Array<String> >;

	/** Default value if selected value is null or invalid. **/
	var defaultOverride: Null< Enum<Dynamic> >;

	@internal
	var editorDisplayMode: FieldDisplayMode;

	@internal
	var editorDisplayPos: FieldDisplayPosition;

	@internal
	var editorAlwaysShow: Bool;
}


/**
	The `Tileset` definition is the most useful part among project definitions. It contains some extra informations about each integrated tileset. If you only had to parse one definition section, that would be the one.
**/
@section("2.3")
@display("Tileset definition")
typedef TilesetDefJson = {
	/** Unique String identifier **/
	var identifier: String;

	/** Unique Intidentifier **/
	var uid: Int;

	/** Path to the source file, relative to the current project JSON file **/
	var relPath: String;

	/** Image width in pixels **/
	var pxWid: Int;

	/** Image height in pixels **/
	var pxHei: Int;

	var tileGridSize: Int;

	/** Space in pixels between all tiles **/
	var spacing: Int;

	/** Distance in pixels from image borders **/
	var padding: Int;

	/** Array of group of tiles selections, only meant to be used in the editor **/
	@internal
	var savedSelections: Array<{ ids:Array<Int>, mode:Enum<Dynamic> }>;

	/** The following data is used internally for various optimizations. It's always synced with source image changes. **/
	@internal
	@added("0.6.0")
	var cachedPixelData: Null<{
		/** An array of 0/1 bytes, encoded in Base64, that tells if a specific TileID is fully opaque (1) or not (0) **/
		@changed("0.6.0")
		var opaqueTiles: String;

		/** Average color codes for each tileset tile (ARGB format) **/
		@added("0.6.0")
		var averageColors: Null<String>;
	}>;
}



@section("2.4")
@display("Enum definition")
typedef EnumDefJson = {
	/** Unique Int identifier **/
	var uid: Int;

	/** Unique String identifier **/
	var identifier: String;

	/** All possible enum values, with their optional Tile infos. **/
	var values: Array<{
		/** Enum value **/
		var id:String;

		/** The optional ID of the tile **/
		var tileId:Null<Int>;

		/** An array of 4 Int values that refers to the tile in the tileset image: `[ x, y, width, height ]` **/
		@added("0.4.0")
		var __tileSrcRect:Array<Int>;
	}>;

	/** Tileset UID if provided **/
	var iconTilesetUid: Null<Int>;

	/** Relative path to the external file providing this Enum **/
	var externalRelPath: Null<String>;

	@internal
	var externalFileChecksum: Null<String>;
};



// Misc enums

enum WorldLayout {
	Free;
	GridVania;
	LinearHorizontal;
	LinearVertical;
}

enum LayerType {
	IntGrid;
	Entities;
	Tiles;
	AutoLayer;
}

enum AutoLayerRuleTileMode {
	Single;
	Stamp;
}

enum AutoLayerRuleCheckerMode {
	None;
	Horizontal;
	Vertical;
}

enum FieldDisplayPosition {
	Above;
	Center;
	Beneath;
}

enum EntityRenderMode {
	Rectangle;
	Ellipse;
	Tile;
	Cross;
}

enum EntityTileRenderMode {
	Stretch;
	Crop;
}

enum EntityLimitBehavior {
	DiscardOldOnes;
	PreventAdding;
	MoveLastOne;
}

enum FieldDisplayMode {
	Hidden;
	ValueOnly;
	NameAndValue;
	EntityTile;
	PointStar;
	PointPath;
	RadiusPx;
	RadiusGrid;
}
