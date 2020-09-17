/**
	NOTE: this class isn't a sample nor a demo.
	It generates the samples build files automatically using a macro.
**/

class SampleHxmlGen {
	public static function run() {
		var dir = "samples"; // no trailing "/"

		var baseHxml = [
			"-cp .",
			"-cp ../src",
			"-lib heaps",
			"-lib deepnightLibs",
			"-D resourcesPath=res",
			"--dce full",
		];

		// List all sample files
		var hxFiles = sys.FileSystem.readDirectory(dir).filter( function(f) {
			return f.indexOf(".hx")==f.length-3 && f.charAt(0)!="_";
		});

		var hxmls = [];
		for(f in hxFiles) {
			var name = f.substring(0, f.indexOf(".hx"));
			Sys.println('Creating $name.hxml...');

			// Build HXML
			var hxml = baseHxml.copy();
			hxml.push('-main $name');
			hxml.push('-js bin/$name.js');
			hxml.push('--cmd start $name.html');
			sys.io.File.saveContent('$dir/$name.hxml', hxml.join("\n") );

			// Build HTML
			var html = StringTools.replace( BASE_HTML, "%%", name );

			sys.io.File.saveContent('$dir/$name.html', html );
			hxmls.push( hxml.filter( function(line) return line.indexOf("--cmd")<0 ) );
		}

		var all = hxmls.map( function(hxml) return hxml.join("\n") ).join("\n\n--next\n");
		sys.io.File.saveContent('$dir/all.hxml', all);

		Sys.println("");
		Sys.println('Generated ${hxmls.length} sample HXMLs successfully.');
	}


	static var BASE_HTML = '
		<!DOCTYPE html>
		<html>
			<head>
				<meta name="viewport" content="width=device-width, user-scalable=no">
				<meta charset="utf-8"/><title>%%</title>
				<style>
					body {
						margin: 0;
						padding: 0;
						background-color: gray;
					}
					canvas {
						width: 640px;
						height: 480px;
						margin: 20px;
						border: 1px solid white;
						background-color: black;
					}
				</style>
			</head>
			<body id="body">

				<canvas id="webgl"></canvas>
				<script type="text/javascript" src="bin/%%.js"></script>

			</body>
		</html>
	';
}
