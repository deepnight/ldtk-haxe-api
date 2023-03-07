package ldtk;


/**
	This is the root of any Project JSON file. It contains:

- the project settings,
- an array of levels,
- a group of definitions (that can probably be safely ignored for most users).
**/
@section("1")
@display("LDtk Json root")
typedef ProjectJson = {
	/** File format version **/
	var jsonVersion: String;

	/** Unique project identifier **/
	@added("1.2.0")
	var iid: String;

	/**
		LDtk application build identifier.
		This is only used to identify the LDtk version that generated this particular project file, which can be useful for specific bug fixing. Note that the build identifier is just the date of the release, so it's not unique to each user (one single global ID per LDtk public release), and as a result, completely anonymous.
	**/
	@internal
	@added("1.0.0")
	var appBuildId : Float;


	/**
		**WARNING**: this field will move to the `worlds` array after the "multi-worlds" update. It will then be `null`. You can enable the Multi-worlds advanced project option to enable the change immediately.

		An enum that describes how levels are organized in this project (ie. linearly or in a 2D space).
	**/
	@changed("1.0.0")
	var worldLayout: Null<WorldLayout>;


	/**
		**WARNING**: this field will move to the `worlds` array after the "multi-worlds" update. It will then be `null`. You can enable the Multi-worlds advanced project option to enable the change immediately.

		Width of the world grid in pixels.
	**/
	@only("'GridVania' layouts")
	@changed("1.0.0")
	var worldGridWidth: Null<Int>;


	/**
		**WARNING**: this field will move to the `worlds` array after the "multi-worlds" update. It will then be `null`. You can enable the Multi-worlds advanced project option to enable the change immediately.

		Height of the world grid in pixels.
	**/
	@only("'GridVania' layouts")
	@changed("1.0.0")
	var worldGridHeight: Null<Int>;


	/** Next Unique integer ID available **/
	@internal
	var nextUid: Int;

	/** Naming convention for Identifiers (first-letter uppercase, full uppercase etc.) **/
	@internal
	@added("1.0.0")
	var identifierStyle : IdentifierStyle;

	/** A structure containing all the definitions of this project **/
	var defs: DefinitionsJson;

	/**
		All levels. The order of this array is only relevant in `LinearHorizontal` and `linearVertical` world layouts (see `worldLayout` value).
		Otherwise, you should refer to the `worldX`,`worldY` coordinates of each Level.
	**/
	var levels: Array<LevelJson>;

	/**
This array is not used yet in current LDtk version (so, for now, it's always empty).

In a later update, it will be possible to have multiple Worlds in a single project, each containing multiple Levels.

What will change when "Multiple worlds" support will be added to LDtk:

 - in current version, a LDtk project file can only contain a single world with multiple levels in it. In this case, levels and world layout related settings are stored in the root of the JSON.
 - after the "Multiple worlds" update, there will be a `worlds` array in root, each world containing levels and layout settings. Basically, it's pretty much only about moving the `levels` array to the `worlds` array, along with world layout related values (eg. `worldGridWidth` etc).

If you want to start supporting this future update easily, please refer to this documentation: https://github.com/deepnight/ldtk/issues/231
	**/
	@added("1.0.0")
	var worlds: Array<WorldJson>;

	/**
		If the project isn't in MultiWorlds mode, this is the IID of the internal "dummy" World.
	**/
	@internal
	@added("1.2.6")
	var dummyWorldIid: String;

	/** Default X pivot (0 to 1) for new entities **/
	@internal
	var defaultPivotX: Float;

	/** Default Y pivot (0 to 1) for new entities **/
	@internal
	var defaultPivotY: Float;


	/**
		**WARNING**: this field will move to the `worlds` array after the "multi-worlds" update. It will then be `null`. You can enable the Multi-worlds advanced project option to enable the change immediately.

		Default new level width
	**/
	@changed("1.0.0")
	@internal
	var defaultLevelWidth: Null<Int>;


	/**
		**WARNING**: this field will move to the `worlds` array after the "multi-worlds" update. It will then be `null`. You can enable the Multi-worlds advanced project option to enable the change immediately.

		Default new level height
	**/
	@changed("1.0.0")
	@internal
	var defaultLevelHeight: Null<Int>;


	/** Default grid size for new layers **/
	@internal
	var defaultGridSize: Int;

	/** Project background color **/
	@color
	var bgColor: String;

	/** Default background color of levels **/
	@added("0.6.0")
	@color
	@internal
	var defaultLevelBgColor: String;

	/** If TRUE, the Json is partially minified (no indentation, nor line breaks, default is FALSE) **/
	@internal
	var minifyJson: Bool;

	/** If TRUE, one file will be saved for the project (incl. all its definitions) and one file in a sub-folder for each level. **/
	@added("0.7.0")
	var externalLevels: Bool;

	/** If TRUE, a Tiled compatible file will also be generated along with the LDtk JSON file (default is FALSE) **/
	@internal
	var exportTiled: Bool;

	/** If TRUE, a very simplified will be generated on saving, for quicker & easier engine integration. **/
	@added("1.1.0")
	@internal
	var simplifiedExport: Bool;

	/** TRUE is equivalent to OneImagePerLayer, FALSE is None. **/
	@internal
	@deprecation("0.9.3", "0.9.3", "imageExportMode")
	var ?exportPng: Bool;

	/** "Image export" option when saving project. **/
	@internal
	@added("0.9.3")
	var imageExportMode: ImageExportMode;

	/** If TRUE, the exported PNGs will include the level background (color or image). **/
	@internal
	@added("1.2.0")
	var exportLevelBg: Bool;

	/** File naming pattern for exported PNGs **/
	@internal
	@added("0.7.2")
	var pngFilePattern: Null<String>;

	/** If TRUE, an extra copy of the project will be created in a sub folder, when saving. **/
	@internal
	@added("0.7.0")
	var backupOnSave: Bool;

	/** Number of backup files to keep, if the `backupOnSave` is TRUE **/
	@internal
	@added("0.7.0")
	var backupLimit: Int;

	/** An array containing various advanced flags (ie. options or other states). **/
	@internal
	@added("0.8.0")
	var flags: Array<ProjectFlag>;

	/** The default naming convention for level identifiers. **/
	@internal
	@added("0.9.0")
	var levelNamePattern: String;

	/**
		This optional description is used by LDtk Samples to show up some informations and instructions.
	**/
	@internal
	@added("1.0.0")
	var tutorialDesc: Null<String>;

	/** An array of command lines that can be ran manually by the user **/
	@internal
	@added("1.2.0")
	var customCommands: Array<CustomCommand>;

	/** All instances of entities that have their `exportToToc` flag enabled are listed in this array. **/
	@added("1.2.4")
	var toc: Array<TableOfContentEntry>;
}


