import dn.*;
import LdtkProject;

class Main extends dn.Process {
	var bmp : h2d.Bitmap;
	var p : LdtkProject;
	var level : LdtkProject_Level;

	public function new() {
		super();

		createRoot(Boot.ME.s2d);

		p = new LdtkProject();
		level = p.all_levels.Level_0;

		// Render
		root.addChild( level.l_Collisions.render() );

		// Level tile field
		var t = level.f_levelTile_getTile();
		if( t!=null )
			new h2d.Bitmap(t, root);

		// Entity tiles
		for(e in level.l_Entities.all_TilesTest) {
			trace(e);
			trace(" skin="+e.f_skin_infos);
			trace(" opt="+e.f_optTile_infos);
			var bmp = new h2d.Bitmap(e.getTile(), root);
			bmp.setPosition( e.pixelX, e.pixelY );
		}

		Process.resizeAll();
	}

	override function onResize() {
		super.onResize();
		
		root.setScale( dn.heaps.Scaler.bestFit_i(level.pxWid, level.pxHei) );
	}

	override function update() {
		super.update();
	}
}
