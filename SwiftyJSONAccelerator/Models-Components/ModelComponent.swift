//
//  ModelComponent.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 09/07/2016.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

/**
 *  A strcture to store the various components of a model file.
 */
internal struct ModelComponent {

  /// Declaration of properties.
  var declarations: [String]
  /// String constants to store the keys.
  var stringConstants: [String]
  /// Initialisers for the properties.
  var initialisers: [String]
  /// Encoders for NSCoding support.
  var encoders: [String]
  /// Decoders for NSCoding support.
  var decoders: [String]
  /// Description printer for each of the properties.
  var description: [String]

  /**
   Initialise a blank model component structure.
   */
  init() {
    declarations = []
    stringConstants = []
    initialisers = []
    encoders = []
    decoders = []
    description = []
  }
}
