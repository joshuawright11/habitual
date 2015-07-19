//
//  Habit.swift
//  Habitual
//
//  Created by Josh Wright on 7/11/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import Foundation
import CoreData

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

}
