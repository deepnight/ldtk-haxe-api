# About

## What is this?

This is the Haxe API to load **LDtk Project JSON** files.

*LDtk is a modern and open-source 2D level editor.*

[Issue tracker (shared)](https://github.com/deepnight/ldtk/issues) |
[API documentation](https://ldtk.io/docs/game-dev/haxe-in-game-api/) |
[LDtk official page](https://ldtk.io)

[![Unit tests](https://github.com/deepnight/ldtk-haxe-api/actions/workflows/unitTests.yml/badge.svg)](https://github.com/deepnight/ldtk-haxe-api/actions/workflows/unitTests.yml)

## Features

 - Compatible with all Haxe based frameworks and engines.
 - Dedicated API for the following frameworks:
   - Heaps.io
   - [HaxeFlixel](https://haxeflixel.com/)
 - **Completely typed at compilation**: if you rename any element in your project (ie. level, layer, entity, etc.), the corresponding references in your code will break accordingly, avoiding typical errors or mistypings.
 - **Full completion in VScode**: if you have vs-haxe installed, you will get full completion while exploring your project file, based on its actual content, right from VScode.

# Usage

## Install

```
haxelib install ldtk-haxe-api
```
## Documentation

Please check the **full documentation and tutorials** here:

https://deepnight.net/docs/ldtk/haxe-api/

## Samples

You can check some examples in [samples](samples) folder.

Samples are built to **WebGL** (Javascript) and **Hashlink** targets, but you can try them on other compatible platforms too.

### Requirements

You need a standard **Haxe** install, and the following libraries installed: *heaps* (from source), *deepnightLibs* (from source), *hlsdl*:

```
haxelib git heaps https://github.com/HeapsIO/heaps.git

haxelib git deepnightLibs https://github.com/deepnight/deepnightLibs.git

haxelib install hlsdl
```

### Building samples

Open a folder in the `samples` folder (eg. `samples\Generic - Generic - Read project`) and run:

```
haxe build.hxml
```

You can also build all samples in one go. Go in `samples` folder and run:

```
haxe buildAll.hxml
```

### Rebuild samples HXMLs

If you modify the API, you might need to rebuild samples `HXML`s files themselves. In the root of the repo, run:

```
haxe genSamples.hxml
```

## Unit tests

You can build and run unit tests manually using the following commands **from the repository root**.

### JS/WebGL target

You will need Node interpreter to run the tests.

```
haxe tests\js.hxml
```

### Neko target

You will need Neko VM interpreter to run the tests.

```
haxe tests\neko.hxml
```
