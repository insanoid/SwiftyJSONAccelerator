# SwiftyJSONAccelerator
[![Build Status](https://travis-ci.org/insanoid/SwiftyJSONAccelerator.svg?branch=issues%2F28-fix-code-base)](https://travis-ci.org/insanoid/SwiftyJSONAccelerator) [![codecov](https://codecov.io/gh/insanoid/SwiftyJSONAccelerator/branch/issues%2F28-fix-code-base.svg)](https://codecov.io/gh/insanoid/SwiftyJSONAccelerator)

**(Alpha v0.0.6)**

[Download the .app (v0.0.6)](https://github.com/insanoid/SwiftyJSONAccelerator/releases/download/v0.0.6/SwiftyJSONAccelerator.zip)

![Logo](https://raw.githubusercontent.com/insanoid/SwiftyJSONAccelerator/master/SwiftyJSONAccelerator/Assets.xcassets/AppIcon.appiconset/Icon_32x32%402x.png)

A swift model generator like the Objective-C [JSONAccelerator](http://nerdery.com/json-accelerator). Formats and generates models for the given JSON and also breaks them into files making it easy to manage and share between several models.

The models that are generated depend on JSON object mapping libraries, currently the model can be generated to depend on any of the below mentioned mapping libraries:

- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
- [Hearst-DD/ObjectMapper](https://github.com/Hearst-DD/ObjectMapper) (Contributed by: [brendan09](https://github.com/brendan09))

Currently, the pattern is very similar to its Objective-C counterpart. It generates classes with following properties.

- Initalize with `JSON` (SwiftyJSON or ObjectMapper)
- Initalize with `AnyObject`
- Optional `NSCoding` compliance.
- Convert object to `NSDictionary`

![Preview](https://raw.githubusercontent.com/insanoid/SwiftyJSONAccelerator/master/preview.png)

*Simple configurable interface for generation of file*


![Preview](https://raw.githubusercontent.com/insanoid/SwiftyJSONAccelerator/master/preview_ii.png)

*Each class in the JSON is generated as a file.*

## TODO

- Handle blank array a bit better.
- Better User Interface and icon.
- Generate both `struct` and `class`.
- Support for further JSON object modelling libraries.
- Add tests and integrate with Travis CI.
- Create a Xcode plugin and a command line executor.

---
Any suggestions regarding code quality of the app, generated code's quaility, Swift related improvements and pull requests are all very welcome.
