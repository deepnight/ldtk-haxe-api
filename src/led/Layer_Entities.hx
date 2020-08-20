package led;

class Layer_Entities extends led.Layer {
	var _entities : Array<Entity> = [];

	public function new(json) {
		super(json);

		for(json in json.entityInstances) {
			var e = _instanciateEntity(json);
			_entities.push(e);

			if( Reflect.field(this, "all_"+e.identifier)==null )
				Reflect.setField(this, "all_"+e.identifier, []);

			var arr : Array<Entity> = Reflect.field(this, "all_"+e.identifier);
			arr.push(e);
		}
	}

	function _instanciateEntity(json:led.JsonTypes.EntityInstJson) : Entity {
		return null; // overriden by Macros.hx
	}
}
