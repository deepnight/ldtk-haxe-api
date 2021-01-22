/**
	NOTE:
	this class isn't a sample nor a demo: it generates the samples HXML and HTML files.
**/

class SamplesBuilder {
	public static function run() {
		var baseDir = "../.."; // no trailing "/"

		Sys.println("");
		Sys.println('NOTE: please check the README for more infos.');
		Sys.println("");


		// List all sample HX files
		var hxFiles : Array<dn.FilePath> = [];
		var allowedDirs = [ "Heaps -", "Generic -" ];
		var pendingDirs = [ baseDir ];
		while( pendingDirs.length>0 ) {
			var dir = pendingDirs.shift();
			for(f in sys.FileSystem.readDirectory(dir)) {
				if( sys.FileSystem.isDirectory(dir+"/"+f) ) {
					for( allow in allowedDirs )
						if( f.indexOf(allow)>=0 ) {
							pendingDirs.push(dir+"/"+f);
							break;
						}
				}
				else if( dir!=baseDir && f.indexOf(".hx")==f.length-3 )
					hxFiles.push( dn.FilePath.fromFile(dir+"/"+f) );
			}
		}


		var removeCmdRegEx = ~/--cmd (.*$)/gm;
		var allHxmls = [];
		var htmlToc = [];
		// var htmlToc = hxFiles.map( (fp)->{
		// 	var name = fp.fileName;
		// 	return '<li> <a href="$name.html">$name</a> </li>';
		// });
		for(fp in hxFiles) {
			var name = fp.fileName;
			var dir = fp.directory;

			// Build HXML
			Sys.println('Creating $dir/build.hxml...');
			var hxml = StringTools.replace(BASE_HXML, "%name%", name);
			hxml = StringTools.replace(hxml, "\t", "");
			sys.io.File.saveContent('$dir/build.hxml', hxml );

			// Build HTML
			Sys.println('Creating $dir/index.html...');
			var html = StringTools.replace( BASE_HTML, "%name%", name );
			html = StringTools.replace( html, "%toc%", htmlToc.join("") );

			sys.io.File.saveContent('$dir/index.html', html );
			allHxmls.push('$dir/build.hxml');
		}

		// Create buildAll.hxml
		var allHxml = allHxmls.map( path->{
			var fp = dn.FilePath.fromFile(path);
			fp.makeRelativeTo(baseDir);
			return '
				--cwd "${fp.directory}"
				"${fp.fileWithExt}"
				--next
				--cwd ..
				';
		} ).join("--next\n");
		allHxml = StringTools.replace(allHxml, "\t", "");
		sys.io.File.saveContent('$baseDir/buildAll.hxml', allHxml);

		Sys.println('Generated ${allHxmls.length} sample build files successfully.');
	}

	public static function print(msg:String) { // Used in HXML macro calls
		Sys.println("");
		Sys.println(msg);
	}




	static var BASE_HXML = "
		# %name% (Javascript/WebGL)
		-cp .
		-cp ../_srcCommon
		-cp ../../src
		-lib heaps
		-lib deepnightLibs
		-D resourcesPath=../_assets
		--dce full
		-main %name%
		-js _javascript.js

		# %name% (Hashlink)
		--next
		-cp .
		-cp ../_srcCommon
		-cp ../../src
		-lib heaps
		-lib deepnightLibs
		-D resourcesPath=../_assets
		-lib hlsdl
		--dce full
		-main %name%
		-hl _hashlink.hl
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
						width: 960px;
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

				<div id="error">Failed to load JS script! Please build it using the HXML file (run: <code>haxe build.hxml</code>).</div>

				<canvas id="webgl"></canvas>

				<script type="text/javascript" src="_javascript.js" onerror=\'document.getElementById("error").style.display="block"\'></script>

			</body>
		</html>
	';
}
