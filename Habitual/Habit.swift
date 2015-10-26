//
//  Habit.swift
//  Habitual
//
//  Created by Josh Wright on 7/11/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import Foundation
import CoreData
import Timepiece
import SwiftyJSON

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
    
    public static func frequencyForName(name: String) -> Frequency{
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

@objc(Habit)
public class Habit: NSManagedObject {
    
    @NSManaged var datesCompletedData: AnyObject
    var datesCompleted: [NSDate] {
        get{return datesCompletedData as? [NSDate] ?? []}
        set{datesCompletedData = newValue}
    }
    
    @NSManaged var frequencyInt: Int16
    var frequency:Frequency { // Wrapper because enums can't be saved in Core Data
        get{return Frequency(rawValue: frequencyInt) ?? .Daily}
        set{frequencyInt = newValue.rawValue}
    }
    
    @NSManaged var name: String
    
    @NSManaged var createdAt: NSDate
    
    // Mark: - Notification data
    
    @NSManaged var notificationsEnabled: Bool
    
    @NSManaged var notificationSettingInt: Int16
    var notificationSetting:NotificationSetting { // Wrapper because enums can't be saved in Core Data
        get{return NotificationSetting(rawValue: notificationSettingInt) ?? .None}
        set{notificationSettingInt = newValue.rawValue}
    }
    
    @NSManaged var usernamesToNotify: [String]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(json: JSON) {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let ed = NSEntityDescription.entityForName("Habit", inManagedObjectContext: managedObjectContext!)
        
        super.init(entity: ed!, insertIntoManagedObjectContext: nil)
        
        datesCompletedData = json["datesCompleted"].arrayObject!
        
        frequencyInt = Frequency.frequencyForName(json["repeat"].stringValue).rawValue
        
        name = json["name"].stringValue
        
        let string = json["createdAt"].stringValue
        
        createdAt = Utilities.dateFromString(string)
    }
    
    public func toJSON() -> JSON {
        
        let json:JSON = JSON([
            "name":name,
            "repeat":frequency.name(),
            "datesCompleted":datesCompleted,
            "notificationsEnabled":notificationsEnabled,
            "notificationSetting":notificationSetting.toString(),
            "usernamesToNotify":usernamesToNotify,
            "createdAt":Utilities.stringFromDate(createdAt)])
        return json
    }
    
    public func canDo() -> Bool {
        
        if datesCompleted.count == 0 {return true}
        
        let last = datesCompleted.sort().last
        
        switch frequency {
        case Frequency.Daily:
            if(last < NSDate.today()) {return true}
        case Frequency.Weekly:
            if(last < NSDate.today().change(weekday: 1)) {return true}
        case Frequency.Monthly:
            if(last < NSDate.today().beginningOfMonth) {return true}
        }
        
        return false
    }
    
    public func longestStreak() -> Int {
        var longestStreak = 0
        
        var prevDate: NSDate?
        for date:NSDate in datesCompleted.sort() {
            if prevDate == nil {
                prevDate = date
                longestStreak = 1
            }else{
                if date.day - prevDate!.day == 1{
                    longestStreak += 1
                }else{
                    longestStreak = 1
                }
                prevDate = date
            }
        }
        
        return longestStreak
    }
    
    public func currentStreak() -> Int {

        if datesCompleted.count == 0 {
            return 0
        } else {
            
            let today: NSDate = (NSDate().beginningOfDay - 1.day)
            var nextDate = datesCompleted.last!
            
            if nextDate < today {
                return 0;
            }else{
                var streak = 1
                for var i = datesCompleted.count - 2; i > 0; i-- {
                    
                    let dateToCheck = datesCompleted[i]
                    
                    if(dateToCheck < nextDate.beginningOfDay - 1.day) {
                        return streak
                    }else{
                        streak++
                        nextDate = dateToCheck
                    }
                }
                return streak
            }
        }
    }
    
    
    // return true if the habit was completed that day
    public func completedOn(date: NSDate) -> Bool {
        
        for completion: NSDate in datesCompleted {
            if(completion.beginningOfDay...completion.endOfDay).contains(date) {return true}
        }
        
        return false
    }
    
    // uncomplete a habit on a certain date
    public func uncompleteOn(date: NSDate) {
        for completion: NSDate in datesCompleted {
            if(completion.beginningOfDay...completion.endOfDay).contains(date) {
                if let index = datesCompleted.indexOf(completion) {
                    datesCompleted.removeAtIndex(index)
                }
            }
        }
    }
    
    // return true if completing a habit on this date would alter future push notifications
    // based on frequency
    public func dateInCurrentFrequency(date: NSDate) -> Bool {

        let now = NSDate()
        
        switch frequency {
        case .Daily:
            return date >= now.beginningOfDay
        case .Weekly:
            return date >= now.beginningOfWeek
        case .Monthly:
            return date >= now.beginningOfMonth
        }
    }
    
    public func dueOn() -> NSDate {
        if datesCompleted.count < 1 {
            switch frequency {
            case .Daily:
                return createdAt.endOfDay
            case .Weekly:
                return createdAt.endOfWeek
            case .Monthly:
                return createdAt.endOfMonth
            }
        }
        
        let lastCompletedOn = datesCompleted.sort().last!
        
        switch frequency {
        case .Daily:
            return lastCompletedOn.endOfDay + 1.day
        case .Weekly:
            return lastCompletedOn.endOfWeek + 1.week
        case .Monthly:
            return lastCompletedOn.endOfMonth + 1.month
        }
    }
}
