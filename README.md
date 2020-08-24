# About

This is the Haxe API to load L-Ed projects.

# Features

TODO features

# Install

TODO install guide
```
haxelib install led-haxe-api
```


# USAGE

Create a HX file for each L-Ed project you want to use:

<sub>**MyProject.hx:**</sub>
```js
private typedef _Whatever = haxe.macro.MacroType<[
	led.Project.build("../path/to/myProject.json")
]>;
```

This file will be populated at compilation-time with all classes & stuff needed to read your JSON project file.

Then in your code, you can access its whole content very easily:

```js
var p = new MyProject();
```

```js
// Access to a specific level
var level = p.all_levels.MyFirstLevel;
level.pxWid;

// Access to a layer in this level
var someLayer = level.l_myIntGridLayer; // return a properly typed IntGrid layer
var entityLayer = level.l_myEntityLayer; // return a properly typed Entity layer

// Access to some entities in an Entity-layer
for( treasure in entityLayer.all_Treasure )
	trace( treasure.pixelX );

// Access to entity fields
var someTreasure = entityLayer.all_Treasure[0];
trace( someTreasure.f_isTreasureHidden); // boolean custom field
```

# Refresh project data without recompiling

The project JSON is embedded at compilation-time for easier usage.

If you edit your levels afterwise, the embedded levels won't automatically update, unless you recompile your code.

You can fix that by using the `parseJson()` method in your Project instance:

```js
var jsonString = SomeFileApi.readFile("myProject.json");

var p = new MyProject( jsonString ); // will override embedded JSON
p.parseJson( jsonString );
```

You use this to dynamically update (ie. "hot-reload") your project data at runtime.

```js
class MyGame {
	var p : MyProject;

	public function new() {
		var p = new MyProject(); // will use embedded JSON
	}

	/*
	This method is called by your hot-reload API
	when your project files changes on the disk.
	*/
	function onMyProjectFileChange(newFileContent:String) {
		p.parseJson( newFileContent );
	}
}
```
