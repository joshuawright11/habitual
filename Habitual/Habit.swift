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
    
    public static func repeatForName(name: String) -> Repeat{
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
    
    @NSManaged var repeatInt: Int16
    var repeat:Repeat { // Wrapper because enums can't be saved in Core Data
        get{return Repeat(rawValue: repeatInt) ?? .Daily}
        set{repeatInt = newValue.rawValue}
    }
    
    @NSManaged var name: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(json: JSON) {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let ed = NSEntityDescription.entityForName("Habit", inManagedObjectContext: managedObjectContext!)
        
        super.init(entity: ed!, insertIntoManagedObjectContext: nil)
        
        datesCompletedData = json["datesCompleted"].arrayObject!
        
        repeatInt = Repeat.repeatForName(json["repeat"].stringValue).rawValue
        
        name = json["name"].stringValue
    }
    
    public func toJSON() -> JSON {
        
        var json:JSON = JSON([
            "name":name,
            "repeat":repeat.name(),
            "datesCompleted":datesCompleted])
        return json
    }
    
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