/**
**IMPORTANT**: this type is not used *yet* in current LDtk version. It's only presented here as a preview of a planned feature.

A World contains multiple levels, and it has its own layout settings.
**/
@added("1.0.0")
@section("1.1")
@display("World")
typedef WorldJson = {
	/** Unique instance identifer **/
	@added("1.0.0")
	var iid: String;

	/** User defined unique identifier **/
	@added("1.0.0")
	var identifier: String;

	/**
		All levels from this world. The order of this array is only relevant in `LinearHorizontal` and `linearVertical` world layouts (see `worldLayout` value). Otherwise, you should refer to the `worldX`,`worldY` coordinates of each Level.
	**/
	@added("1.0.0")
	var levels: Array<LevelJson>;

	/** Default new level width **/
	@internal
	@added("1.0.0")
	var defaultLevelWidth: Int;

	/** Default new level height **/
	@internal
	@added("1.0.0")
	var defaultLevelHeight: Int;

	/**
		An enum that describes how levels are organized in this project (ie. linearly or in a 2D space).
	**/
	@added("1.0.0")
	var worldLayout: WorldLayout;

	/** Width of the world grid in pixels. **/
	@only("'GridVania' layouts")
	@added("1.0.0")
	var worldGridWidth: Int;

	/** Height of the world grid in pixels. **/
	@only("'GridVania' layouts")
	@added("1.0.0")
	var worldGridHeight: Int;
}


