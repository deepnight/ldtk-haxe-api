# ABOUT

## What is this?

This is the Haxe API to load **L-Ed** projects.

L-Ed is an open-source 2D level editor, available here: https://github.com/deepnight/led

## Features

 - **Completely typed at compilation**: if you rename any element in your project (ie. level, layer, entity, etc.), the corresponding references in your code will break accordingly, avoiding typical errors or mistypings.


# USAGE

## Install

```
haxelib install led-haxe-api
```

You can optionally use the latest GIT version by using:

```
haxelib git led-haxe-api https://github.com/deepnight/led.git
```


## Parsing your L-Ed project JSON

Create a HX file for each L-Ed project you want to load:

<sub>**MyProject.hx:**</sub>
```js
private typedef _Tmp = haxe.macro.MacroType<[
	led.Project.build("../path/to/myProject.json")
]>;
```

**Note**: "*_Tmp*" isn't actually used, but we still need an identifier here. Anything will do the job.

This magic line will call the `led.Project.build()` *macro* which will parse the project JSON file, then use its content to dynamically construct types & classes definitions at compilate-time.

## Instanciating the project

Create a project instance somewhere:

<sub>**MyGame.hx:**</sub>
```js
class MyGame {
	public function new() {
		var p = new MyProject();
	}
}
```

The project content is easily accessed using various methods:

```js
// Access to a specific level
var level = p.all_levels.MyFirstLevel;
trace( level.pxWid );

// Access to a layer in this level
var someLayer = level.l_myIntGridLayer; // return a properly typed IntGrid layer
var entityLayer = level.l_myEntityLayer; // return a properly typed Entity layer

// Access to some entities in an Entity-layer
for( treasure in entityLayer.all_Treasure )
	trace( treasure.pixelX );

// Access to entity fields
var someTreasure = entityLayer.all_Treasure[0];
trace( someTreasure.f_isTreasureHidden); // boolean custom field
trace( someTreasure.f_customColor_hex); // color code in Hex format (#rrggbb)
```

## Refresh project data without recompiling

**Important notes**: the project JSON is embedded at compilation-time for easier usage.

If you edit your levels afterwise, the embedded levels won't automatically update, unless you recompile your code.

You can fix that by passing the dynamically loaded JSON to the constructor:

```js
var jsonString = SomeFileAccessApi.readFile("myProject.json");

var p = new MyProject( jsonString ); // will override embedded JSON
```

**Warning**: all the types & classes definitions are only generated at compilation time. This will only refresh the actual data.

You can also use the `parseJson()` method to dynamically update (ie. "hot-reload") your project data at runtime:

```js
/*
I will pretend that this method is called by your hot-reload API
when your project files changes on the disk.
*/
function onMyProjectFileChange(newFileContent:String) {
	p.parseJson( newFileContent );
}
```
