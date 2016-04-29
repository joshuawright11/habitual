//
//  Frequency.swift
//  Ignite
//
//  Created by Josh Wright on 11/26/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Foundation

/// The frequency at which a habit should be repeated.
public enum Frequency: Int16 {
    
    case Daily = 0
    case Weekly = 1
    case Monthly = 2

    /// All the values in this enum, for iteration purposes.
    static let allValues = [Daily, Weekly, Monthly]
    
    /// Converts the value to a `String`.
    ///
    /// - returns: The `String` name of the value.
    public func toString() -> String{
        switch self {
        case Daily:
            return "Daily"
        case Weekly:
            return "Weekly"
        default:
            return "Monthly"
        }
    }
    
    /// Converts a `String` to a `Frequency` value. Returns `.None` if
    /// there are no values associated with the `String`
    ///
    /// - parameter name: The name of a value.
    ///
    /// - returns: The value associated with that name.
    public static func frequencyForName(name: String) -> Frequency {
        switch name {
        case "Daily":
            return Daily
        case "Weekly":
            return Weekly
        case "Monthly":
            return Monthly
        default:
            return Daily
        }
    }
}
