//
//  TimeOfDay.swift
//  Ignite
//
//  Created by Josh Wright on 11/26/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Foundation

/// The time of day that the habit is aimed to be completed.
public enum TimeOfDay: Int16 {
    
    case Morning = 0
    case Afternoon = 1
    case Evening = 2
    
    /// Converts the value to a `String`.
    ///
    /// - returns: The `String` name of the value.
    public func toString() -> String{
        switch self {
        case .Morning:
            return "Morning"
        case .Afternoon:
            return "Afternoon"
        default:
            return "Evening"
        }
    }
}
