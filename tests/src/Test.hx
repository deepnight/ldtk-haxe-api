class Test {
	public function new() {
		print("Starting tests...");

		try {
			// Run tests
			new test.Data();

			#if( hl || js )
			new test.Render();
			#end
		}
		catch( e:Dynamic ) {
			// Unknown errors
			print("Unknown error: "+e);
			die();
		}

		print("Success.");
	}

	public static function die() {
		print("Critical error, tests stopped.");
		print("");
		#if js
		throw new js.lib.Error("Failed");
		#else
		Sys.exit(1);
		#end
	}

	public static function print(v:Dynamic) {
		#if js
		js.html.Console.log( Std.string(v) );
		#else
		Sys.println( Std.string(v) );
		#end
	}
}

