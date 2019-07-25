![Logo](https://raw.githubusercontent.com/insanoid/SwiftyJSONAccelerator/master/SwiftyJSONAccelerator/Support/Assets.xcassets/AppIcon.appiconset/Icon_32x32%402x.png)

# SwiftyJSONAccelerator - MacOS app `Codeable` Model file Generator For Swift 5

[![Build
Status](https://travis-ci.org/insanoid/SwiftyJSONAccelerator.svg?branch=master)](https://travis-ci.org/insanoid/SwiftyJSONAccelerator) [![codecov](https://codecov.io/gh/insanoid/SwiftyJSONAccelerator/branch/master/graph/badge.svg)](https://codecov.io/gh/insanoid/SwiftyJSONAccelerator)

**Version v2.0 Released! (Swift 5)**

- Generates Swift 5 `Codeable` version along with `CodingKeys`.
- Allows support to switch between `Optional` and non-optional variations.
- Temporarily support for CLI and tests have been removed.
- UI now supports Dark mode!

- **Application Download:** [Download the .app (v2.0.0)](https://github.com/insanoid/SwiftyJSONAccelerator/releases/download/v2.0.0/SwiftyJSONAccelerator.zip)

## Installing & Building

- **Building:**
  ```
  pod install
  ```

- **Application Only:** [Download the .app (v2.0.0)](https://github.com/insanoid/SwiftyJSONAccelerator/releases/download/v2.0.0/SwiftyJSONAccelerator.zip)

## Features

![Logo](https://github.com/insanoid/SwiftyJSONAccelerator/blob/master/preview.png)

A Swift model generator like the Objective-C [JSONAccelerator](http://nerdery.com/json-accelerator). Formats and generates models for the given JSON and also breaks them into files making it easy to manage and share between several models.

- The models that are generated depend Swift's inbuilt `Codeable` feature making encoding and decoding objects a thing of the past.
- Allows to opt for either optional or non-optional variables.
- Allows an array of a certain object type with different properties to be merged into a single model with all properties.
- Click `Load folder with JSON files + Config` to generate all possible models for given folder with JSON files, note this needs a `.config.json` as this uses the CLI logic internally.

## TODO

- CLI tool needs to be recreated
- Tests needed to be added again
- Sparkle integration to deploy newer versions
- Deployment using homebrew
- Add support for [Codextended](https://github.com/JohnSundell/Codextended).

## Older Swift Versions

The older version of the project generating older swift code. Please keep in mind it is **no longer supported**.

- Version v1.4.0 (Swift 3) [Download (v1.5.0)](https://github.com/insanoid/SwiftyJSONAccelerator/releases/download/v1.5.0/SwiftyJSONAccelerator.zip)
- Version v0.0.6 (Swift 2) [Download (v0.0.6)](https://github.com/insanoid/SwiftyJSONAccelerator/releases/download/v0.0.6/SwiftyJSONAccelerator.zip)

## Contributions and Requests

Any suggestions regarding code quality of the app, generated code's quality, Swift related improvements and pull requests are all very welcome. Please make sure you submit the pull request to the next release branch and not the master branch.

## License

[MIT License](LICENSE) / [Karthikeya Udupa](https://karthikeya.co.uk)
