class _HxmlGenerator {
	public static function run() {
		var dir = "samples"; // no trailing "/"

		var baseHxml = [
			"-cp .",
			"-cp ../src",
			"-lib hlsdl",
			"-lib heaps",
			"-lib deepnightLibs",
			"-D windowSize=1280x720",
			"-D resourcesPath=res",
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
			hxml.push('-hl bin/$name.hl');
			hxml.push('--cmd hl bin/$name.hl');

			// Save it
			sys.io.File.saveContent('$dir/$name.hxml', hxml.join("\n") );
			hxmls.push( hxml.filter( function(line) return line.indexOf("--cmd")<0 ) );
		}

		var all = hxmls.map( function(hxml) return hxml.join("\n") ).join("\n\n--next\n");
		sys.io.File.saveContent('$dir/all.hxml', all);

		Sys.println("");
		Sys.println('Generated ${hxmls.length} sample HXMLs successfully.');
	}
}
