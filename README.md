# About

## What is this?

This is the Haxe API to load **LEd Project JSON** files.

*LEd is a modern and open-source 2D level editor.*

[LEd official page](https://deepnight.net/tools/led-2d-level-editor) |
[Documentation](https://deepnight.net/docs/led-documentation/haxe-api)

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

https://deepnight.net/docs/led-documentation/haxe-api/

## Demo & samples

You can check the sample HX files in [samples](samples) folder. You can also build them by following these simple steps:

Step 1: Generate the HXML files for each sample:

```
haxe genSamples.hxml
```

Step 2: Build & test a sample (requires HashLink):

```
cd samples
haxe SomeSampleName.hxml
```
