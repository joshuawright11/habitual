//
//  TimeOfDay.swift
//  Ignite
//
//  Created by Josh Wright on 11/26/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Foundation

public enum TimeOfDay: Int16 {
    case Morning = 0
    case Afternoon = 1
    case Evening = 2
    
    public func name() -> String{
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
