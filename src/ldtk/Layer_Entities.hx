package ldtk;

class Layer_Entities extends ldtk.Layer {
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

	function _instanciateEntity(json:ldtk.Json.EntityInstanceJson) : Entity {
		return null; // overriden by Macros.hx
	}
}
