//
//  Frequency.swift
//  Ignite
//
//  Created by Josh Wright on 11/26/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Foundation

public enum Frequency: Int16 {
    case Daily = 0
    case Weekly = 1
    case Monthly = 2
    
    static let allValues = [Daily, Weekly, Monthly]
    
    public func name() -> String{
        switch self {
        case .Daily:
            return "Daily"
        case .Weekly:
            return "Weekly"
        default:
            return "Monthly"
        }
    }
    
    public static func frequencyForName(name: String) -> Frequency {
        switch name {
        case "Daily":
            return .Daily
        case "Weekly":
            return .Weekly
        default:
            return .Monthly
        }
    }
}
