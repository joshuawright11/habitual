//
//  ParseObject.swift
//  Ignite
//
//  Created by Josh Wright on 11/18/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import Parse

public class ParseObject: NSObject {
    var parseObject: PFObject?
    
    override init() {
        self.parseObject = nil
        super.init()
    }
    
    init(parseObject: PFObject) {
        self.parseObject = parseObject
        super.init()
    }
}