/**
This section contains all the level data. It can be found in 2 distinct forms, depending on Project current settings:

- If "*Separate level files*" is **disabled** (default): full level data is *embedded* inside the main Project JSON file,
- If "*Separate level files*" is **enabled**: level data is stored in *separate* standalone `.ldtkl` files (one per level). In this case, the main Project JSON file will still contain most level data, except heavy sections, like the `layerInstances` array (which will be null). The `externalRelPath` string points to the `ldtkl` file.

A `ldtkl` file is just a JSON file containing exactly what is described below.
**/
@section("2")
@display("Level")
typedef LevelJson = {

	/** Unique Int identifier **/
	var uid: Int;

	/**
		Unique instance identifier
	**/
	@added("1.0.0")
	var iid: String;

	/** User defined unique identifier **/
	var identifier: String;

	/** If TRUE, the level identifier will always automatically use the naming pattern as defined in `Project.levelNamePattern`. Becomes FALSE if the identifier is manually modified by user. **/
	@internal
	@added("0.9.0")
	var useAutoIdentifier: Bool;

	/**
		World X coordinate in pixels.
		Only relevant for world layouts where level spatial positioning is manual (ie. GridVania, Free). For Horizontal and Vertical layouts, the value is always -1 here.
	**/
	@added("0.6.0")
	@changed("1.0.0")
	var worldX: Int;

	/**
		World Y coordinate in pixels.
		Only relevant for world layouts where level spatial positioning is manual (ie. GridVania, Free). For Horizontal and Vertical layouts, the value is always -1 here.
	**/
	@added("0.6.0")
	@changed("1.0.0")
	var worldY: Int;

	/**
		Index that represents the "depth" of the level in the world. Default is 0, greater means "above", lower means "below".
		This value is mostly used for display only and is intended to make stacking of levels easier to manage.
	**/
	@added("1.0.0")
	var worldDepth: Int;

	/** Width of the level in pixels **/
	var pxWid: Int;

	/** Height of the level in pixels **/
	var pxHei: Int;

	/** Background color of the level. If `null`, the project `defaultLevelBgColor` should be used.**/
	@added("0.6.0")
	@color
	@internal
	var bgColor: Null<String>;

	/** Background color of the level (same as `bgColor`, except the default value is automatically used here if its value is `null`) **/
	@added("0.6.0")
	@color
	var __bgColor: String;

	/**
		An array containing all Layer instances. **IMPORTANT**: if the project option "*Save levels separately*" is enabled, this field will be `null`.
		This array is **sorted in display order**: the 1st layer is the top-most and the last is behind.
	**/
	@changed("0.7.0")
	var layerInstances: Null< Array<LayerInstanceJson> >;

	/** An array containing this level custom field values. **/
	@changed("0.8.0")
	var fieldInstances: Array<FieldInstanceJson>;

	/**
		This value is not null if the project option "*Save levels separately*" is enabled. In this case, this **relative** path points to the level Json file.
	**/
	@added("0.7.0")
	var externalRelPath: Null<String>;

	/**
		An array listing all other levels touching this one on the world map.
		Only relevant for world layouts where level spatial positioning is manual (ie. GridVania, Free). For Horizontal and Vertical layouts, this array is always empty.
	**/
	@added("0.6.0")
	@changed("1.0.0")
	var __neighbours: Array<NeighbourLevel>;

	/**
		The *optional* relative path to the level background image.
	**/
	@added("0.7.0")
	var bgRelPath: Null<String>;

	/**
		An enum defining the way the background image (if any) is positioned on the level. See `__bgPos` for resulting position info.
	**/
	@internal
	@added("0.7.0")
	var bgPos: Null<BgImagePos>;

	/**
		Background image X pivot (0-1)
	**/
	@internal
	@added("0.7.0")
	var bgPivotX: Float;

	/**
		Background image Y pivot (0-1)
	**/
	@internal
	@added("0.7.0")
	var bgPivotY: Float;

	/**
		Position informations of the background image, if there is one.
	**/
	@only("If background image exists")
	@added("0.7.0")
	var __bgPos: Null<LevelBgPosInfos>;


	/**
		The "guessed" color for this level in the editor, decided using either the background color or an existing custom field.
	**/
	@internal
	@added("1.0.0")
	@color
	var __smartColor: String;
}



@section("2.1")
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

	/** Unique layer instance identifier **/
	var iid : String;

	/** Reference to the UID of the level containing this layer instance **/
	var levelId: Int;

	/** Reference the Layer definition UID **/
	var layerDefUid: Int;

	/** Layer instance visibility **/
	@added("0.8.0")
	var visible: Bool;

	/** X offset in pixels to render this layer, usually 0 (IMPORTANT: this should be added to the `LayerDef` optional offset, so you should probably prefer using `__pxTotalOffsetX` which contains the total offset value) **/
	@changed("0.5.0")
	var pxOffsetX: Int;

	/** Y offset in pixels to render this layer, usually 0 (IMPORTANT: this should be added to the `LayerDef` optional offset, so you should probably prefer using `__pxTotalOffsetX` which contains the total offset value) **/
	@changed("0.5.0")
	var pxOffsetY: Int;

	/** Random seed used for Auto-Layers rendering **/
	@only("Auto-layers")
	@internal
	var seed: Int;

	/**
		The list of IntGrid values, stored using coordinate ID system (refer to online documentation for more info about "Coordinate IDs")
	**/
	@deprecation("0.8.0", "1.0.0", "intGridCsv")
	@only("IntGrid layers")
	var ?intGrid: Array<IntGridValueInstance>;


	/**
		A list of all values in the IntGrid layer, stored in CSV format (Comma Separated Values).
		Order is from left to right, and top to bottom (ie. first row from left to right, followed by second row, etc).
		`0` means "empty cell" and IntGrid values start at 1.
		The array size is `__cWid` x `__cHei` cells.
	**/
	@only("IntGrid layers")
	@added("0.8.0")
	var intGridCsv: Array<Int>;

	@only("Tile layers")
	var gridTiles: Array<Tile>;

	/** This layer can use another tileset by overriding the tileset UID here. **/
	@only("Tile layers")
	var overrideTilesetUid: Null<Int>;

	/**
		An array containing all tiles generated by Auto-layer rules. The array is already sorted in display order (ie. 1st tile is beneath 2nd, which is beneath 3rd etc.).

		Note: if multiple tiles are stacked in the same cell as the result of different rules, all tiles behind opaque ones will be discarded.
	**/
	@only("Auto-layers")
	@added("0.4.0")
	var autoLayerTiles: Array<Tile>;

	@only("Entity layers")
	var entityInstances: Array<EntityInstanceJson>;


	/** An Array containing the UIDs of optional rules that were enabled in this specific layer instance. **/
	@internal
	@added("0.9.0")
	var optionalRules: Array<Int>;
}



/**
	This structure represents a single tile from a given Tileset.
**/
@section("2.2")
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


