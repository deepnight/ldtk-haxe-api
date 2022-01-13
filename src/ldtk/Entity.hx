package ldtk;

class Entity {
	var untypedProject : ldtk.Project;

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

	/** Width in pixels **/
	public var width : Int;

	/** Height in pixels**/
	public var height : Int;

	/** Tile infos if the entity has one (it could have be overridden by a Field value, such as Enums) **/
	public var defaultTileInfos : Null<{ tilesetUid:Int, x:Int, y:Int, w:Int, h:Int }>;

	var _fields : Map<String, Dynamic> = new Map();


	public function new(p:ldtk.Project, json:ldtk.Json.EntityInstanceJson) {
		untypedProject = p;
		identifier = json.__identifier;
		iid = json.iid;
		cx = json.__grid[0];
		cy = json.__grid[1];
		pixelX = json.px[0];
		pixelY = json.px[1];
		pivotX = json.__pivot==null ? 0 : json.__pivot[0];
		pivotY = json.__pivot==null ? 0 : json.__pivot[1];
		width = json.width;
		height = json.height;

		defaultTileInfos = json.__tile==null ? null : {
			tilesetUid: json.__tile.tilesetUid,
			x: json.__tile.srcRect[0],
			y: json.__tile.srcRect[1],
			w: json.__tile.srcRect[2],
			h: json.__tile.srcRect[3],
		}

		p._assignFieldInstanceValues(this, json.fieldInstances);
	}

}
