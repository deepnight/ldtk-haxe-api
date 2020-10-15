/**
	This sample shows how to access some of the Project data
	using Haxe API.
**/

import externEnums.GameEnums;

class BaseExample {
	static function main() {
		var project = new _Project();

		var myLevel = project.all_levels.MyFirstLevel;

		// IntGrid ASCII render
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
		for( mobEntity in myLevel.l_EntityTest.all_Mob ) {
			print( mobEntity.identifier );
			print( "  scale = "+mobEntity.f_scale );

			var i = 0;
			for( pt in mobEntity.f_path )
				print( "  path["+(i++)+"] = "+pt.cx+","+pt.cy);
		}

		// Enum switching
		for( mobEntity in myLevel.l_EntityTest.all_Mob ) {
			var lootName = switch mobEntity.f_lootDrop {
				case null: "no loot";
				case Food: "some food";
				case Gold: "gold coins";
				case Ammo: "ammunitions";
				case Key: "iron key";
			}
			print( mobEntity.identifier+" => loot = '"+lootName+"'" );
		}
	}




	#if js
	static var _htmlLog : js.html.Element;
	#end
	static function print(msg:String) {
		#if sys
			Sys.println(msg);
		#elseif js
			if( _htmlLog==null ) {
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

