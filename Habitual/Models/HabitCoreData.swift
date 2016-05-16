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

/// The `NSManagedObject` for representing a `Habit` in Core Data. This class
/// should only be accessible by the `Habit` class.
@objc(Habit)
public class HabitCoreData: NSManagedObject {
    
    /// The dates on which the habit was completed
    @NSManaged var datesCompletedData: AnyObject
    
    /// The raw value of the `Frequency` at which the habit should be completed.
    @NSManaged var frequencyInt: Int16
    
    /// The habit's server identifier.
    @NSManaged var objectId: String
    
    /// Managed variable for he name of the habit.
    @NSManaged var name: String
    
    /// The time at which the habit was created.
    @NSManaged var createdAt: NSDate
    
    /// Whether the habit is publicly unavailable to all connections except
    /// those that it is accountable to.
    @NSManaged var privat: Bool
    
    /// The `String` value of the time to remind the user to complete the habit.
    /// Empty string (`""`) if the user should never be reminded.
    @NSManaged var remindUserAt: String
    
    /// The `String` value of the time to remind the users to which the habit is
    /// accountable, if the habit has not been completed by that time.
    @NSManaged var notifyConnectionsAt: String
    
    /// The raw value of the `TimeOfDay` at which the habit is aimed to be 
    /// completed.
    @NSManaged var timeOfDayInt: Int16
    
    /// The `Int64` value of the amount of times a habit should be completed per
    /// `Frequency`. This is Int64 to avoid type errors on the pre-64-bit 
    /// devices.
    @NSManaged var timesToCompleteInt: Int64
    
    /// The `String` values of the days on which the habit should be completed.
    /// The format of the days are:
    ///
    ///     Sunday    : "Su"
    ///     Monday    : "M"
    ///     Tuesday   : "T"
    ///     Wednesday : "W"
    ///     Thursday  : "R"
    ///     Friday    : "F"
    ///     Saturday  : "Sa"
    @NSManaged var daysToComplete: [String]
    
    /// The filename of the habit's icon.
    @NSManaged var icon: String
    
    /// The hex value of the habit's color in the form "#RRGGBB".
    @NSManaged var color: String
    
    /// Whether the habit is accountable to any connections.
    @NSManaged var notificationsEnabled: Bool
    
    /// The raw values of the `NotificationSetting`s describing when users to
    /// to which the habit is accountable should be notified.
    @NSManaged var notificationSettingsInts: AnyObject
    
    /// The names of the users to which the habit is accountable.
    @NSManaged var usernamesToNotify: [String]
    
    /// Saves the object to Core Data
    func save() {
        do {
            try managedObjectContext!.save()
        } catch let error as NSError {
            print("awww error: " + error.description)
        }
    }
    
    /// Completely erases the object from Core Data
    func delete() {
        managedObjectContext?.deleteObject(self)
        save()
    }
}
