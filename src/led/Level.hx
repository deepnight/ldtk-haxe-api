package led;

class Level {
	public var identifier : String;
	public var pxWid : Int;
	public var pxHei : Int;
	public var allUntypedLayers(default,null) : Array<Layer>;

	public function new(json:led.Json.LevelJson) {
		identifier = json.identifier;
		pxWid = json.pxWid;
		pxHei = json.pxHei;
		allUntypedLayers = [];
		for(json in json.layerInstances)
			allUntypedLayers.push( _instanciateLayer(json) );
	}

	function _instanciateLayer(json:led.Json.LayerInstanceJson) : led.Layer {
		return null; // overriden by Macros.hx
	}
}
