package led;

typedef ProjectJson = {
	var name : String;
	var bgColor : String;

	var levels : Array<LevelJson>;
	var defs : {
		layers : Array<LayerDefJson>,
		entities: Array<EntityDefJson>,
		enums: Array<EnumDefJson>,
		externalEnums: Array<EnumDefJson>,
		tilesets : Array<TilesetDefJson>,
	}
}

typedef LayerDefJson = {
	var identifier : String;
	var type : String;
	var intGridValues : Array<{ identifier:String, color:String }>;
	var autoTilesetDefUid : Null<Int>;
	var tilesetDefUid : Int;
}

typedef EntityDefJson = {
	var identifier : String;
	var fieldDefs : Array<FieldDefJson>;
}

typedef EnumDefJson = {
	var identifier : String;
	var uid : Int;
	var values : Array<{ id:String }>;
	var externalRelPath : Null<String>;
}

typedef FieldDefJson = {
	var identifier : String;
	var __type : String;
	var canBeNull : Bool;
}

typedef TilesetDefJson = {
	var identifier : String;
	var uid : Int;
	var relPath : String;
	var tileGridSize : Int;
	var spacing : Int;
	var padding : Int;

	var pxWid : Int;
	var pxHei : Int;
	var savedSelections : Dynamic;
}


typedef LevelJson = {
	var identifier : String;
	var pxWid : Int;
	var pxHei : Int;
	var layerInstances : Array<LayerInstJson>;
}

typedef LayerInstJson = {
	var __type : String;
	var __identifier : String;
	var __cWid : Int;
	var __cHei : Int;
	var __gridSize : Int;
	var pxOffsetX : Int;
	var pxOffsetY : Int;

	var intGrid : Array<{ coordId:Int, v:Int }>;
	var autoTiles : Array<{
		ruleUid:Int,
		results: Array<{
			coordId:Int,
			tiles:Array<{ tileId:Int, __x:Int, __y:Int }>,
			flips:Int
		}>
	}>;
	var entityInstances : Array<EntityInstJson>;
	var gridTiles : Array<{ coordId:Int, tileId:Int }>;
}

typedef EntityInstJson = {
	var __identifier : String;
	var __cx : Int;
	var __cy : Int;
	var x : Int;
	var y : Int;
	var fieldInstances : Array<{ __identifier:String, __value:Dynamic, __type:String }>;
}