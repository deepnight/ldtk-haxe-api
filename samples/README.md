# About samples

This folder contains all the samples & demo for the Haxe API.

# Usage

To build samples, you first need to run the ``genSamples.hxml`` from the parent folder:

```
haxe genSamples.hxml
```

This script will generate the HXMLs for each sample that is used to build and execute it.

To build a sample (for example, "HeapsAutoLayer"):

```
cd samples
haxe HeapsAutoLayer.hxml
```

# Optional: Heaps

All Heaps samples will require the Heaps framework installed:

```
haxelib git heaps https://github.com/HeapsIO/heaps.git
```