import externEnums.GameEnums;

class Demo {
	static function main() {
		var project = new _Project();

		var myLevel = project.all_levels.LevelTest;

		// IntGrid layer access
		var layer = myLevel.l_IntGridTest;
		for( cy in 0...layer.cHei ) {
			for( cx in 0...layer.cWid )
				if( layer.hasValue(cx,cy) )
					Sys.print("#");
				else
					Sys.print(".");
			Sys.println("");
		}

		// Entity access
		for( mobEntity in myLevel.l_EntityTest.all_Mob )
			Sys.println(mobEntity.identifier+" => elite="+mobEntity.f_elite);

		// Enums
		for( mobEntity in myLevel.l_EntityTest.all_Mob )
			Sys.println(
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
}

