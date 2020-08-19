package led;

class Layer_Entities extends led.Layer {
	var _entities : Array<Entity> = [];

	public function new(json) {
		super(json);

		for(json in json.entityInstances)
			_entities.push( _instanciateEntity(json) );
	}

	function _instanciateEntity(json:led.JsonTypes.EntityInstJson) : Entity {
		return null; // overriden by Macros.hx
	}
}
