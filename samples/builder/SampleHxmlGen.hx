/**
	NOTE: this class isn't a sample nor a demo.
	It generates the samples build files automatically using a macro.
**/

package samples.builder;

class SampleHxmlGen {
	public static function run() {
		var dir = "samples"; // no trailing "/"

		Sys.println("");
		Sys.println('NOTE: please check the README for more infos.');
		Sys.println("");


		// List all sample files
		var hxFiles = sys.FileSystem.readDirectory(dir).filter( function(f) {
			return f.indexOf(".hx")==f.length-3 && f.charAt(0)!="_";
		});

		var removeCmdRegEx = ~/--cmd (.*$)/gm;
		var hxmls = [];
		var htmlToc = hxFiles.map( (f)->{
			var name = f.substring(0, f.indexOf(".hx"));
			return '<li> <a href="$name.html">$name</a> </li>';
		});
		for(f in hxFiles) {
			var name = f.substring(0, f.indexOf(".hx"));

			// Build HXML
			Sys.println('Creating $name.hxml...');
			var hxml = StringTools.replace(BASE_HXML, "%name%", name);
			hxml = StringTools.replace(hxml, "\t", "");
			sys.io.File.saveContent('$dir/$name.hxml', hxml );

			// Build HTML
			Sys.println('Creating $name.html...');
			var html = StringTools.replace( BASE_HTML, "%name%", name );
			html = StringTools.replace( html, "%toc%", htmlToc.join("") );

			sys.io.File.saveContent('$dir/$name.html', html );
			hxmls.push( removeCmdRegEx.replace(hxml, "") );
		}

		var all = hxmls.join("--next\n");
		sys.io.File.saveContent('$dir/all.hxml', all);

		Sys.println('Generated ${hxmls.length} sample build files successfully.');
	}

	public static function print(msg:String) { // Used in HXML macro calls
		Sys.println("");
		Sys.println(msg);
	}




	static var BASE_HXML = "
		# %name% (Javascript/WebGL)
		-cp .
		-cp ../src
		-lib heaps
		-lib deepnightLibs
		--dce full
		-main %name%
		-js bin/%name%.js
		--cmd %name%.html

		# %name% (Hashlink)
		--next
		-cp .
		-cp ../src
		-lib heaps
		-lib deepnightLibs
		--dce full
		-main %name%
		-hl bin/%name%.hl
	";


	static var BASE_HTML = '
		<!DOCTYPE html>
		<html>
			<head>
				<meta name="viewport" content="width=device-width, user-scalable=no">
				<meta charset="utf-8"/><title>%name%</title>
				<style>
					body {
						font-family: sans-serif;
						margin: 0;
						padding: 0;
						background-color: gray;
					}
					canvas {
						width: 640px;
						height: 480px;
						margin: 20px;
						border: 1px solid white;
						background-color: #555;
					}
					#error {
						display: none;
						padding: 16px;
						margin-bottom: 16px;
						color: white;
						background: red;
					}
					ul.toc {
						display: flex;
						list-style: none;
						margin: 0;
						padding: 8px;
					}
					ul.toc li a {
						display: inline-block;
						padding: 3px 8px;
						background: black;
						color: #fc0;
						text-decoration: none;
						border-radius: 3px;
						margin-right: 1px;
						margin-bottom: 1px;
					}
					ul.toc li:hover a {
						color: black;
						background-color: #fc0;
						text-decoration: none;
					}
				</style>
			</head>
			<body id="body">
				<ul class="toc">%toc%</ul>

				<div id="error">Failed to load JS script! Please build it using the corresponding HXML file.</div>

				<canvas id="webgl"></canvas>

				<script type="text/javascript" src="bin/%name%.js" onerror=\'document.getElementById("error").style.display="block"\'></script>

			</body>
		</html>
	';
}
