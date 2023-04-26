package;

import flixel.FlxG;
import flixel.FlxState;

class PlayState extends FlxState
{
	override public function create()
	{
		super.create();

		// Create project instance
		var project = new LdtkProject();


		// Iterate all world levels
		for( level in project.all_worlds.Default.levels ) {
			// Create a FlxGroup for all level layers
			var container = new flixel.group.FlxSpriteGroup();
			add(container);

			// Place it using level world coordinates (in pixels)
			container.x = level.worldX;
			container.y = level.worldY;

			// Attach level background image, if any
			if( level.hasBgImage() )
				container.add( level.getBgSprite() );

			// Render layer "Background"
			level.l_Cavern_background.render( container );

			// Render layer "Collisions"
			level.l_Collisions.render( container );

			// Render layer "Custom_Tiles"
			level.l_Custom_tiles.render( container );
		}

	}
}
