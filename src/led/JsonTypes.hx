package led;

typedef ProjectJson = {
	var name : String;

	var levels : Array<LevelJson>;
	var defs : {
		layers : Array<LayerDefJson>,
	}
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
}

typedef LayerDefJson = {
	var identifier : String;
	var type : String;
}