/**
	This object represents a custom sub rectangle in a Tileset image.
**/
@display("Tileset rectangle")
@section("3.3.1")
@added("1.0.0")
typedef TilesetRect = {
	/** UID of the tileset **/
	@added("1.0.0")
	var tilesetUid : Int;

	/** X pixels coordinate of the top-left corner in the Tileset image **/
	@added("1.0.0")
	var x : Int;

	/** Y pixels coordinate of the top-left corner in the Tileset image **/
	@added("1.0.0")
	var y : Int;

	/** Width in pixels **/
	@added("1.0.0")
	var w : Int;

	/** Height in pixels **/
	@added("1.0.0")
	var h : Int;
}


@section("2.3")
@display("Entity instance")
typedef EntityInstanceJson = {
	/** Entity definition identifier **/
	var __identifier: String;

	/** Grid-based coordinates (`[x,y]` format) **/
	@changed("0.4.0")
	var __grid: Array<Int>;

	/** Pivot coordinates  (`[x,y]` format, values are from 0 to 1) of the Entity **/
	@added("0.7.0")
	var __pivot: Array<Float>;

	/** Array of tags defined in this Entity definition **/
	@added("1.0.0")
	var __tags: Array<String>;

	/** Entity width in pixels. For non-resizable entities, it will be the same as Entity definition. **/
	@added("0.8.0")
	var width: Int;

	/** Entity height in pixels. For non-resizable entities, it will be the same as Entity definition. **/
	@added("0.8.0")
	var height: Int;

	/**
		Optional TilesetRect used to display this entity (it could either be the default Entity tile, or some tile provided by a field value, like an Enum).
	**/
	@added("0.4.0")
	@changed("1.0.0")
	var __tile: Null<TilesetRect>;

	/**
		The entity "smart" color, guessed from either Entity definition, or one its field instances.
	**/
	@added("1.0.0")
	var __smartColor : String;

	/**
		Unique instance identifier
	**/
	@added("1.0.0")
	var iid : String;

	/** Reference of the **Entity definition** UID **/
	var defUid: Int;

	/** Pixel coordinates (`[x,y]` format) in current level coordinate space. Don't forget optional layer offsets, if they exist! **/
	@changed("0.4.0")
	var px: Array<Int>;

	/** An array of all custom fields and their values. **/
	var fieldInstances: Array<FieldInstanceJson>;
}



@section("2.4")
@display("Field instance")
typedef FieldInstanceJson = {
	/** Field definition identifier **/
	var __identifier: String;

	/**
		Actual value of the field instance. The value type varies, depending on `__type`:
		 - For **classic types** (ie. Integer, Float, Boolean, String, Text and FilePath), you just get the actual value with the expected type.
		 - For **Color**, the value is an hexadecimal string using "#rrggbb" format.
		 - For **Enum**, the value is a String representing the selected enum value.
		 - For **Point**, the value is a [GridPoint](#ldtk-GridPoint) object.
		 - For **Tile**, the value is a [TilesetRect](#ldtk-TilesetRect) object.
		 - For **EntityRef**, the value is an [EntityReferenceInfos](#ldtk-EntityReferenceInfos) object.

		If the field is an array, then this `__value` will also be a JSON array.
	**/
	@types(Int, Float, Bool, String, ldtk.GridPoint, ldtk.TilesetRect, ldtk.EntityReferenceInfos)
	var __value: Dynamic;

	/**
		Type of the field, such as `Int`, `Float`, `String`, `Enum(my_enum_name)`, `Bool`, etc.
		NOTE: if you enable the advanced option **Use Multilines type**, you will have "*Multilines*" instead of "*String*" when relevant.
	**/
	var __type: String;

	/**
		Optional TilesetRect used to display this field (this can be the field own Tile, or some other Tile guessed from the value, like an Enum).
	**/
	@added("1.0.0")
	var __tile: Null<TilesetRect>;

	/**
		Reference of the **Field definition** UID
	**/
	var defUid: Int;

	/**
		Editor internal raw values
	**/
	@internal
	var realEditorValues: Array< Null<Enum<Dynamic>> >;
}



/**
If you're writing your own LDtk importer, you should probably just ignore *most* stuff in the `defs` section, as it contains data that are mostly important to the editor. To keep you away from the `defs` section and avoid some unnecessary JSON parsing, important data from definitions is often duplicated in fields prefixed with a double underscore (eg. `__identifier` or `__type`).

The 2 only definition types you might need here are **Tilesets** and **Enums**.
**/
@section("3")
@display("Definitions")
typedef DefinitionsJson = {
	/** All layer definitions **/
	var layers : Array<LayerDefJson>;

	/** All entities definitions, including their custom fields **/
	var entities : Array<EntityDefJson>;

	/** All tilesets **/
	var tilesets : Array<TilesetDefJson>;

	/** All internal enums **/
	var enums : Array<EnumDefJson>;

	/** All custom fields available to all levels. **/
	@added("0.8.0")
	var levelFields : Array<FieldDefJson>;

	/** Note: external enums are exactly the same as `enums`, except they have a `relPath` to point to an external source file. **/
	var externalEnums : Array<EnumDefJson>;
}



