import dn.CiAssert;
import externEnums.GameEnums;

class Main {
	static function main() {
		print("Running tests...");

		// Run tests
		var project = new ProjectNoPackage();

		try {
			section("PROJECT (NO PACKAGE)...");

			section("Project...");
			CiAssert.isNotNull( project );

			// Types
			section("Types...");
			CiAssert.isNotNull( ProjectNoPackage.Enum_Mobs );
			CiAssert.isNotNull( ProjectNoPackage.EntityEnum );
			CiAssert.isNotNull( ProjectNoPackage.Tileset_Cavernas_by_Adam_Saltsman );

			// Levels
			section("Levels...");
			CiAssert.isNotNull( project.all_levels );
			CiAssert.isNotNull( project.all_levels.MyFirstLevel );
			CiAssert.isNotNull( project.resolveLevel("MyFirstLevel") );
			CiAssert.isTrue( project.levels.length>0 );
			CiAssert.isNotNull( project.levels[0].l_IntGridTest );

			// IntGrid layer
			section("IntGrid...");
			CiAssert.isNotNull( project.all_levels.MyFirstLevel.l_IntGridTest );
			CiAssert.equals( project.all_levels.MyFirstLevel.l_IntGridTest.type, led.Layer.LayerType.IntGrid );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_IntGridTest.type==IntGrid );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_IntGridTest.getInt(0,0)==0 );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_IntGridTest.hasValue(0,0) );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_IntGridTest.getName(0,0)=="a" );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_IntGridTest.getInt(1,0)==1 );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_IntGridTest.getInt(2,0)==2 );
			CiAssert.isFalse( project.all_levels.MyFirstLevel.l_IntGridTest.hasValue(0,1) );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_IntGridTest.isCoordValid(0,0) );
			CiAssert.isFalse( project.all_levels.MyFirstLevel.l_IntGridTest.isCoordValid(-1,0) );
			CiAssert.isFalse( project.all_levels.MyFirstLevel.l_IntGridTest.isCoordValid(999,0) );

			// Entity layer
			section("Entity...");
			CiAssert.isNotNull( project.all_levels.MyFirstLevel.l_EntityTest);
			CiAssert.equals( project.all_levels.MyFirstLevel.l_EntityTest.type, led.Layer.LayerType.Entities );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_EntityTest.type==Entities );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_EntityTest.all_Hero.length!=0 );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_EntityTest.all_Mob.length!=0 );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_EntityTest.all_Test.length!=0 );

			// Entities
			var hero = project.all_levels.MyFirstLevel.l_EntityTest.all_Hero[0];
			var mob = project.all_levels.MyFirstLevel.l_EntityTest.all_Mob[0];
			var test = project.all_levels.MyFirstLevel.l_EntityTest.all_Test[0];
			CiAssert.isNotNull( hero );
			CiAssert.isNotNull( mob );
			CiAssert.isNotNull( test );
			CiAssert.isTrue( mob.f_scale==0.5 );

			// Enums
			section("Enums...");
			CiAssert.isTrue( hero.f_startWeapon==LongBow );
			CiAssert.isTrue( mob.f_type==Trash );
			CiAssert.isTrue( mob.entityType==Mob );
			CiAssert.isTrue( mob.f_lootDrop==externEnums.GameEnums.DroppedItemType.Gold );

			// Arrays
			CiAssert.isNotNull( test.f_ints );
			CiAssert.isTrue( test.f_ints.length==3 );
			CiAssert.isTrue( test.f_ints[0]==0 );
			CiAssert.isTrue( test.f_ints[1]==1 );
			CiAssert.isTrue( test.f_ints[2]==2 );
			CiAssert.isTrue( test.f_strings[0]=="a" );
			CiAssert.isTrue( test.f_floats[1]==0.5 );
			CiAssert.isTrue( test.f_bools[0]==false );
			CiAssert.isTrue( test.f_bools[2]==true );
			CiAssert.isTrue( test.f_colors_hex[0]=="#FF0000" );
			CiAssert.isTrue( test.f_colors_int[0]==0xff0000 );
			CiAssert.isTrue( test.f_localEnums.length>0 );
			CiAssert.isTrue( test.f_localEnums[0]==FireBall );
			CiAssert.isTrue( test.f_externEnums.length>0 );
			CiAssert.isTrue( test.f_externEnums[0]==Gold );

			// Points / paths
			section("Points/paths...");
			CiAssert.isTrue( test.f_point.cx==19 );
			CiAssert.isTrue( mob.f_path!=null );
			CiAssert.isTrue( mob.f_path.length>0 );
			CiAssert.isTrue( mob.f_path[0].cy == mob.cy );

			// Switch check
			section("Switch...");
			CiAssert.isTrue( switch project.all_levels.MyFirstLevel.l_EntityTest.all_Mob[0].f_lootDrop {
				case null: false;
				case Food: false;
				case Gold: true;
				case Ammo: false;
				case Key: false;
				case MachineGun: false;
				case LongBow: false;
			});
			switch project.all_levels.MyFirstLevel.l_EntityTest.all_Mob[0].f_type {
				case Trash:
				case Shooter:
				case Shielder:
			}

			// Tile layer
			section("Tile layer...");
			CiAssert.isNotNull( project.all_levels.MyFirstLevel.l_TileTest );
			CiAssert.equals( project.all_levels.MyFirstLevel.l_TileTest.type, led.Layer.LayerType.Tiles );
			CiAssert.isNotNull( project.all_levels.MyFirstLevel.resolveLayer("TileTest") );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_TileTest.identifier=="TileTest" );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_TileTest.type==Tiles );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_TileTest.getTileIdAt(0,0)==-1 );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_TileTest.getTileIdAt(0,9)!=-1 );

			// Tileset
			section("Tileset...");
			CiAssert.isNotNull( project.all_levels.MyFirstLevel.l_TileTest.tileset );
			#if !js
			CiAssert.isNotNull( project.all_levels.MyFirstLevel.l_TileTest.tileset.loadAtlasBytes(project) );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_TileTest.tileset.loadAtlasBytes(project).length>0 );
			#end
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_TileTest.getTileIdAt(1,4)>=0 );
			var gridSize = project.all_levels.MyFirstLevel.l_TileTest.tileset.tileGridSize;
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_TileTest.tileset.getAtlasX(1)==gridSize );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_TileTest.tileset.getAtlasY(1)==0 );

			// Auto-layer (IntGrid)
			section("Auto-Layer (IntGrid)...");
			CiAssert.isNotNull( project.all_levels.MyFirstLevel.l_IntGrid_AutoLayer );
			CiAssert.isNotNull( project.all_levels.MyFirstLevel.l_IntGrid_AutoLayer.tileset );
			#if !js
			CiAssert.isNotNull( project.all_levels.MyFirstLevel.l_IntGrid_AutoLayer.tileset.loadAtlasBytes(project) );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_IntGrid_AutoLayer.tileset.loadAtlasBytes(project).length>0 );
			#end
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_IntGrid_AutoLayer.autoTiles.length>100 );
			CiAssert.isNotNull( project.all_levels.MyFirstLevel.l_IntGrid_AutoLayer.autoTiles[0] );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_IntGrid_AutoLayer.autoTiles[0].renderX!=0 );

			// Auto-layer (pure)
			section("Auto-Layer (pure)...");
			CiAssert.isNotNull( project.all_levels.MyFirstLevel.l_Pure_AutoLayer);
			CiAssert.equals( project.all_levels.MyFirstLevel.l_Pure_AutoLayer.type, led.Layer.LayerType.IntGrid );
			CiAssert.isNotNull( project.all_levels.MyFirstLevel.l_Pure_AutoLayer.tileset );
			#if !js
			CiAssert.isNotNull( project.all_levels.MyFirstLevel.l_Pure_AutoLayer.tileset.loadAtlasBytes(project) );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_Pure_AutoLayer.tileset.loadAtlasBytes(project).length>0 );
			#end

			// Project in a package
			section("PROJECT (WITH PACKAGE)...");

			var project = new packageTest.ProjectPackage();
			CiAssert.isNotNull( project );
			CiAssert.isNotNull( packageTest.ProjectPackage.Enum_Mobs );
			CiAssert.isNotNull( packageTest.ProjectPackage.EntityEnum );
			CiAssert.isNotNull( packageTest.ProjectPackage.Enum_Weapons );
			CiAssert.isNotNull( packageTest.ProjectPackage.Tileset_Cavernas_by_Adam_Saltsman );
			CiAssert.isNotNull( project.all_levels );
			CiAssert.isNotNull( project.all_levels.MyFirstLevel );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_EntityTest.all_Mob.length>0 );
			CiAssert.isNotNull( project.all_levels.MyFirstLevel.l_EntityTest.all_Mob[0].f_lootDrop );
			CiAssert.isTrue( project.all_levels.MyFirstLevel.l_EntityTest.all_Hero[0].f_startWeapon == packageTest.ProjectPackage.Enum_Weapons.LongBow );

		}
		catch( e:Dynamic ) {
			// Unknown errors
			section("Exception: "+e);
			print("");
			die();
			return;
		}

		print("");
		print("Success.");
	}


	static function die() {
		#if hxnodejs
			js.node.Require.require("process").exit(1);
		#elseif js
			// unsupported
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

