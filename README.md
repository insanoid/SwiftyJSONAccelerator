![Logo](https://raw.githubusercontent.com/insanoid/SwiftyJSONAccelerator/master/SwiftyJSONAccelerator/Support/Assets.xcassets/AppIcon.appiconset/Icon_32x32%402x.png)

# SwiftyJSONAccelerator - MacOS app `Codeable` Model file Generator For Swift 5

[![Build
Status](https://travis-ci.org/insanoid/SwiftyJSONAccelerator.svg?branch=master)](https://travis-ci.org/insanoid/SwiftyJSONAccelerator)
![codecov](https://codecov.io/gh/insanoid/SwiftyJSONAccelerator/branch/master/graph/badge.svg)

## Installing & Building

- **Building:**

  ```
  pod install
  ```

  You will also need to install `SwiftFormat` with `brew install swiftformat` and `SwiftLint` with `brew install swiftlint`.

- **Download dmg:** [Download the .app (v2.2.0)](https://github.com/insanoid/SwiftyJSONAccelerator/releases/download/v2.2.0/SwiftyJSONAccelerator.app.zip)

## Features

![Logo](https://github.com/insanoid/SwiftyJSONAccelerator/blob/master/preview.png)

A Swift model generator like the Objective-C [JSONAccelerator](http://nerdery.com/json-accelerator). Formats and generates models for the given JSON and also breaks them into files making it easy to manage and share between several models.

- The models that are generated depend Swift's inbuilt `Codeable` feature making encoding and decoding objects a thing of the past.
- Allows to opt for either optional or non-optional variables.
- Allows an array of a certain object type with different properties to be merged into a single model with all properties.
- Click `Load folder with JSON files + Config` to generate all possible models for given folder with JSON files, note this needs a `.config.json` as this uses the CLI logic internally.

## Contributions and Requests

Any suggestions regarding code quality of the app, generated code's quality, Swift related improvements and pull requests are all very welcome. Please make sure you submit the pull request to the next release branch and not the master branch.

- [Contributing Guidelines](.github/contributing.md)
- [Code of Conduct](.github/CODE_OF_CONDUCT.md)

## License

[MIT License](LICENSE.md) / [Karthikeya Udupa](https://karthikeya.co.uk)
