//
//  NotificationSetting.swift
//  Ignite
//
//  Created by Josh Wright on 11/26/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Foundation

/// The setting describing what event needs to happen for a habit's accountable 
/// users to be notified.
public enum NotificationSetting: Int16 {
    
    /// Notifications should never be sent out.
    case None = 0
    
    /// Notifications should be sent out every time a habit is not completed.
    case EveryMiss = 1
    
    /// Notifications should be sent out when a habit is not completed for a
    /// week straight.
    case WeeklyMiss = 2
    
    /// Notifications should be sent out when a habit is completed for a week 
    /// straight.
    case WeeklyStreak = 3
    
    /// All the values in this enum, for iteration purposes.
    static let allValues = [None, EveryMiss, WeeklyMiss, WeeklyStreak]
    
    /// Converts the value to a `String`.
    /// 
    /// - returns: The `String` name of the value.
    public func toString() -> String{
        switch self {
        case None:
            return "None"
        case EveryMiss:
            return "EveryMiss"
        case WeeklyMiss:
            return "WeeklyMiss"
        default:
            return "WeeklyStreak"
        }
    }
    
    /// Converts a `String` to a `NotificationSetting` value. Returns `.None` if
    /// there are no values associated with the `String`
    ///
    /// - parameter name: The name of a value.
    ///
    /// - returns: The value associated with that name.
    public static func notificationSettingForName(name: String) -> NotificationSetting{
        switch name {
        case "None":
            return None
        case "EveryMiss":
            return EveryMiss
        case "WeeklyMiss":
            return WeeklyMiss
        case "WeeklyStreak":
            return WeeklyStreak
        default:
            return None
        }
    }
}