@section("3.1")
@display("Layer definition")
typedef LayerDefJson = {
	/** User defined unique identifier **/
	var identifier: String;

	/** Type of the layer (*IntGrid, Entities, Tiles or AutoLayer*) **/
	var __type: String;

	/** Type of the layer as Haxe Enum **/
	@internal
	var type: LayerType;

	/** Unique Int identifier **/
	var uid: Int;

	/** User defined documentation for this element to provide help/tips to level designers. **/
	@added("1.2.5")
	@internal
	var doc: Null<String>;

	/** Width and height of the grid in pixels **/
	var gridSize: Int;

	/** Width of the optional "guide" grid in pixels **/
	@internal
	@added("1.0.0")
	var guideGridWid: Int;

	/** Height of the optional "guide" grid in pixels **/
	@internal
	@added("1.0.0")
	var guideGridHei: Int;

	/** X offset of the layer, in pixels (IMPORTANT: this should be added to the `LayerInstance` optional offset) **/
	@added("0.5.0")
	var pxOffsetX: Int;

	/** Y offset of the layer, in pixels (IMPORTANT: this should be added to the `LayerInstance` optional offset) **/
	@added("0.5.0")
	var pxOffsetY: Int;

	/**
		Parallax horizontal factor (from -1 to 1, defaults to 0) which affects the scrolling speed of this layer, creating a fake 3D (parallax) effect.
	**/
	@added("1.0.0")
	var parallaxFactorX: Float;

	/**
		Parallax vertical factor (from -1 to 1, defaults to 0) which affects the scrolling speed of this layer, creating a fake 3D (parallax) effect.
	**/
	@added("1.0.0")
	var parallaxFactorY: Float;

	/**
		If true (default), a layer with a parallax factor will also be scaled up/down accordingly.
	**/
	@added("1.0.0")
	var parallaxScaling: Bool;

	/** Opacity of the layer (0 to 1.0) **/
	var displayOpacity: Float;

	/** Alpha of this layer when it is not the active one. **/
	@internal
	@added("1.0.0")
	var inactiveOpacity: Float;

	/** Hide the layer from the list on the side of the editor view. **/
	@internal
	@added("1.0.0")
	var hideInList: Bool;

	@internal
	@added("1.0.0")
	var hideFieldsWhenInactive: Bool;

	/** Allow editor selections when the layer is not currently active. **/
	@internal
	@added("1.1.4")
	var canSelectWhenInactive: Bool;

	/**
		An array that defines extra optional info for each IntGrid value.
		WARNING: the array order is not related to actual IntGrid values! As user can re-order IntGrid values freely, you may value "2" before value "1" in this array.
	**/
	@changed("1.0.0")
	@only("IntGrid layer")
	var intGridValues: Array<IntGridValueDef>;

	/**
		Reference to the Tileset UID being used by this auto-layer rules. WARNING: some layer *instances* might use a different tileset. So most of the time, you should probably use the `__tilesetDefUid` value from layer instances.
	**/
	@deprecation("1.0.0", "1.2.0", "tilesetDefUid")
	@only("Auto-layers")
	var ?autoTilesetDefUid: Null<Int>;

	/** Contains all the auto-layer rule definitions. **/
	@only("Auto-layers")
	@internal
	var autoRuleGroups: Array<AutoLayerRuleGroupJson>;
	@only("Auto-layers")
	var autoSourceLayerDefUid: Null<Int>;

	/** An array of tags to filter Entities that can be added to this layer **/
	@internal
	@added("0.8.0")
	@only("Entity layer")
	var requiredTags: Array<String>;

	/** An array of tags to forbid some Entities in this layer **/
	@internal
	@added("0.8.0")
	@only("Entity layer")
	var excludedTags: Array<String>;

	/**
		Reference to the default Tileset UID being used by this layer definition.
		**WARNING**: some layer *instances* might use a different tileset. So most of the time, you should probably use the `__tilesetDefUid` value found in layer instances.
		Note: since version 1.0.0, the old `autoTilesetDefUid` was removed and merged into this value.
	**/
	@changed("1.0.0")
	@only("Tile layers, Auto-layers")
	var tilesetDefUid: Null<Int>;

	/** If the tiles are smaller or larger than the layer grid, the pivot value will be used to position the tile relatively its grid cell. **/
	@only("Tile layers")
	@internal
	var tilePivotX: Float;

	/** If the tiles are smaller or larger than the layer grid, the pivot value will be used to position the tile relatively its grid cell. **/
	@only("Tile layers")
	@internal
	var tilePivotY: Float;
}

@inline
@display("Auto-layer rule group")
typedef AutoLayerRuleGroupJson = {
	var uid: Int;
	var name: String;
	var active: Bool;
	var rules: Array<AutoRuleDef>;
	@added("0.9.0")
	var isOptional: Bool;

	@removed("1.0.0")
	var ?collapsed: Bool;

	@added("1.1.4")
	var usesWizard: Bool;
}

