//
//  Habit.swift
//  Habitual
//
//  Created by Josh Wright on 7/11/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import Foundation
import CoreData

enum Repeat: Int {
    case Daily = 0
    case Weekly = 1
    case Monthly = 2
}

@objc(Habit)
public class Habit: NSManagedObject {
    
    @NSManaged var datesCompleted: AnyObject
    @NSManaged var repeat: Int
    @NSManaged var name: String

}
