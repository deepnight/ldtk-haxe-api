import dn.CiAssert;
import externEnums.GameEnums;

class Main {
	static function main() {
		print("Running tests...");

		// Run tests
		var project = new ProjectNoPackage();

		try {
			section("Project (no package)...");
			CiAssert.isNotNull( project );

			// Levels
			section("Levels...");
			CiAssert.isNotNull( project.all_levels );
			CiAssert.isNotNull( project.all_levels.LevelTest );
			CiAssert.isNotNull( project.resolveLevel("LevelTest") );
			CiAssert.isTrue( project.levels.length>0 );
			CiAssert.isNotNull( project.levels[0].l_IntGridTest );

			// IntGrid layer
			section("IntGrid...");
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
			section("Entity...");
			CiAssert.isNotNull( project.all_levels.LevelTest.l_EntityTest);
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.type==Entities );
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.all_Hero.length!=0 );
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.all_Mob.length!=0 );

			// Enums
			section("Enums...");
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.all_Hero[0].f_startWeapon==LongBow );
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.all_Mob[0].f_type==Trash);
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.all_Mob[0].entityType==Mob);
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.all_Mob[0].f_lootDrop==externEnums.GameEnums.DroppedItemType.Gold );
			CiAssert.isTrue( project.all_levels.LevelTest.l_EntityTest.all_Mob[0].f_lootCount>0);

			// Switch check
			section("Switch...");
			CiAssert.isTrue( switch project.all_levels.LevelTest.l_EntityTest.all_Mob[0].f_lootDrop {
				case null: false;
				case Food: false;
				case Gold: true;
				case Ammo: false;
				case Key: false;
				case MachineGun: false;
				case LongBow: false;
			});
			switch project.all_levels.LevelTest.l_EntityTest.all_Mob[0].f_type {
				case Trash:
				case Shooter:
				case Shielder:
			}

			// Tile layer
			section("Tile layer...");
			CiAssert.isNotNull( project.all_levels.LevelTest.l_TileTest );
			CiAssert.isNotNull( project.all_levels.LevelTest.resolveLayer("TileTest") );
			CiAssert.isTrue( project.all_levels.LevelTest.l_TileTest.identifier=="TileTest" );
			CiAssert.isTrue( project.all_levels.LevelTest.l_TileTest.type==Tiles );
			CiAssert.isTrue( project.all_levels.LevelTest.l_TileTest.getTileIdAt(0,0)==-1 );
			CiAssert.isTrue( project.all_levels.LevelTest.l_TileTest.getTileIdAt(0,9)!=-1 );

			// Tileset
			section("Tileset...");
			CiAssert.isNotNull( project.all_levels.LevelTest.l_TileTest.tileset );
			CiAssert.isNotNull( project.all_levels.LevelTest.l_TileTest.tileset.loadAtlasBytes(project) );
			CiAssert.isTrue( project.all_levels.LevelTest.l_TileTest.tileset.loadAtlasBytes(project).length>0 );
			var gridSize = project.all_levels.LevelTest.l_TileTest.tileset.tileGridSize;
			CiAssert.isTrue( project.all_levels.LevelTest.l_TileTest.tileset.getAtlasX(1)==gridSize );
			CiAssert.isTrue( project.all_levels.LevelTest.l_TileTest.tileset.getAtlasY(1)==0 );

			// Auto-layer
			section("Auto-Layer...");
			CiAssert.isNotNull( project.all_levels.LevelTest.l_AutoLayerTest );
			CiAssert.isNotNull( project.all_levels.LevelTest.l_AutoLayerTest.tileset );
			CiAssert.isNotNull( project.all_levels.LevelTest.l_AutoLayerTest.tileset.loadAtlasBytes(project) );
			CiAssert.isTrue( project.all_levels.LevelTest.l_AutoLayerTest.tileset.loadAtlasBytes(project).length>0 );
			CiAssert.isNotNull( project.all_levels.LevelTest.l_AutoLayerTest.getAutoTiles(1,1) );
			CiAssert.isTrue( project.all_levels.LevelTest.l_AutoLayerTest.hasAutoTiles(1,1) );
			CiAssert.isTrue( project.all_levels.LevelTest.l_AutoLayerTest.getAutoTiles(1,1).length>1 );

			// Project in a package
			section("Project (with package)...");

			var project = new packageTest.ProjectPackage();
			CiAssert.isNotNull( project );
			CiAssert.isNotNull( packageTest.ProjectPackage.Enum_Mobs );
			CiAssert.isNotNull( packageTest.ProjectPackage.EntityEnum );
			CiAssert.isNotNull( packageTest.ProjectPackage.Tileset_Cavernas_by_Adam_Saltsman );

		}
		catch( e:Dynamic ) {
			// Unknown errors
			print("Unknown error: "+e);
			die();
		}

		print("");
		print("Success.");
	}


	static function die() {
		#if js
		throw new js.lib.Error("Failed");
		#else
		Sys.exit(1);
		#end
	}

	static inline function section(v:String) {
		print("");
		print(v);
	}

	static function print(v:Dynamic) {
		#if js
		js.html.Console.log( Std.string(v) );
		#else
		Sys.println( Std.string(v) );
		#end
	}
}