/**
	This complex section isn't meant to be used by game devs at all, as these rules are completely resolved internally by the editor before any saving. You should just ignore this part.
**/
@internal
@section("3.1.1")
@display("Auto-layer rule definition")
typedef AutoRuleDef = {
	/** Unique Int identifier **/
	var uid: Int;

	/** Pattern width & height. Should only be 1,3,5 or 7. **/
	var size: Int;

	/** Rule pattern (size x size) **/
	var pattern: Array<Int>;

	/** Default IntGrid value when checking cells outside of level bounds **/
	@added("0.9.0")
	var outOfBoundsValue: Null<Int>;

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

	/** X cell start offset **/
	var xOffset: Int;

	/** Y cell start offset **/
	var yOffset: Int;

	/** If TRUE, enable Perlin filtering to only apply rule on specific random area **/
	var perlinActive: Bool;

	var perlinScale: Float;

	var perlinOctaves: Float;

	var perlinSeed: Float;
};



@section("3.2")
@display("Entity definition")
typedef EntityDefJson = {
	/** User defined unique identifier **/
	var identifier: String;

	/** Unique Int identifier **/
	var uid: Int;

	/** User defined documentation for this element to provide help/tips to level designers. **/
	@added("1.2.5")
	@internal
	var doc: Null<String>;

	/** If enabled, all instances of this entity will be listed in the project "Table of content" object. **/
	@internal
	@added("1.2.4")
	var exportToToc: Bool;

	/** An array of strings that classifies this entity **/
	@added("0.8.0")
	@internal
	var tags: Array<String>;

	/** Pixel width **/
	var width: Int;

	/** Pixel height **/
	var height: Int;

	/** If TRUE, the entity instances will be resizable horizontally **/
	@added("0.8.0")
	@internal
	var resizableX: Bool;

	/** If TRUE, the entity instances will be resizable vertically **/
	@added("0.8.0")
	@internal
	var resizableY: Bool;

	/** Only applies to entities resizable on both X/Y. If TRUE, the entity instance width/height will keep the same aspect ratio as the definition. **/
	@added("0.8.0")
	@internal
	var keepAspectRatio: Bool;

	/** Base entity color **/
	@color
	var color: String;

	@internal
	var renderMode: EntityRenderMode;

	@internal
	@added("1.0.0")
	var tileOpacity: Float;

	@internal
	@added("0.8.0")
	var fillOpacity: Float;

	@internal
	@added("0.8.0")
	var lineOpacity: Float;

	@internal
	@added("0.8.0")
	var hollow: Bool;

	/** Display entity name in editor **/
	@internal
	@added("0.4.0")
	var showName: Bool;

	/** Tileset ID used for optional tile display **/
	var tilesetId: Null<Int>;

	/** Tile ID used for optional tile display **/
	@deprecation("1.0.0", "1.2.0", "tileRect")
	var ?tileId: Null<Int>;

	/**
		An object representing a rectangle from an existing Tileset
	**/
	@added("1.0.0")
	var tileRect: Null<TilesetRect>;

	/**
		An enum describing how the the Entity tile is rendered inside the Entity bounds.
	**/
	@changed("0.8.1")
	var tileRenderMode: EntityTileRenderMode;

	/**
		An array of 4 dimensions for the up/right/down/left borders (in this order) when using 9-slice mode for `tileRenderMode`.
		If the tileRenderMode is not NineSlice, then this array is empty.
		See: https://en.wikipedia.org/wiki/9-slice_scaling
	**/
	@added("1.0.0")
	var nineSliceBorders: Array<Int>;

	/** Max instances count **/
	@internal
	@changed("0.8.0")
	var maxCount: Int;

	/** If TRUE, the maxCount is a "per world" limit, if FALSE, it's a "per level". **/
	@internal
	@added("0.8.0")
	var limitScope: EntityLimitScope;

	@internal
	var limitBehavior: EntityLimitBehavior;

	/** Pivot X coordinate (from 0 to 1.0) **/
	var pivotX: Float;

	/** Pivot Y coordinate (from 0 to 1.0) **/
	var pivotY: Float;

	/** Array of field definitions **/
	@internal
	var fieldDefs: Array<FieldDefJson>;
};


