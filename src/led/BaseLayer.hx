package led;

import led.ApiTypes;

class BaseLayer {
	public var identifier : String;
	public var type : String; // TODO enum?
	public var cWid : Int;
	public var cHei : Int;
	public var pxOffsetX: Int;
	public var pxOffsetY : Int;

	public function new(json:LayerJson) {
		identifier = json.__identifier;
		type = json.__type;
		cWid = json.__cWid;
		cHei = json.__cHei;
		pxOffsetX = json.pxOffsetX;
		pxOffsetY = json.pxOffsetY;
		trace(this);
	}
}
