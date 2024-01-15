/**
	This sample shows how to access some of the Project data using Haxe API.
**/

import ExternEnumTest;

class ReadProject {
	static function main() {
		hxd.Res.initEmbed();
		var project = new LdtkProject();

		var myLevel = project.all_worlds.SampleWorld.all_levels.West;

		// IntGrid ASCII render
		var layer = myLevel.l_Collisions;
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
		for( playerEntity in myLevel.l_Entities.all_Player )
			print( "Found: "+playerEntity.identifier );

		for( itemEntity in myLevel.l_Entities.all_Item ) {
			print( "Found: "+itemEntity.identifier );
			print( "  type = "+itemEntity.f_type );

			var displayName = switch itemEntity.f_type {
				case Pickaxe: 'A rusty pickaxe';
				case Potion: 'A fresh vial of Healing potion';
				case Food: 'Some tasty food';
			}
			print('  "$displayName"');
		}
	}




	/**
		Print some text
	**/
	#if js
	static var _htmlLog : js.html.Element;
	#end

	static function print(msg:String) {
		#if sys

			Sys.println(msg);

		#elseif js

			if( _htmlLog==null ) {
				// Hide HTML canvas
				js.Browser.document.querySelector("canvas").remove();

				// Create a PRE element to display text
				_htmlLog = js.Browser.document.createPreElement();
				js.Browser.document.body.appendChild(_htmlLog);
				_htmlLog.style.marginLeft = "16px";
				_htmlLog.innerText = "CONSOLE OUTPUT:\n\n";
			}
			_htmlLog.append(msg+"\n");
			js.html.Console.info(msg);

		#else

			trace(msg);

		#end
	}
}

