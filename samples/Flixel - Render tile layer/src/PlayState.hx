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
		for( level in project.levels ) {
			// Create a FlxGroup for all level layers
			var container = new flixel.group.FlxSpriteGroup();
			add(container);

			// Place it using level world coordinates (in pixels)
			container.x = level.worldX;
			container.y = level.worldY;

			// Render layer "Background"
			level.l_Background.render( container );

			// Render layer "Collisions"
			level.l_Collisions.render( container );

			// Render layer "Custom_Tiles"
			level.l_Custom_tiles.render( container );
		}

	}
}
