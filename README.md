# About

## What is this?

This is the Haxe API to load **LEd Project JSON** files.

*LEd is a modern and open-source 2D level editor.*

[API documentation](https://deepnight.net/docs/led/haxe-api) |
[LEd official page](https://deepnight.net/tools/led-2d-level-editor) 

[![Build Status](https://travis-ci.com/deepnight/led-haxe-api.svg?branch=master)](https://travis-ci.com/deepnight/led-haxe-api)


## Features

 - **Completely typed at compilation**: if you rename any element in your project (ie. level, layer, entity, etc.), the corresponding references in your code will break accordingly, avoiding typical errors or mistypings.
 - **Full completion in VScode**: if you have vs-haxe installed, you will get full completion while exploring your project file, based on its actual content, right from VScode.

# Usage

## Install

```
haxelib install led-haxe-api
```
## Documentation

Please check the **full documentation and tutorials** here:

https://deepnight.net/docs/led/haxe-api/

## Samples

You can check the sample HX files in [samples](samples) folder.

### Building samples

Samples are built to WebGL/Javascript and Hashlink targets, but you can try them on other platforms too.

To build them, you will first need both **Heaps** and **deepnightLibs** installed:

```
haxelib git heaps https://github.com/HeapsIO/heaps.git
haxelib git deepnightLibs https://github.com/deepnight/deepnightLibs.git
```

Then run:

```
haxe genSamples.hxml
```

This will create all the build files for each sample, then compile all of them.

To run one, use open the corresponding HTML file in a browser. You might need to check the browser console to see some outputs.

If you need to re-compile a single sample:

```
cd samples
haxe SomeSampleName.hxml
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
