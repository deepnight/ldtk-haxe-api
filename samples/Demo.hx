import externEnums.GameEnums;

class Demo {
	static function main() {
		var project = new _Project();

		var myLevel = project.all_levels.MyFirstLevel;

		// IntGrid layer access
		var layer = myLevel.l_IntGridTest;
		for( cy in 0...layer.cHei ) {
			var row = "";
			for( cx in 0...layer.cWid )
				if( layer.hasValue(cx,cy) )
					row+="#";
				else
					row+=".";
			print(row+"  "+cy);
		}

		// Entity access
		for( mobEntity in myLevel.l_EntityTest.all_Mob )
			print(mobEntity.identifier+" => elite="+mobEntity.f_elite);

		// Enums
		for( mobEntity in myLevel.l_EntityTest.all_Mob )
			print(
				mobEntity.identifier+" => loot="+
				switch mobEntity.f_lootDrop {
					case null: "no loot";
					case Food: "some food";
					case Gold: "gold coins";
					case Ammo: "ammunitions";
					case Key: "iron key";
					case MachineGun: "heavy machinegun";
					case LongBow: "elven long bow";
				}
			);
	}


	static function print(msg:String) {
		#if sys
		Sys.println(msg);
		#elseif js
		js.html.Console.info(msg);
		#else
		trace(msg);
		#end
	}
}

