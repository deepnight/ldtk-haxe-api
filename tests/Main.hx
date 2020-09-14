import dn.CiAssert;
import externEnums.GameEnums;

class Main {
	static function main() {
		print("Starting tests...");

		// Run tests
		try {
			var project = new CiTestProject();

			CiAssert.isNotNull( project );

			// Levels
			CiAssert.isNotNull( project.all_levels );
			CiAssert.isNotNull( project.all_levels.LevelTest );
			CiAssert.isNotNull( project.resolveLevel("LevelTest") );

			// IntGrid layer
			CiAssert.isNotNull( project.all_levels.LevelTest.l_IntGridTest );
			CiAssert.isTrue( project.all_levels.LevelTest.l_IntGridTest.type==IntGrid );
			CiAssert.isTrue( project.all_levels.LevelTest.l_IntGridTest.getInt(0,0)==0 );
			CiAssert.isTrue( project.all_levels.LevelTest.l_IntGridTest.hasValue(0,0) );
			CiAssert.isTrue( project.all_levels.LevelTest.l_IntGridTest.getName(0,0)=="a" );
			CiAssert.isTrue( project.all_levels.LevelTest.l_IntGridTest.getInt(1,0)==1 );
			CiAssert.isTrue( project.all_levels.LevelTest.l_IntGridTest.getInt(2,0)==2 );
			CiAssert.isFalse( project.all_levels.LevelTest.l_IntGridTest.hasValue(0,1) );
			CiAssert.isTrue( project.all_levels.LevelTest.l_IntGridTest.isCoordValid(0,0) );
			CiAssert.isFalse( project.all_levels.LevelTest.l_IntGridTest.isCoordValid(-1,0) );
			CiAssert.isFalse( project.all_levels.LevelTest.l_IntGridTest.isCoordValid(999,0) );

			// Entity layer
			CiAssert.isNotNull( project.all_levels.LevelTest.l_EntityTest);
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.type==Entities );
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.all_Hero.length!=0 );
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.all_Mob.length!=0 );
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.all_Hero[0].f_startWeapon==LongBow );
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.all_Mob[0].f_type==Trash);
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.all_Mob[0].entityType==Mob);
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.all_Mob[0].f_lootDrop==externEnums.GameEnums.DroppedItemType.Gold );
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.all_Mob[0].f_lootCount>0);

			// Switch check
			switch project.all_levels.LevelTest.l_EntityTest.all_Mob[0].f_lootDrop {
				case null:
				case Food:
				case Gold:
				case Ammo:
				case Key:
				case MachineGun:
				case LongBow:
			}
			switch project.all_levels.LevelTest.l_EntityTest.all_Mob[0].f_type {
				case Trash:
				case Shooter:
				case Shielder:
			}

			// Tile layer
			CiAssert.isNotNull( project.all_levels.LevelTest.l_TileTest );
			CiAssert.isNotNull( project.all_levels.LevelTest.resolveLayer("TileTest") );
			CiAssert.isNotNull( project.all_levels.LevelTest.l_TileTest.tileset );
			CiAssert.isTrue( project.all_levels.LevelTest.l_TileTest.identifier=="TileTest" );
			CiAssert.isTrue( project.all_levels.LevelTest.l_TileTest.type==Tiles );
			CiAssert.isTrue( project.all_levels.LevelTest.l_TileTest.getTileIdAt(0,0)==-1 );
			CiAssert.isTrue( project.all_levels.LevelTest.l_TileTest.getTileIdAt(0,9)!=-1 );
		}
		catch( e:Dynamic ) {
			// Unknown errors
			print("Unknown error: "+e);
			die();
		}

		print("Success.");
	}


	static function die() {
		#if js
		throw new js.lib.Error("Failed");
		#else
		Sys.exit(1);
		#end
	}

	static function print(v:Dynamic) {
		#if js
		js.html.Console.log( Std.string(v) );
		#else
		Sys.println( Std.string(v) );
		#end
	}
}