/**
	This section is mostly only intended for the LDtk editor app itself. You can safely ignore it.
**/
@internal
@added("0.6.0")
@section("3.2.1")
@display("Field definition")
typedef FieldDefJson = {
	/** User defined unique identifier **//** User defined unique identifier **/
	var identifier: String;

	/** User defined documentation for this field to provide help/tips to level designers about accepted values. **/
	@added("1.2.0")
	var doc: Null<String>;

	/** Unique Int identifier **/
	var uid: Int;

	/**
		Human readable value type. Possible values: `Int, Float, String, Bool, Color, ExternEnum.XXX, LocalEnum.XXX, Point, FilePath`.
		If the field is an array, this field will look like `Array<...>` (eg. `Array<Int>`, `Array<Point>` etc.)
		NOTE: if you enable the advanced option **Use Multilines type**, you will have "*Multilines*" instead of "*String*" when relevant.
	**/
	var __type: String;

	/** Internal enum representing the possible field types. Possible values: @enum{ldtk.FieldType} **/
	@docType(String)
	var type: FieldType;

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

	@changed("1.0.0")
	@internal
	var editorDisplayMode: FieldDisplayMode;

	@added("1.1.4")
	@internal
	var editorLinkStyle: FieldLinkStyle;

	@internal
	var editorDisplayPos: FieldDisplayPosition;

	@internal
	@added("1.1.4")
	var editorShowInWorld: Bool;

	@internal
	var editorAlwaysShow: Bool;

	@internal
	@added("1.0.0")
	var editorTextPrefix: Null<String>;

	@internal
	@added("1.0.0")
	var editorTextSuffix: Null<String>;

	@added("0.8.0")
	@internal
	var editorCutLongValues: Bool;

	@internal
	@changed("0.9.3")
	var textLanguageMode: Null<TextLanguageMode>;

	@internal
	@added("1.0.0")
	var symmetricalRef: Bool;

	@internal
	@added("1.0.0")
	var autoChainRef: Bool;

	@internal
	@added("1.0.0")
	var allowOutOfLevelRef: Bool;

	@internal
	@added("1.0.0")
	var allowedRefs: EntityReferenceTarget;

	@internal
	@added("1.0.0")
	var allowedRefTags: Array<String>;

	/**
		UID of the tileset used for a Tile
	**/
	@only("Tile")
	@internal
	@added("1.0.0")
	var tilesetUid: Null<Int>;


	/** If TRUE, the color associated with this field will override the Entity or Level default color in the editor UI. For Enum fields, this would be the color associated to their values. **/
	@internal
	@added("1.0.0")
	var useForSmartColor: Bool;
}


/**
	The `Tileset` definition is the most important part among project definitions. It contains some extra informations about each integrated tileset. If you only had to parse one definition section, that would be the one.
**/
@section("3.3")
@display("Tileset definition")
typedef TilesetDefJson = {
	/** Grid-based width **/
	@added("0.9.0")
	var __cWid : Int;

	/** Grid-based height **/
	@added("0.9.0")
	var __cHei : Int;

	/** User defined unique identifier **/
	var identifier: String;

	/** Unique Intidentifier **/
	var uid: Int;

	/**
		If this value is set, then it means that this atlas uses an internal LDtk atlas image instead of a loaded one.
	**/
	@added("1.0.0")
	var embedAtlas : Null<EmbedAtlas>;

	/**
		Path to the source file, relative to the current project JSON file
		It can be null if no image was provided, or when using an embed atlas.
	**/
	var relPath: Null<String>;

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

	/** Optional Enum definition UID used for this tileset meta-data **/
	@added("0.9.0")
	var tagsSourceEnumUid: Null<Int>;

	/** Tileset tags using Enum values specified by `tagsSourceEnumId`. This array contains 1 element per Enum value, which contains an array of all Tile IDs that are tagged with it. **/
	@added("0.9.0")
	var enumTags: Array<EnumTagValue>;

	/** An array of custom tile metadata **/
	@added("0.9.0")
	var customData : Array<TileCustomMetadata>;

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

	/** An array of user-defined tags to organize the Tilesets **/
	@added("1.0.0")
	var tags: Array<String>;
}



@section("3.4")
@display("Enum definition")
typedef EnumDefJson = {
	/** Unique Int identifier **/
	var uid: Int;

	/** User defined unique identifier **/
	var identifier: String;

	/** All possible enum values, with their optional Tile infos. **/
	var values: Array<EnumDefValues>;

	/** Tileset UID if provided **/
	var iconTilesetUid: Null<Int>;

	/** Relative path to the external file providing this Enum **/
	var externalRelPath: Null<String>;

	@internal
	var externalFileChecksum: Null<String>;

	/** An array of user-defined tags to organize the Enums **/
	@added("1.0.0")
	var tags: Array<String>;
};

@section("3.4.1")
@display("Enum value definition")
typedef EnumDefValues = {
	/** Enum value **/
	var id:String;

	/** The optional ID of the tile **/
	var tileId:Null<Int>;

	/** Optional color **/
	@added("0.9.0")
	var color:Int;

	/** An array of 4 Int values that refers to the tile in the tileset image: `[ x, y, width, height ]` **/
	@added("0.4.0")
	var __tileSrcRect:Null< Array<Int> >; // TODO use a Tile instance here?
}



/* INLINED TYPES *****************************************************************************/

/** Nearby level info **/
@inline
@display("Neighbour level")
typedef NeighbourLevel = {
	/** Neighbour Instance Identifier **/
	@added("1.0.0")
	var levelIid : String;

	@deprecation("1.0.0", "1.2.0", "levelIid")
	var ?levelUid: Int;

	/** A single lowercase character tipping on the level location (`n`orth, `s`outh, `w`est, `e`ast). **/
	var dir: String;
}

