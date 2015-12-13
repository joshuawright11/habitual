//
//  ParseObject.swift
//  Ignite
//
//  Created by Josh Wright on 11/18/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import Parse

/// An base object for all model objects that are based off of a 'PFObject'.
/// This should never be instantiated.
public class ParseObject: NSObject {

    /// The `PFObject` parse object that this object is a representation of.
    var parseObject: PFObject?
    
    /// Basic initializer that sets the parseObject to nil. Used when creating
    /// objects in the app that will be saved to the server, but not yet.
    override init() {
        self.parseObject = nil
        super.init()
    }
    
    /// Initialize with a Parse `PFObject` object.
    ///
    /// - parameter parseObject: The `PFObject` object with which to initialize.
    init(parseObject: PFObject) {
        self.parseObject = parseObject
        super.init()
    }
}
