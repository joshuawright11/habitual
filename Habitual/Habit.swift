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

// 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
// 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
// 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
// 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
// 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
// 💩💩💩💩💩💩💩CLEAN  ME💩💩💩💩💩💩💩💩
// 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
// 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
// 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
// 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
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
    
    @NSManaged var privat: Bool
    
    @NSManaged var remindAt: String
    
    @NSManaged var timeOfDay: Int16
    
    @NSManaged var timesToComplete: Int
    
    @NSManaged var daysToComplete: [String]
    
    @NSManaged var icon: String
    
    @NSManaged var color: String
    
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
        
//        privat = json["private"].boolValue
        
        remindAt = json["remindAt"].stringValue
        
        timeOfDay = json["timeOfDay"].int16Value
        
        timesToComplete = json["timesToComplete"].intValue
        
        daysToComplete = json["daysToComplete"].arrayObject as! [String]
        
        color = json["color"].stringValue
        
        icon = json["icon"].stringValue
    }
    
    init() {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let ed = NSEntityDescription.entityForName("Habit", inManagedObjectContext: managedObjectContext!)
        super.init(entity: ed!, insertIntoManagedObjectContext: managedObjectContext)
        
        createdAt = NSDate()
        icon = "flash"
        color = kColorPurple.hexString
        name = ""
        frequency = .Daily
        daysToComplete = ["M","T","W","R","F","Sa","Su"]
        timesToComplete = 1
        datesCompleted = []
        notificationsEnabled = false
        notificationSetting = .EveryMiss
        usernamesToNotify = []
    }
    
    static func deleteHabit(habit: Habit) {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        managedObjectContext?.deleteObject(habit)
    }
    
    public func toJSON() -> JSON {
        
        let json:JSON = JSON([
            "name":name,
            "repeat":frequency.name(),
            "datesCompleted":datesCompleted,
            "notificationsEnabled":notificationsEnabled,
            "notificationSetting":notificationSetting.toString(),
            "usernamesToNotify":usernamesToNotify,
            "createdAt":Utilities.stringFromDate(createdAt),
            "private":false,
            "remindAt":"",
            "timeOfDay":0,
            "timesToComplete":timesToComplete,
            "daysToComplete":daysToComplete,
            "":"",
            "":""])
        return json
    }
    
    public func availableOn(date: NSDate) -> Bool {
        
        if createdAt.beginningOfDay > date {return false}
        
        if(frequency == .Daily) {
            let dsotw = ["Su","M","T","W","R","F","Sa"]
            
            let dayOfWeek = dsotw[date.weekday-1]
            
            if !daysToComplete.contains(dayOfWeek) {return false}
        }
        
        return true
    }
    
    public func canDo() -> Bool { return canDoOn(NSDate()) }
    
    public func canDoOn(date: NSDate) -> Bool {
        
        if createdAt.endOfDay < date.beginningOfDay {return false}
        
        if datesCompleted.count == 0 {return true}
        
        if(frequency == .Daily) {
            let dsotw = ["Su","M","T","W","R","F","Sa"]
            
            let dayOfWeek = dsotw[date.weekday-1]
            
            if !daysToComplete.contains(dayOfWeek) {return false}
        }
        
        let timesLeft = countDoneInDate(date) < timesToComplete
        
        return timesLeft
    }
    
    public func countDoneInDate(date: NSDate) -> Int {
        
        var count = 0
        
        let first: NSDate, last: NSDate
        
        switch frequency {
        case .Daily:
            first = date.beginningOfDay
            last = date.endOfDay
        case .Weekly:
            first = date.beginningOfWeek
            last = date.endOfWeek
        case .Monthly:
            first = date.beginningOfMonth
            last = date.endOfMonth
        }
        
        for completion: NSDate in datesCompleted {
            if(first...last).contains(completion) {count++}
        }
        
        return count
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
    
    public func countCompletedOn(date: NSDate) -> Int {
        
        var count = 0
        
        for completion: NSDate in datesCompleted {
            if(completion.beginningOfDay...completion.endOfDay).contains(date) {count++}
        }
        
        return count
    }
    
    public func countCompletedIn(date: NSDate, freq: Frequency) -> Int {
        
        var count = 0
        
        for completion: NSDate in datesCompleted {
            
            let first: NSDate, last: NSDate
            switch frequency {
            case .Daily:
                first = completion.beginningOfDay
                last = completion.endOfDay
            case .Weekly:
                first = completion.beginningOfWeek
                last = completion.endOfWeek
            case .Monthly:
                first = completion.beginningOfMonth
                last = completion.endOfMonth
            }
            
            if(first...last).contains(date) {count++}
        }
        
        return count
    }
    
    // uncomplete a habit on a certain date
    public func uncompleteOn(date: NSDate) {
        for completion: NSDate in datesCompleted {
            if(completion.beginningOfDay...completion.endOfDay).contains(date) {
                if let index = datesCompleted.indexOf(completion) {
                    datesCompleted.removeAtIndex(index)
                    return
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
        
        let countDone = countCompletedIn(lastCompletedOn, freq: frequency)
        
        if countDone < timesToComplete {
            switch frequency {
            case .Daily:
                return lastCompletedOn.endOfDay
            case .Weekly:
                return lastCompletedOn.endOfWeek
            case .Monthly:
                return lastCompletedOn.endOfMonth
            }
        }
        
        switch frequency {
        case .Daily:
            return lastCompletedOn.endOfDay + 1.day
        case .Weekly:
            return lastCompletedOn.endOfWeek + 1.week
        case .Monthly:
            return lastCompletedOn.endOfMonth + 1.month
        }
    }
    
    public func getCompletionPercentage() -> Double{
        // calculate number of units
        
        let today = NSDate()
        
        let startOfFirstInterval: NSDate
        switch frequency {
        case .Daily:
            startOfFirstInterval = createdAt.beginningOfDay
        case .Weekly:
            startOfFirstInterval = createdAt.beginningOfWeek
        case .Monthly:
            startOfFirstInterval = createdAt.beginningOfMonth
        }
        
        let daysSinceBegan = (today.endOfDay.timeIntervalSinceDate(startOfFirstInterval))/86400
        let unitsSinceBegan: Double
        
        switch frequency {
        case .Daily:
            
            if daysToComplete.count < 7 {
                var days = 0
                var date = createdAt.beginningOfDay
                
                let dsotw = ["Su","M","T","W","T","F","Sa"]
                
                while(date < NSDate()) {
                    if(daysToComplete.contains(dsotw[date.weekday-1])) {
                        days++
                    }
                    date = date + 1.day
                }
                unitsSinceBegan = days == 0 ? Double(1) : Double(days)
                
            }else{
                unitsSinceBegan = ceil(daysSinceBegan)
            }
        case .Weekly:
            unitsSinceBegan = ceil(daysSinceBegan/7)
        case .Monthly:
            unitsSinceBegan = ceil(daysSinceBegan/30.417)
        }
        
        let perc = (Double(datesCompleted.count)/unitsSinceBegan)*100.0
        return perc/Double(timesToComplete)
    }
    
    func save() {
        do {
            try managedObjectContext?.save()
        } catch let error as NSError {
            print("awww error: " + error.description)
        }
    }
    
    func delete() {
        managedObjectContext?.deleteObject(self)
        ForeignNotificationManager.deleteHabitForCurrentUser(self)
        Utilities.postNotification(kNotificationIdentifierHabitAddedOrDeleted)
    }
}
