# About

## What is this?

This is the Haxe API to load **LEd Project JSON** files.

*LEd is a modern and open-source 2D level editor.*

[LEd official page](https://deepnight.net/tools/led-2d-level-editor) |


## Features

 - **Completely typed at compilation**: if you rename any element in your project (ie. level, layer, entity, etc.), the corresponding references in your code will break accordingly, avoiding typical errors or mistypings.

# Install

## Latest stable version

```
haxelib install led-haxe-api
```

## Latest Git

It is recommended to use the Git version **if you built LEd from Git**.

```
haxelib git led-haxe-api https://github.com/deepnight/led-haxe-api.git
```

# Usage

## 1. Create the project class

Create a HX file for each L-Ed project JSON. The filename isn't important, pick whatever you like.

This HX will host all the the typed data extracted from the JSON:

<sub>**MyProject.hx:**</sub>

```haxe
private typedef _Tmp =
	haxe.macro.MacroType<[ led.Project.build("../path/to/myProject.json") ]>;
```

## 2. Create a project instance

<sub>**MyGame.hx:**</sub>
```haxe
class MyGame {
	public function new() {
		var p = new MyProject();
		trace( p.all_levels ); // Well done!
	}
}
```

## Notes

The "*_Tmp*" typedef isn't actually directly used. But for syntax validity purpose, we need an identifier here. Anything will do the job.

This magic line will call the `led.Project.build` *macro* which will parse the project JSON file, then use its content to dynamically construct types & classes definitions at compilation-time.

You can move the project HX class to a sub-package, just add the corresponding `package` line at the beginning:

```haxe
package assets;

private typedef _Tmp =
	haxe.macro.MacroType<[ led.Project.build("../path/to/myProject.json") ]>;
```


# Accessing all data

The project content is easily accessed using various methods:

```haxe
var p = new MyProject();

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
trace( someTreasure.f_isTreasureHidden ); // boolean custom field
trace( someTreasure.f_customColor_hex ); // color code in Hex format (#rrggbb)
```

# Refresh project data without recompiling

**Important notes**: the project JSON is embedded at compilation-time for easier usage.

If you edit your levels afterwise, **the embedded levels won't automatically update**, unless you *recompile* your code.

You can "fix" that by passing the dynamically loaded JSON string to the constructor:

```haxe
var projectJsonString = SomeFileAccessApi.readFile("myProject.json");

var p = new MyProject( projectJsonString ); // will override embedded JSON
```

**Warning**: all the types & classes definitions are only generated at compilation time. This will only refresh the actual data.

You can also use the `parseJson()` method to dynamically update (eg. to implement "hot-reloading") your project data at runtime:

```haxe
/*
I will pretend that this method is called by your hot-reload API
when the project JSON changes on the disk.
*/
function onMyProjectFileChange(newFileContent:String) {
	p.parseJson( newFileContent );
}
```
