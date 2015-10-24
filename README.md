# SwiftyJSONAccelerator

**(Alpha v0.0.2)**

[Download the .app (v0.0.2)](https://github.com/insanoid/SwiftyJSONAccelerator/releases/download/v0.0.2/SwiftyJSONAccelerator.zip)

![Logo](https://raw.githubusercontent.com/insanoid/SwiftyJSONAccelerator/master/SwiftyJSONAccelerator/Assets.xcassets/AppIcon.appiconset/Icon_32x32%402x.png)

A swift model generator like the Objective-C [JSONAccelerator](http://nerdery.com/json-accelerator). Formats and generates models for the given JSON and also breaks them into files making it easy to manage and share between several models. it relies on [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) and requires you to include it in your project.

Currently, the pattern is very similar to its Objective-C counterpart. It generates classes with following properties.

- Initalize with `JSON` (SwiftyJSON based)
- Initalize with `AnyObject`
- `NSCoding` compliant (Can be Archived using `NSKeyedArchiver`)
- Convert to `NSDictionary`
	 
![Preview](https://raw.githubusercontent.com/insanoid/SwiftyJSONAccelerator/master/preview.png)

*Simple configurable interface for generation of file*


![Preview](https://raw.githubusercontent.com/insanoid/SwiftyJSONAccelerator/master/preview_ii.png)

*Files are generated individually making it more easy to use.*

## TODO

- Handle blank array a bit better.
- Better User Interface and icon.
- Generate both `struct` and `class`.
- Support for generation of models that do not need SwiftyJSON.
- Add tests and integrate with Travis CI.
- Create a Xcode plugin and a command line executor.

---

This is one of my very first Swift projects, since I am used to developing models from JSON based APIs in Objective-C and there was no free tool to do this in Swift I created this (with ample inspiration from [SwiftJSON](https://github.com/swiftjson/SwiftJson) and[JSONAccelerator](http://nerdery.com/json-accelerator)). Any suggestions regarding code quality of the app, generated code's quaility, swift improvements and pull requests are all higly welcome.
