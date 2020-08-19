package led;

typedef ProjectJson = {
	var name : String;

	var levels : Array<LevelJson>;
	var defs : {
		layers : Array<{ identifier:String }>,
	}
}


typedef LevelJson = {
	var identifier : String;
	var pxWid : Int;
	var pxHei : Int;
	var layerInstances : Array<LayerJson>;
}

typedef LayerJson = {
	var __type : String;
	var __identifier : String;
	var __cWid : Int;
	var __cHei : Int;
	var pxOffsetX : Int;
	var pxOffsetY : Int;
}