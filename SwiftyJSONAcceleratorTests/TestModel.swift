//
//  TestModel.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 20/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

public class TestModel {
    
    internal let kTestModelName = ""
    internal let kTestModelValue = ""
    
    var name: NSString?
    var value: Bool?
    var num: Number?
    
    
    convenience init(object: AnyObject) {
        self.init(json: JSON(object))
    }
    
    init(json: JSON) {
        
    }
    
    
    // MARK: NSCoding
    required convenience public init(coder decoder: NSCoder) {
        self.name = decoder.decodeObjectForKey("title") as! String
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.name, forKey: "title")
    }
    
}