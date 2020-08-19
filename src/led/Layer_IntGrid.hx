package led;

class Layer_IntGrid extends led.Layer {
	var intGrid : Map<Int,Int> = new Map();

	public function new(json) {
		super(json);
		trace("New Default IntGrid layer");
	}
}
