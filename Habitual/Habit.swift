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

public enum Repeat: Int16 {
    case Daily = 0
    case Weekly = 1
    case Monthly = 2
    
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
}

@objc(Habit)
public class Habit: NSManagedObject {
    
    @NSManaged var datesCompletedData: AnyObject
    var datesCompleted: [NSDate] {
        get{return datesCompletedData as? [NSDate] ?? []}
        set{datesCompletedData = newValue}
    }
    
    @NSManaged var repeatInt: Int16
    var repeat:Repeat { // Wrapper because enums can't be saved in Core Data
        get{return Repeat(rawValue: repeatInt) ?? .Daily}
        set{repeatInt = newValue.rawValue}
    }
    
    @NSManaged var name: String
    
    public func canDo() -> Bool{
        
        if datesCompleted.count == 0 {return true}
        
        let last = datesCompleted.last
        
        switch repeat {
        case Repeat.Daily:
            if(last < NSDate.today()) {return true}
        case Repeat.Weekly:
            if(last < NSDate.today().change(weekday: 1)) {return true}
        case Repeat.Monthly:
            if(last < NSDate.today().beginningOfMonth) {return true}
        }
        
        return false
    }
    
    public func longestStreak() -> Int {
        var longestStreak = 0
        
        var prevDate: NSDate?
        for date:NSDate in datesCompleted {
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
        // TODO incomplete
        return 0
    }
}