/** Level background image position info **/
@inline
@display("Level background position")
typedef LevelBgPosInfos = {
	/** An array containing the `[x,y]` pixel coordinates of the top-left corner of the **cropped** background image, depending on `bgPos` option. **/
	var topLeftPx: Array<Int>;

	/** An array containing the `[scaleX,scaleY]` values of the **cropped** background image, depending on `bgPos` option. **/
	var scale: Array<Float>;

	/** An array of 4 float values describing the cropped sub-rectangle of the displayed background image. This cropping happens when original is larger than the level bounds. Array format: `[ cropX, cropY, cropWidth, cropHeight ]`**/
	var cropRect: Array<Float>;
}

/** IntGrid value instance **/
@inline
@display("IntGrid value instance")
typedef IntGridValueInstance = {
	/** Coordinate ID in the layer grid **/
	var coordId:Int;

	/** IntGrid value **/
	var v:Int;
}

/** IntGrid value definition **/
@inline
@display("IntGrid value definition")
typedef IntGridValueDef = {
	/**
		The IntGrid value itself
	**/
	@added("0.8.0")
	var value: Int;

	/** User defined unique identifier **/
	var identifier:Null<String>;

	@color
	var color:String ;
}

/** In a tileset definition, enum based tag infos **/
@inline
@added("1.0.0")
@display("Enum tag value")
typedef EnumTagValue = {
	var enumValueId: String;
	var tileIds: Array<Int>;
}

/** In a tileset definition, user defined meta-data of a tile. **/
@inline
@added("1.0.0")
@display("Tile custom metadata")
typedef TileCustomMetadata = {
	var tileId:Int;
	var data:String;
}

/** This object describes the "location" of an Entity instance in the project worlds. **/
@section("2.4.2")
@added("1.0.0")
@display("Reference to an Entity instance")
typedef EntityReferenceInfos = {
	/** IID of the refered EntityInstance **/
	@added("1.0.0")
	var entityIid : String;

	/** IID of the LayerInstance containing the refered EntityInstance **/
	@added("1.0.0")
	var layerIid : String;

	/** IID of the Level containing the refered EntityInstance **/
	@added("1.0.0")
	var levelIid : String;

	/** IID of the World containing the refered EntityInstance **/
	@added("1.0.0")
	var worldIid : String;
}

/**
	This object is just a grid-based coordinate used in Field values.
**/
@section("2.4.3")
@added("1.0.0")
@display("Grid point")
typedef GridPoint = {
	/** X grid-based coordinate **/
	@added("1.0.0")
	var cx: Int;

	/** Y grid-based coordinate **/
	@added("1.0.0")
	var cy: Int;
}


@added("1.2.0")
@inline
typedef CustomCommand = {
	var command: String;
	var when: CustomCommandTrigger;
}


@added("1.2.4")
@inline
typedef TableOfContentEntry = {
	var identifier: String;
	var instances: Array<EntityReferenceInfos>;
}




/* MISC ENUMS *****************************************************************************/

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

enum FieldType {
	F_Int;
	F_Float;
	F_String;
	F_Text;
	F_Bool;
	F_Color;
	F_Enum(enumDefUid:Int);
	F_Point;
	F_Path;

	@added("1.0.0")
	F_EntityRef;

	@added("1.0.0")
	F_Tile;
}


enum EntityRenderMode {
	Rectangle;
	Ellipse;
	Tile;
	Cross;
}

enum EntityTileRenderMode {
	Cover;
	FitInside;
	Repeat;
	Stretch;
	FullSizeCropped;
	FullSizeUncropped;
	NineSlice;
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
	Points;
	PointStar;
	PointPath;
	PointPathLoop;
	RadiusPx;
	RadiusGrid;
	ArrayCountWithLabel;
	ArrayCountNoLabel;
	RefLinkBetweenPivots;
	RefLinkBetweenCenters;
}

@:added("1.1.4")
enum FieldLinkStyle {
	ZigZag;
	StraightArrow;
	CurvedArrow;
	ArrowsLine;
	DashedLine;
}

enum BgImagePos {
	Unscaled;
	Contain;
	Cover;
	CoverDirty;
	Repeat;
}

enum TextLanguageMode {
	LangPython;
	LangRuby;
	LangJS;
	LangLua;
	LangC;
	LangHaxe;

	LangMarkdown;
	LangJson;
	LangXml;

	LangLog;
}

enum ProjectFlag {
	DiscardPreCsvIntGrid; // backward compatibility
	ExportPreCsvIntGridFormat;
	IgnoreBackupSuggest;
	PrependIndexToLevelFileNames;
	MultiWorlds;
	UseMultilinesType;
}

enum EntityLimitScope {
	PerLayer;
	PerLevel;
	PerWorld;
}

@changed("1.1.0")
enum ImageExportMode {
	None;
	OneImagePerLayer;
	OneImagePerLevel;
	LayersAndLevels;
}

@added("1.0.0")
enum EntityReferenceTarget {
	Any;
	OnlySame;
	OnlyTags;
}

@added("1.0.0")
enum IdentifierStyle {
	Capitalize;
	Uppercase;
	Lowercase;
	Free;
}

enum EmbedAtlas {
	LdtkIcons;
}

@added("1.2.0")
enum CustomCommandTrigger {
	Manual;
	AfterLoad;
	BeforeSave;
	AfterSave;
}
