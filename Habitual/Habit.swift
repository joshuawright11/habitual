//
//  Habit.swift
//  Ignite
//
//  Created by Josh Wright on 11/25/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Timepiece
import SwiftyJSON
import Parse

public class Habit: ParseObject {

    var coreDataObject:HabitCoreData?

    var objectId: String {
        get{
            return coreDataObject!.objectId
        }
    }
    
    var datesCompleted: [NSDate]
    var frequency:Frequency
    var name: String
    var createdAt: NSDate
    var privat: Bool
    var remindUserAt: String
    var notifyConnectionsAt: String
    var timeOfDay: TimeOfDay
    var timesToComplete: Int
    var daysToComplete: [String]
    var icon: String
    var color: String
    var notificationsEnabled: Bool
    var notificationSettings:[NotificationSetting]
    var usersToNotify: [User]
    
    override init() {
        self.coreDataObject = nil
        
        datesCompleted = []
        frequency = .Daily
        name = ""
        createdAt = NSDate()
        privat = false
        remindUserAt = ""
        notifyConnectionsAt = ""
        timeOfDay = .Morning
        timesToComplete = 1
        daysToComplete = ["M","T","W","R","F","Sa","Su"]
        icon = "compass"
        color = kColorPurple.hexString
        notificationsEnabled = false
        notificationSettings = [.None]
        usersToNotify = []
        
        super.init()
    }
    
    override init(parseObject: PFObject) {
        coreDataObject = nil
        
        datesCompleted = parseObject["datesCompleted"] as! [NSDate]
        frequency = Frequency.frequencyForName(parseObject["frequency"] as! String)
        name = parseObject["name"] as! String
        createdAt = parseObject["creationDate"] as! NSDate
        privat = false
        remindUserAt = ""
        notifyConnectionsAt = ""
        timeOfDay = .Morning
        timesToComplete = parseObject["timesToComplete"] as! Int
        daysToComplete = parseObject["daysToComplete"] as! [String]
        icon = parseObject["icon"] as! String
        color = parseObject["color"] as! String
        notificationsEnabled = parseObject["notificationsEnabled"] as! Bool
        notificationSettings = [.None]
        usersToNotify = []
        for userPO in parseObject["usersToNotify"] as! [PFUser] {
            if(userPO.dataAvailable){
                usersToNotify.append(User(parseUser: userPO, withHabits: false))
            }
        }
        
        super.init(parseObject: parseObject)
    }
    
    init(coreDataObject: HabitCoreData) {
        self.coreDataObject = coreDataObject
        
        datesCompleted = coreDataObject.datesCompleted
        frequency = coreDataObject.frequency
        name = coreDataObject.name
        createdAt = coreDataObject.createdAt
        privat = coreDataObject.privat
        remindUserAt = coreDataObject.remindUserAt
        notifyConnectionsAt = coreDataObject.notifyConnectionsAt
        timeOfDay = TimeOfDay(rawValue: coreDataObject.timeOfDayInt)!
        timesToComplete = coreDataObject.timesToComplete
        daysToComplete = coreDataObject.daysToComplete
        icon = coreDataObject.icon
        color = coreDataObject.color
        notificationsEnabled = coreDataObject.notificationsEnabled
        notificationSettings = coreDataObject.notificationSettings
        usersToNotify = []
        
        super.init()
    }
    
    // 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
    // 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
    // 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
    // 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
    // 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
    // 💩💩💩💩💩💩 CLEAN ME    💩💩💩💩💩💩
    // 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
    // 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
    // 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
    // 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
    // 💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩💩
    
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
}
