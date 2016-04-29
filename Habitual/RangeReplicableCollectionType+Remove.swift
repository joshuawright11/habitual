//
//  RangeReplicableCollectionType+Remove.swift
//  Ignite
//
//  Created by Josh Wright on 4/28/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import Foundation

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}
