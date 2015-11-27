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

@objc(Habit)
public class HabitCoreData: NSManagedObject {
    
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
    
    @NSManaged var objectId: String
    @NSManaged var name: String
    @NSManaged var createdAt: NSDate
    @NSManaged var privat: Bool
    @NSManaged var remindUserAt: String
    @NSManaged var notifyConnectionsAt: String
    @NSManaged var timeOfDayInt: Int16
    
    var timesToComplete: Int {
        get{ return Int(timesToCompleteInt)}
        set(newVal){timesToCompleteInt = Int64(newVal)}
    }
    
    @NSManaged var timesToCompleteInt: Int64
    @NSManaged var daysToComplete: [String]
    @NSManaged var icon: String
    @NSManaged var color: String
    // Mark: - Notification data
    @NSManaged var notificationsEnabled: Bool
    @NSManaged var notificationSettingsInts: AnyObject
    var notificationSettings:[NotificationSetting] { // Wrapper because enums can't be saved in Core Data
        get{return [.None]}
        set{notificationSettingsInts = []}
    }
    @NSManaged var usernamesToNotify: [String]
    
    func save() {
        do {
            try managedObjectContext?.save()
        } catch let error as NSError {
            print("awww error: " + error.description)
        }
    }
    
    func delete() {
        managedObjectContext?.deleteObject(self)
        save()
    }
}
