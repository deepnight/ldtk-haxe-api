import dn.CiAssert;
import ExternEnumTest;
import ExternCastleDbTest;
import ProjectNoPackage;

class Tests {

	static function exit(code=0) {
		#if hxnodejs
			js.node.Require.require("process").exit(code);
		#elseif js
			// unsupported
		#else
			Sys.exit(code);
		#end
	}

	static inline function section(v:String) {
		if( CiAssert.VERBOSE ) {
			print("");
			print(v);
		}
	}

	static function print(v:Dynamic) {
		#if js
			js.html.Console.log( Std.string(v) );
		#else
			Sys.println( Std.string(v) );
		#end
	}


	static function main() {
		// Init
		#if hl
			hxd.Res.initLocal();
		#else
			hxd.Res.initEmbed();
		#end

		// Load castle DB
		ExternCastleDbTest.load( hxd.Res.sample_cdb.entry.getText() );

		// Check args
		CiAssert.VERBOSE = false;
		for( a in Sys.args() )
			if( a=="-v" )
				CiAssert.VERBOSE = true;

		print("Running tests...");

		// Run tests
		var project = new ProjectNoPackage();

		try {
			section("PROJECT (NO PACKAGE)...");

			section("Project...");
			CiAssert.isNotNull( project );

			// Project asset loader
			CiAssert.isNotNull( project.getAsset("unitTest.ldtk") );

			// Project defs
			CiAssert.isNotNull( project.defs );
			CiAssert.isNotNull( project.defs.entities );
			CiAssert.isNotNull( project.defs.enums );
			CiAssert.isNotNull( project.defs.externalEnums );
			CiAssert.isNotNull( project.defs.layers );
			CiAssert.isNotNull( project.defs.tilesets );

			var defaultWorld  = project.all_worlds.World1;
			CiAssert.equals( defaultWorld.layout, ldtk.Json.WorldLayout.GridVania );
			CiAssert.isTrue( project.defs.entities.length>0 );
			CiAssert.isTrue( project.defs.enums.length>0 );
			CiAssert.isTrue( project.defs.externalEnums.length>0 );
			CiAssert.isTrue( project.defs.layers.length>0 );
			CiAssert.isTrue( project.defs.tilesets.length>0 );

			CiAssert.isNotNull( project.getLayerDefJson("IntGrid_AutoLayer") );
			CiAssert.isNotNull( project.getEntityDefJson("Hero") );
			CiAssert.isNotNull( project.getEnumDefJson("Weapons") );
			CiAssert.isNotNull( project.getEnumDefJson("lowercase_enum") );
			CiAssert.isNotNull( project.getTilesetDefJson("Minecraft_texture_pack") );

			CiAssert.equals( project.getEnumDefFromValue(Trash).identifier, "Mobs" );
			CiAssert.equals( project.getEnumDefFromValue(LongBow).identifier, "Weapons" );
			CiAssert.equals( project.getEnumDefFromValue(Lc_a).identifier, "lowercase_enum" );
			CiAssert.equals( project.getEnumDefFromValue(Ammo).identifier, "DroppedItemType" ); // extern
			CiAssert.equals( project.getEnumDefFromValue(Foo).identifier, "SomeEnum" ); // extern
			CiAssert.equals( project.getEnumDefFromValue(null), null );

			// Original JSON fields
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.json );
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_IntGrid8.json );
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_EntityTest.all_Mob[0].json );
			CiAssert.isNotNull( project.all_tilesets.Cavernas_by_Adam_Saltsman.json );

			// Types
			section("Types...");
			CiAssert.isNotNull( ProjectNoPackage.Enum_Mobs );
			CiAssert.isNotNull( ProjectNoPackage.ProjectNoPackage_EntityEnum );
			CiAssert.isNotNull( ProjectNoPackage.Tileset_Cavernas_by_Adam_Saltsman );

			// Levels
			section("Levels...");
			CiAssert.isNotNull( defaultWorld.all_levels );
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests );
			CiAssert.isNotNull( defaultWorld.all_levels.Offset_tests );
			CiAssert.isNotNull( defaultWorld.getLevel("Main_tests") );
			CiAssert.equals( defaultWorld.getLevel("Main_tests"), defaultWorld.all_levels.Main_tests );
			CiAssert.equals( defaultWorld.getLevel(0), defaultWorld.all_levels.Main_tests );
			CiAssert.isTrue( defaultWorld.levels.length>0 );
			CiAssert.isNotNull( defaultWorld.levels[0].l_IntGridTest );
			CiAssert.equals( defaultWorld.levels[1].worldX, 512 );
			CiAssert.equals( defaultWorld.levels[1].worldY, 256 );
			CiAssert.equals( defaultWorld.levels[0].bgColor_hex, "#271E27" );
			CiAssert.equals( defaultWorld.levels[0].bgColor_int, 0x271E27 );
			CiAssert.equals( defaultWorld.levels[0].neighbours.length, 2 );
			CiAssert.equals( defaultWorld.levels[0].neighbours[0].dir, ldtk.Level.NeighbourDir.East );
			CiAssert.equals( defaultWorld.getLevelAt(10,10), defaultWorld.all_levels.Main_tests );
			CiAssert.equals( defaultWorld.getLevelAt(600,400), defaultWorld.all_levels.Offset_tests );

			// Layer misc
			CiAssert.equals( defaultWorld.all_levels.Main_tests.l_IntGridTest.visible, true );

			// Layer JSONs
			var layer = defaultWorld.all_levels.Main_tests.l_EntityTest;
			CiAssert.isNotNull(layer.json);
			CiAssert.isNotNull(layer.json.entityInstances);
			CiAssert.isNotNull(layer.defJson);
			CiAssert.equals(layer.json.layerDefUid, layer.defJson.uid);
			CiAssert.equals(layer.defJson.identifier, "EntityTest");


			// Layer offsets
			CiAssert.equals( defaultWorld.all_levels.Offset_tests.l_IntGrid8.pxTotalOffsetX, 4 );
			CiAssert.equals( defaultWorld.all_levels.Offset_tests.l_IntGrid8.pxTotalOffsetY, 4 );
			CiAssert.equals( defaultWorld.all_levels.Offset_tests.l_IntGridTest.pxTotalOffsetX, 8 );
			CiAssert.equals( defaultWorld.all_levels.Offset_tests.l_IntGridTest.pxTotalOffsetY, 8 );
			CiAssert.equals( defaultWorld.all_levels.Offset_tests.l_EntityTest.all_OffsetTest[0].pixelX, 0 );
			CiAssert.equals( defaultWorld.all_levels.Offset_tests.l_EntityTest.all_OffsetTest[0].pixelY, 0 );


			// IntGrid layer
			section("IntGrid...");
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_IntGridTest );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.l_IntGridTest.type, ldtk.Json.LayerType.IntGrid );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_IntGridTest.type==IntGrid );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_IntGridTest.getInt(0,0)==1 );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_IntGridTest.hasValue(0,0) );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_IntGridTest.getName(0,0)=="a" );

			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_IntGridTest.getInt(1,0)==2 );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_IntGridTest.getInt(2,0)==3 );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_IntGridTest.getInt(3,0)==4 );

			CiAssert.equals( defaultWorld.all_levels.Main_tests.l_IntGridTest.hasValue(0,1), false );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.l_IntGridTest.hasValue(3,0, 4), true );

			CiAssert.equals( defaultWorld.all_levels.Main_tests.l_IntGridTest.isCoordValid(0,0), true );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.l_IntGridTest.isCoordValid(-1,0), false );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.l_IntGridTest.isCoordValid(999,0), false );

			// Entity layer
			section("Entity...");
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_EntityTest);
			CiAssert.equals( defaultWorld.all_levels.Main_tests.l_EntityTest.type, ldtk.Json.LayerType.Entities );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_EntityTest.type==Entities );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_EntityTest.all_Hero.length!=0 );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_EntityTest.all_Mob.length!=0 );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_EntityTest.all_AllFields.length!=0 );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.l_EntityTest.all_Unused.length, 0 );
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_EntityTest.all_Mob[0].tileInfos );

			// Entity layer tags
			var level = defaultWorld.all_levels.Main_tests;
			CiAssert.isNotNull( level.l_EntityWithTag );
			CiAssert.isNotNull( level.l_EntityWithTag.all_Tagged );
			CiAssert.equals( level.l_EntityWithTag.all_Tagged.length, 3 );
			CiAssert.equals( level.l_EntityWithTag.getAllUntyped().length, 3 );

			// Entities
			var hero = defaultWorld.all_levels.Main_tests.l_EntityTest.all_Hero[0];
			var mob = defaultWorld.all_levels.Main_tests.l_EntityTest.all_Mob[0];
			var allFieldsTest = defaultWorld.all_levels.Main_tests.l_EntityTest.all_AllFields[0];
			var fileEnt = defaultWorld.all_levels.Main_tests.l_EntityTest.all_File[0];
			CiAssert.isNotNull( hero );
			CiAssert.isNotNull( mob );
			CiAssert.isNotNull( allFieldsTest );
			CiAssert.isNotNull( fileEnt );
			CiAssert.equals( mob.f_scale, 0.5 );
			CiAssert.equals( hero.width, 16 );
			CiAssert.equals( hero.height, 24 );
			CiAssert.equals( allFieldsTest.width, 32 );
			CiAssert.equals( allFieldsTest.height, 32 );
			CiAssert.equals( allFieldsTest.iid, "f2f3f740-66b0-11ec-91ab-910cd77ba401" );
			CiAssert.equals( allFieldsTest.f_entityRefs.length, 2 );
			CiAssert.equals( allFieldsTest.f_entityRefs[0].entityIid, "57c51ab0-66b0-11ec-8446-f3a61ee63449" );
			CiAssert.equals( allFieldsTest.f_entityRefs[1].entityIid, "58f66ec0-66b0-11ec-8446-9b40d7be219b" );

			// Entity JSONs
			CiAssert.isNotNull(hero.json);
			CiAssert.isNotNull(hero.json.fieldInstances);
			CiAssert.isNotNull(hero.defJson);
			CiAssert.isNotNull(hero.defJson.fieldDefs);
			CiAssert.equals(hero.json.defUid, hero.defJson.uid);
			CiAssert.equals(hero.defJson.identifier, "Hero");

			// Extern enums
			var extEnt = defaultWorld.all_levels.Main_tests.l_EntityTest.all_ExternEnums[0];
			CiAssert.isNotNull(extEnt);
			CiAssert.isNotNull(extEnt.f_cdb);
			CiAssert.isNotNull(extEnt.f_haxe);
			CiAssert.equals(extEnt.f_cdb, CdbA);
			CiAssert.equals(extEnt.f_haxe, SomeEnum.Pouet);
			CiAssert.isTrue(
				switch extEnt.f_cdb {
					case CdbA: true;
					case CdbB: false;
					case CdbC: false;
				}
			);
			CiAssert.isTrue(extEnt.f_cdb==ExternCastleDbTest.CdbEnumTestKind.CdbA);

			// Entity tiles
			var eTiles = defaultWorld.all_levels.Main_tests.l_EntityTest.all_EntityTiles;
			CiAssert.isNotNull( eTiles );
			CiAssert.isTrue( eTiles.length>=2 );
			CiAssert.isNotNull( eTiles[0].tileInfos );
			CiAssert.equals( eTiles[0].tileInfos.tilesetUid, 14 );
			CiAssert.equals( eTiles[0].tileInfos.x, 32 );
			CiAssert.equals( eTiles[0].tileInfos.y, 32 );
			CiAssert.equals( eTiles[1].tileInfos.x, 64 );
			CiAssert.equals( eTiles[1].tileInfos.y, 0 );

			// Sym ref 1
			var fromSymRef = defaultWorld.all_levels.Main_tests.l_EntityTest.all_SymRef[0];
			var toSymRef = defaultWorld.all_levels.Target_level_ref.l_EntityTest.all_SymRef[0];
			CiAssert.equals( fromSymRef.f_ref.entityIid, toSymRef.iid );
			CiAssert.equals( fromSymRef.f_ref.levelIid, defaultWorld.all_levels.Target_level_ref.iid );
			CiAssert.equals( toSymRef.f_ref.entityIid, fromSymRef.iid );
			CiAssert.equals( toSymRef.f_ref.levelIid, defaultWorld.all_levels.Main_tests.iid );

			// Sym ref 2
			var fromSymRef = defaultWorld.all_levels.Main_tests.l_EntityTest.all_SymRef[1];
			var toSymRef = defaultWorld.all_levels.Main_tests.l_EntityTest.all_SymRef[2];
			CiAssert.equals( fromSymRef.f_ref.entityIid, toSymRef.iid );
			CiAssert.equals( fromSymRef.f_ref.levelIid, defaultWorld.all_levels.Main_tests.iid );
			CiAssert.equals( toSymRef.f_ref.entityIid, fromSymRef.iid );
			CiAssert.equals( toSymRef.f_ref.levelIid, defaultWorld.all_levels.Main_tests.iid );

			// Regions
			var r = defaultWorld.all_levels.Main_tests.l_EntityTest.all_Region[0];
			CiAssert.isNotNull(r);
			CiAssert.equals(r.width, 64);
			CiAssert.equals(r.height, 48);
			CiAssert.equals(r.f_flag, true);

			// Enums
			section("Enums...");
			CiAssert.isNotNull( Enum_Weapons );
			CiAssert.isNotNull( Enum_lowercase_enum );
			CiAssert.equals( Enum_Weapons.getConstructors()[0], "LongBow" );
			CiAssert.equals( Enum_Weapons.getConstructors()[1], "Torch" );
			CiAssert.equals( hero.f_startWeapon, LongBow );
			CiAssert.equals( mob.f_type, Trash );
			CiAssert.equals( mob.entityType, Mob );
			CiAssert.equals( mob.f_lootDrops[0], ExternEnumTest.DroppedItemType.Ammo );
			CiAssert.equals( mob.f_lootDrops[1], ExternEnumTest.DroppedItemType.Food );
			CiAssert.equals( mob.f_lootDrops[2], ExternEnumTest.DroppedItemType.Gold );
			CiAssert.equals( mob.f_lootDrops[3], ExternEnumTest.DroppedItemType.Key );

			// Arrays
			CiAssert.isNotNull( allFieldsTest.f_ints );
			CiAssert.equals( allFieldsTest.f_ints.length, 3 );
			CiAssert.equals( allFieldsTest.f_ints[0], 0 );
			CiAssert.equals( allFieldsTest.f_ints[1], 1 );
			CiAssert.equals( allFieldsTest.f_ints[2], 2 );
			CiAssert.equals( allFieldsTest.f_strings[0], "a" );
			CiAssert.equals( allFieldsTest.f_floats[1], 0.5 );
			CiAssert.equals( allFieldsTest.f_bools[0], false );
			CiAssert.equals( allFieldsTest.f_bools[2], true );
			CiAssert.equals( allFieldsTest.f_colors_hex[0],"#FF0000" );
			CiAssert.equals( allFieldsTest.f_colors_int[0], 0xff0000 );
			CiAssert.isTrue( allFieldsTest.f_localEnums.length>0 );
			CiAssert.equals( allFieldsTest.f_localEnums[0], FireBall );
			CiAssert.isTrue( allFieldsTest.f_externEnums.length>0 );
			CiAssert.equals( allFieldsTest.f_externEnums[0], Gold );
			CiAssert.equals( allFieldsTest.f_externEnums[1], null );
			CiAssert.equals( allFieldsTest.f_lowercaseEnum[0], Lc_a );
			CiAssert.equals( allFieldsTest.f_lowercaseEnum[1], Lc_b );
			CiAssert.equals( allFieldsTest.f_lowercaseEnum[2], null );

			// FilePath entity field & loading
			CiAssert.isNotNull( fileEnt.f_filePath );
			CiAssert.isNotNull( project.getAsset(fileEnt.f_filePath) );
			CiAssert.isNotNull( fileEnt.f_filePath_bytes );
			CiAssert.isTrue( fileEnt.f_filePath_bytes.length>0 );

			// Points / paths
			section("Points/paths...");
			CiAssert.isTrue( allFieldsTest.f_point.cx==19 );
			CiAssert.isTrue( mob.f_path!=null );
			CiAssert.isTrue( mob.f_path.length>0 );
			CiAssert.isTrue( mob.f_path[0].cy == mob.cy );

			// Worlds untyped access
			for(w in project.worlds)
				CiAssert.isTrue( Reflect.hasField(project.all_worlds, w.identifier) );
			CiAssert.isNotNull( project.getWorld(project.all_worlds.World1.iid) );
			CiAssert.isNotNull( project.getWorld(project.all_worlds.World2.iid) );
			CiAssert.equals( project.getWorld(project.all_worlds.World1.iid), project.all_worlds.World1 );
			CiAssert.equals( project.getWorld(project.all_worlds.World2.iid), project.all_worlds.World2 );
			CiAssert.equals( project.worlds[0].layout, ldtk.Json.WorldLayout.GridVania );
			CiAssert.equals( project.worlds[1].layout, ldtk.Json.WorldLayout.Free );

			// Enum switch check
			section("Switch...");
			CiAssert.isTrue( switch defaultWorld.all_levels.Main_tests.l_EntityTest.all_Mob[0].f_lootDrops[0] {
				case null: false;
				case Ammo: true;
				case Food: false;
				case Gold: false;
				case Key: false;
			});
			switch defaultWorld.all_levels.Main_tests.l_EntityTest.all_Mob[0].f_type {
				case Trash:
				case Shooter:
				case Shielder:
			}

			// Level custom fields
			CiAssert.equals( defaultWorld.all_levels.Main_tests.f_level_int, 1 );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.f_level_string, "my string value" );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.f_level_reward, Ammo );
			CiAssert.equals( defaultWorld.all_levels.Offset_tests.f_level_int, 2 );
			CiAssert.equals( defaultWorld.all_levels.Offset_tests.f_level_reward, Key );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.f_lowercase_enum[0], Lc_a );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.f_lowercase_enum[1], Lc_b );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.f_lowercase_enum.length, 2 );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.f_lowercase_enum[2], null );

			// Tile layer
			section("Tile layer...");
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_TileTest );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.l_TileTest.type, ldtk.Json.LayerType.Tiles );
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.resolveLayer("TileTest") );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_TileTest.identifier=="TileTest" );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_TileTest.type==Tiles );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_TileTest.hasAnyTileAt(4,0) );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.l_TileTest.getTileStackAt(4,0)[0].tileId, 0 );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_TileTest.hasAnyTileAt(5,0) );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.l_TileTest.getTileStackAt(5,0)[0].tileId, 1 );


			// Tilesets
			section("Tilesets...");
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_TileTest.tileset );
			// CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_TileTest.tileset.atlasBytes );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_TileTest.getTileStackAt(1,4)[0].tileId>=0 );
			var gridSize = defaultWorld.all_levels.Main_tests.l_TileTest.tileset.tileGridSize;
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_TileTest.tileset.getAtlasX(1)==gridSize );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_TileTest.tileset.getAtlasY(1)==0 );

			// Tilesets enum tags
			CiAssert.isNotNull( project.all_tilesets.Minecraft_texture_pack );
			CiAssert.isNotNull( project.all_tilesets.Minecraft_texture_pack.hasTag );
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_TileTest.tileset );
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_TileTest.tileset.hasTag );
			CiAssert.isTrue( project.all_tilesets.Minecraft_texture_pack.hasTag(0,Grass) );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_TileTest.tileset.hasTag(0,Grass) );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_TileTest.tileset.hasTag(1,Stone) );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_TileTest.tileset.hasTag(3,Grass) );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_TileTest.tileset.hasTag(3,Dirt) );
			CiAssert.isFalse( defaultWorld.all_levels.Main_tests.l_TileTest.tileset.hasTag(1,Grass) );
			CiAssert.isFalse( defaultWorld.all_levels.Main_tests.l_TileTest.tileset.hasTag(4,Grass) );

			CiAssert.isNotNull( project.all_tilesets.Cavernas_by_Adam_Saltsman );
			CiAssert.isNotNull( project.all_tilesets.Cavernas_by_Adam_Saltsman.hasTag );
			CiAssert.isTrue( project.all_tilesets.Cavernas_by_Adam_Saltsman.hasTag(0,Lc_a) );
			CiAssert.isTrue( project.all_tilesets.Cavernas_by_Adam_Saltsman.hasTag(1,Lc_b) );
			CiAssert.isTrue( project.all_tilesets.Cavernas_by_Adam_Saltsman.hasTag(2,Lc_c) );
			CiAssert.isTrue( project.all_tilesets.Cavernas_by_Adam_Saltsman.hasTag(3,Lc_d) );
			CiAssert.isFalse( project.all_tilesets.Cavernas_by_Adam_Saltsman.hasTag(1,Lc_a) );
			CiAssert.isFalse( project.all_tilesets.Cavernas_by_Adam_Saltsman.hasTag(4,Lc_a) );


			// Auto-layer (IntGrid)
			section("Auto-Layer (IntGrid)...");
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_IntGrid_AutoLayer );
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_IntGrid_AutoLayer.tileset );
			// CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_IntGrid_AutoLayer.tileset.atlasBytes );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_IntGrid_AutoLayer.autoTiles.length>100 );
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_IntGrid_AutoLayer.autoTiles[0] );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_IntGrid_AutoLayer.autoTiles[0].renderX!=0 );

			// Auto-layer (pure)
			section("Auto-Layer (pure)...");
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_Pure_AutoLayer);
			// CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_Pure_AutoLayer.tileset.atlasBytes );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.l_Pure_AutoLayer.type, ldtk.Json.LayerType.AutoLayer );
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_Pure_AutoLayer.tileset );

			// Project references
			section("Project refs...");
			var level = defaultWorld.all_levels.Main_tests;
			@:privateAccess CiAssert.equals( level.untypedProject, project );
			@:privateAccess CiAssert.equals( level.l_EntityTest.untypedProject, project );
			@:privateAccess CiAssert.equals( level.l_IntGrid_AutoLayer.tileset.untypedProject, project );


			// Level background image
			CiAssert.isTrue( defaultWorld.all_levels.Offset_tests.bgImageInfos==null );
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.bgImageInfos );
			CiAssert.equals( defaultWorld.all_levels.Main_tests.bgImageInfos.topLeftX, 0 );
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.bgImageInfos.cropRect );


			// Project in a package
			section("PROJECT (WITH PACKAGE)...");

			var project = new packageTest.ProjectPackage();
			CiAssert.isNotNull( project );
			CiAssert.isNotNull( packageTest.ProjectPackage.Enum_Mobs );
			CiAssert.isNotNull( packageTest.ProjectPackage.ProjectPackage_EntityEnum );
			CiAssert.isNotNull( packageTest.ProjectPackage.Enum_Weapons );
			CiAssert.isNotNull( packageTest.ProjectPackage.Tileset_Cavernas_by_Adam_Saltsman );
			CiAssert.isNotNull( defaultWorld.all_levels );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.load() );
			CiAssert.isTrue( defaultWorld.all_levels.Offset_tests.load() );
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_EntityTest.all_Mob.length>0 );
			CiAssert.isNotNull( defaultWorld.all_levels.Main_tests.l_EntityTest.all_Mob[0].f_lootDrops );
			CiAssert.isTrue( defaultWorld.all_levels.Main_tests.l_EntityTest.all_Hero[0].f_startWeapon == Enum_Weapons.LongBow );

			// Table of content
			CiAssert.isNotNull( project.toc );
			CiAssert.isNotNull( project.toc.Hero );
			CiAssert.isTrue( project.toc.Hero.length>0 );
			CiAssert.equals( project.toc.Hero[0].entityIid, "f2f3d032-66b0-11ec-91ab-159ce9d99f47" );
			CiAssert.isNotNull( project.toc.Mob );
			CiAssert.isTrue( project.toc.Mob.length>0 );


			var world = project.all_worlds.World1;

			// 1.4.0
			var l = world.all_levels.v1_4_0;
			CiAssert.isNotNull(l);
			var e = l.l_EntityTest.all_Hero[0];
			CiAssert.isNotNull(e);
			CiAssert.equals(e.pixelX, 40);
			CiAssert.equals(e.pixelY, 96);
			CiAssert.equals(e.worldPixelX, l.worldX+e.pixelX);
			CiAssert.equals(e.worldPixelY, l.worldY+e.pixelY);
			CiAssert.equals(l.neighbours.length, 1);
			CiAssert.equals(l.neighbours[0].dir, ldtk.Level.NeighbourDir.DepthBelow);
		}
		catch( e:Dynamic ) {
			// Unknown errors
			print("Exception: "+e);
			print("");
			exit(1);
			return;
		}

		if( CiAssert.VERBOSE )
			print("");
		print("Success.");
		exit(0);
	}
}

