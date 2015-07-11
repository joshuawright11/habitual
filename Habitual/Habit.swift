//
//  Habit.swift
//  Habitual
//
//  Created by Josh Wright on 7/11/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import Foundation
import CoreData

@objc(Habit)
class Habit: NSManagedObject {

    @NSManaged var datesCompleted: AnyObject
    @NSManaged var repeat: NSNumber
    @NSManaged var name: String

}
