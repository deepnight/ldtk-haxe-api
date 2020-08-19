package led;

import led.ApiTypes;

class Level {
	public var identifier : String;
	public var pxWid : Int;
	public var pxHei : Int;
	var _layers : Array<BaseLayer>;

	public function new(json:LevelJson) {
		identifier = json.identifier;
		pxWid = json.pxWid;
		pxHei = json.pxHei;
		_layers = [];
		for(json in json.layerInstances)
			switch json.__type {
				case "IntGrid": _layers.push( new led.BaseLayer(json) );
				case _ : trace("WARNING: unsupported layer type "+json.__type+". Please update the Led API.");
				// case _ : throw "Unsupported layer type "+json.__type+". Please update the Led API.";
			}
	}
}
