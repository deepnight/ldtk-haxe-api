package led;

typedef ProjectJson = {
	var name : String;

	var levels : Array<LevelJson>;
	var defs : {
		layers : Array<LayerDefJson>,
		entities: Array<EntityDefJson>,
		enums: Array<EnumDefJson>,
		externalEnums: Array<EnumDefJson>,
	}
}

typedef LayerDefJson = {
	var identifier : String;
	var type : String;
	var intGridValues : Array<{ identifier:String, color:String }>;
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
	var pxOffsetX : Int;
	var pxOffsetY : Int;

	var intGrid : Array<{ coordId:Int, v:Int }>;
	var entityInstances : Array<EntityInstJson>;
	var gridTiles : Array<{ coordId:Int, v:Int }>;
}

typedef EntityInstJson = {
	var __identifier : String;
	var __cx : Int;
	var __cy : Int;
	var x : Int;
	var y : Int;
	var fieldInstances : Array<{ __identifier:String, __value:Dynamic, __type:String }>;
}