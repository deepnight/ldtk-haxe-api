package ldtk;

class Level {
	public var identifier : String;
	public var pxWid : Int;
	public var pxHei : Int;
	public var allUntypedLayers(default,null) : Array<Layer>;

	public function new(json:ldtk.Json.LevelJson) {
		identifier = json.identifier;
		pxWid = json.pxWid;
		pxHei = json.pxHei;
		allUntypedLayers = [];
		for(json in json.layerInstances)
			allUntypedLayers.push( _instanciateLayer(json) );
	}

	function _instanciateLayer(json:ldtk.Json.LayerInstanceJson) : ldtk.Layer {
		return null; // overriden by Macros.hx
	}
}
