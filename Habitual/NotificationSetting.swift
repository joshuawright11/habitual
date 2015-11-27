//
//  NotificationSetting.swift
//  Ignite
//
//  Created by Josh Wright on 11/26/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Foundation

public enum NotificationSetting: Int16 {
    case None = 0
    case EveryMiss = 1
    case WeeklyMiss = 2
    case WeeklyStreak = 3
    
    static let allValues = [None, EveryMiss, WeeklyMiss, WeeklyStreak]
    
    public func toString() -> String{
        switch self {
        case .None:
            return "None"
        case .EveryMiss:
            return "EveryMiss"
        case .WeeklyMiss:
            return "WeeklyMiss"
        default:
            return "WeeklyStreak"
        }
    }
    
    public static func notificationSettingForName(name: String) -> NotificationSetting{
        switch name {
        case "None":
            return .None
        case "EveryMiss":
            return .EveryMiss
        case "WeeklyMiss":
            return .WeeklyMiss
        default:
            return .WeeklyStreak
        }
    }
}
