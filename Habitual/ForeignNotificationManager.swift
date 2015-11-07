//
//  ForeignNotificationManager.swift
//  Habitual
//
//  Created by Josh Wright on 7/24/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit
import Parse
import Timepiece

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

public class ForeignNotificationManager: NSObject {
    
    public static func uploadHabitForCurrentUser(habit: Habit) {

        guard let user = AuthManager.currentUser else {
            print("ERROR! User is not loaded!")
            return
        }
        
        let push = PFObject(className: "Habit")
        
        push["owner"] = user.username
        push["targetUsernames"] = habit.usernamesToNotify
        push["name"] = habit.name
        
        push["daysToComplete"] = habit.daysToComplete
        push["timesToComplete"] = habit.timesToComplete

        var due = NSDate()
        
        switch habit.frequency {
        case .Daily:
            due = due.endOfDay
        case .Weekly:
            due = due.endOfWeek
        case .Monthly:
            due = due.endOfMonth
        }
        
        push["due"] = due
        push["frequency"] = habit.frequency.name()
        
        push.saveInBackground()
    }
    
    public static func updateHabitForCurrentUser(habit: Habit, originalName: String) {

        guard let user = AuthManager.currentUser else {
            print("ERROR! User is not loaded!")
            return
        }
        
        let query: PFQuery = PFQuery(className: "Habit")
        query.whereKey("owner", equalTo: user.username)
        query.whereKey("name", equalTo: originalName)
        query.findObjectsInBackgroundWithBlock { (array, error) -> Void in
            
            if error == nil {
                let push: PFObject = (array?.first)!
                
                push["owner"] = user.username
                push["targetUsernames"] = habit.usernamesToNotify
                push["name"] = habit.name
                push["due"] = habit.dueOn()
                push["frequency"] = habit.frequency.name()
                
                push["daysToComplete"] = habit.daysToComplete
                push["timesToComplete"] = habit.timesToComplete
                
                push.saveInBackground()
            }
        }
    }
    
    public static func deleteHabitForCurrentUser(habit: Habit) {
        
        guard let user = AuthManager.currentUser else {
            print("ERROR! User is not loaded!")
            return
        }
        
        let query: PFQuery = PFQuery(className: "Habit")
        query.whereKey("owner", equalTo: user.username)
        query.whereKey("name", equalTo: habit.name)
        query.findObjectsInBackgroundWithBlock { (array, error) -> Void in

            if error == nil {
                array?.first?.deleteInBackground()
            }
        }
    }
    
    public static func completeHabitForCurrentUser(habit: Habit) {
        
        guard let user = AuthManager.currentUser else {
            print("ERROR! User is not loaded!")
            return
        }
        
        let query: PFQuery = PFQuery(className: "Habit")
        query.whereKey("owner", equalTo: user.username)
        query.whereKey("name", equalTo: habit.name)
        query.findObjectsInBackgroundWithBlock { (array, error) -> Void in
            
            if (error == nil) {
                let object: PFObject = (array?.first)!
                
                object["due"] = habit.dueOn()
                
                object.saveInBackground()
            }
        }
        
    }
    
    public static func uncompleteHabitForCurrentUser(habit: Habit) {
        
        guard let user = AuthManager.currentUser else {
            print("ERROR! User is not loaded!")
            return
        }
        
        let query: PFQuery = PFQuery(className: "Habit")
        query.whereKey("owner", equalTo: user.username)
        query.whereKey("name", equalTo: habit.name)
        query.findObjectsInBackgroundWithBlock { (array, error) -> Void in
            
            if (error == nil) {
                let object: PFObject = (array?.first)!
                
                object["due"] = habit.dueOn()
                
                object.saveInBackground()
            }
        }
        
    }


}
