package ldtk;

class Entity {
	var untypedProject : ldtk.Project;

	/** Original JSON object **/
	public var json(default,null) : ldtk.Json.EntityInstanceJson;

	/** Original entity definition JSON object **/
	public var defJson(default,null) : ldtk.Json.EntityDefJson;

	public var identifier : String;

	/** Unique instance identifier **/
	public var iid : String;

	/** Grid-based X coordinate **/
	public var cx : Int;

	/** Grid-based Y coordinate **/
	public var cy : Int;

	/** Pixel-based X coordinate **/
	public var pixelX : Int;

	/** Pixel-based Y coordinate **/
	public var pixelY : Int;

	/** Pivot X coord (0-1) **/
	public var pivotX : Float;

	/** Pivot Y coord (0-1) **/
	public var pivotY : Float;

	/** Pixel-based X world coordinate **/
	public var worldPixelX : Int;

	/** Pixel-based Y world coordinate **/
	public var worldPixelY : Int;

	/** Width in pixels **/
	public var width : Int;

	/** Height in pixels**/
	public var height : Int;

	/** Tile infos if the entity has one (it could have be overridden by a Field value, such as Enums) **/
	public var tileInfos : Null<ldtk.Json.TilesetRect>;

	var _fields : Map<String, Dynamic> = new Map();


	public function new(p:ldtk.Project, json:ldtk.Json.EntityInstanceJson) {
		untypedProject = p;
		this.json = json;
		this.defJson = p.getEntityDefJson(json.defUid);
		identifier = json.__identifier;
		iid = json.iid;
		cx = json.__grid[0];
		cy = json.__grid[1];
		pixelX = json.px[0];
		pixelY = json.px[1];
		pivotX = json.__pivot==null ? 0 : json.__pivot[0];
		pivotY = json.__pivot==null ? 0 : json.__pivot[1];
		worldPixelX = json.__worldX;
		worldPixelY = json.__worldY;
		width = json.width;
		height = json.height;

		tileInfos = json.__tile;

		p._assignFieldInstanceValues(this, json.fieldInstances);
	}


	#if heaps
	public function getTile() : Null<h2d.Tile> {
		if( tileInfos==null )
			return null;

		var tileset = untypedProject._untypedTilesets.get(tileInfos.tilesetUid);
		if( tileset==null )
			return null;

		return tileset.getFreeTile(tileInfos.x, tileInfos.y, tileInfos.w, tileInfos.h);
	}
	#end

}
