//
//  HabitRepository.swift
//  Ignite
//
//  Created by Josh Wright on 4/1/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import UIKit
import Parse
import CoreData

internal class HabitRepository: NSObject {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    internal var habits: [Habit] = []
    
    private var habitCoreDataObjects:[Habit : HabitCoreData] = [:]
    private var habitParseObjects:[Habit : PFObject] = [:]
    
    override init() {
        super.init()
        // attempt to load from coredata
        habits = getHabitsOfCurrentUser()
    }
    
    internal func createHabit(habit: Habit) {
        addToCoreData(habit)
        uploadToServer(habit, callback: nil)
        habits.append(habit)
    }
    
    internal func deleteHabit(habit: Habit) {
        deleteFromCoreData(habit)
        habits.removeObject(habit)
    }
    
    internal func updateHabit(habit: Habit) {
        updateCoreData(habit)
    }
    
    internal func orderHabits(habits: [Habit]) {
        for index in 0...habits.count - 1 {
            let habit = habits[index]
            habit.timeOfDay = index
            saveToCoreData(habit)
        }
    }
    
    internal func isTracking(habit: Habit) -> Bool {
        return habits.contains(habit)
    }
    
    private func loadHabitsFromCoreData() {
        
    }
}

private extension HabitRepository {

    private func getHabitsOfCurrentUser() -> [Habit]{
        let entityDescription = NSEntityDescription.entityForName("Habit",
                                              inManagedObjectContext: managedObjectContext!)
        let request = NSFetchRequest()
        request.entity = entityDescription
        
        var error: NSError?
        var objects: [AnyObject]?
        do {
            objects = try managedObjectContext?.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            print("Error: \(error?.description)")
            objects = nil
        }
        
        var habits:[Habit] = []
        if let results = objects {
            if results.count > 0 {
                for result in results{
                    let coreDataObject = result as! HabitCoreData
                    let habit = Habit(coreDataObject: coreDataObject)
                    habits.append(habit)
                    habitCoreDataObjects[habit] = coreDataObject
                }
            }
        }
        return habits;
    }
    
    private func clearHabitsOfCurrentUser() {
        let entityDescription = NSEntityDescription.entityForName("Habit",
                                              inManagedObjectContext: managedObjectContext!)
        let request = NSFetchRequest()
        request.entity = entityDescription
        var error: NSError?
        var objects: [AnyObject]?
        do {
            objects = try managedObjectContext?.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            print("Error: \(error?.description)")
            objects = nil
        }

        if let results = objects {
            if results.count > 0 {
                for result in results{
                    let habit = result as! HabitCoreData
                    managedObjectContext?.deleteObject(habit)
                }
                do {
                    try managedObjectContext?.save()
                } catch _ {
                
                }
                habits = [];
            }
        }
    }
}

internal extension Habit {
    
    /// Initialize with a Parse `PFObject` object.
    ///
    /// - parameter parseObject: The `PFObject` object with which to initialize.
    convenience init?(parseObject: PFObject) {
        
        self.init()
        
        guard parseObject.dataAvailable else {
            return nil
        }
        
        datesCompleted = parseObject["datesCompleted"] as! [NSDate]
        frequency = Frequency.frequencyForName(parseObject["frequency"] as! String)
        self.name = parseObject["name"] as! String
        createdAt = parseObject["creationDate"] as! NSDate
        
        if let priv = parseObject["private"] {
            privat = priv as! Bool
        } else {
            privat = false
        }
        
        remindUserAt = ""
        notifyConnectionsAt = ""
        timeOfDay = 1
        timesToComplete = parseObject["timesToComplete"] as! Int
        daysToComplete = parseObject["daysToComplete"] as! [String]
        icon = parseObject["icon"] as! String
        color = parseObject["color"] as! String
        notificationsEnabled = parseObject["notificationsEnabled"] as! Bool
        notificationSettings = [.None]
        usersToNotify = []
        for userPO in parseObject["usersToNotify"] as! [PFUser] {
            if let user = User(parseUser: userPO) {
                usersToNotify.append(user)
            }
        }
    }
}
extension HabitRepository {
    
    func uploadToServer(habit: Habit, callback: ((Bool) -> ())?) {
    
        if habitParseObjects[habit] == nil {
            let parseObject = HabitRepository.makeParseObjectForHabit()
            habitParseObjects[habit] = parseObject
        }
        
        
    }
    
    static func makeParseObjectForHabit() -> PFObject {
        guard let user = PFUser.currentUser() else {
            fatalError("ERROR! User is not loaded!")
        }
        
        let parseObject = PFObject(className: "Habit")
        parseObject["owner"] = user
        return parseObject
    }
    
    func updateOnServer(habit: Habit, callback: ((Bool) -> ())?) {
        
        guard let parseObject = habitParseObjects[habit] else {
            return
        }
        
        parseObject["creationDate"] = habit.createdAt
        parseObject["datesCompleted"] = habit.datesCompleted
        parseObject["timesToComplete"] = habit.timesToComplete
        parseObject["frequency"] = habit.frequency.toString()
        parseObject["name"] = habit.name
        parseObject["due"] = habit.dueOn()
        parseObject["daysToComplete"] = habit.daysToComplete
        parseObject["notifyConnectionsAt"] = habit.notifyConnectionsAt
        parseObject["timeOfDay"] = String(habit.timeOfDay)
        parseObject["timesToComplete"] = habit.timesToComplete
        parseObject["icon"] = habit.icon
        parseObject["color"] = habit.color
        parseObject["notificationsEnabled"] = habit.notificationsEnabled
        parseObject["notificationSettings"] = habit.notificationSettings.map({$0.toString()})
        parseObject["private"] = habit.privat
        
        parseObject.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                if let callback = callback {callback(true)}
            } else {
                if let callback = callback {callback(false)}
            }
        })
    }
    
    func deleteFromServer(habit: Habit) {
        if let parseObject = habitParseObjects[habit] {
            parseObject.deleteInBackground()
        }
    }
}

internal extension Message {
    
    /// Initialize with a Parse `PFObject` object.
    ///
    /// - parameter parseObject: The `PFObject` object with which to initialize.
    convenience init?(parseObject: PFObject) {
        
        guard let sender = User(parseUser: parseObject["sender"] as? PFUser) else {
            return nil
        }
        
        self.init(sender: sender)
        text = parseObject["text"] as! String
        
        if let _ = parseObject["habit"] { // No habit data is stored, just a
            habit = Habit()               // placeholder `PFObject` to show
        } else {                          // there is one.
            habit = nil
        }
    }
}

private extension Habit {
   
    /// Initialize with a Core Data `HabitCoreData` object.
    ///
    /// - parameter coreDataObject: The `HabitCoreData` object with which to
    ///                             initialize.
    convenience init(coreDataObject: HabitCoreData) {
        
        self.init()
        
        datesCompleted = coreDataObject.datesCompletedData as! [NSDate]
        frequency = Frequency(rawValue: coreDataObject.frequencyInt)!
        name = coreDataObject.name
        createdAt = coreDataObject.createdAt
        privat = coreDataObject.privat
        remindUserAt = coreDataObject.remindUserAt
        notifyConnectionsAt = coreDataObject.notifyConnectionsAt
        timeOfDay = Int(coreDataObject.timeOfDayInt)
        timesToComplete = Int(coreDataObject.timesToCompleteInt)
        daysToComplete = coreDataObject.daysToComplete
        icon = coreDataObject.icon
        color = coreDataObject.color
        notificationsEnabled = coreDataObject.notificationsEnabled
        notificationSettings = []
        usersToNotify = []
    }
}

private extension HabitRepository {
    
    func completeOn(habit: Habit, date: NSDate) -> Bool {
        
        if habit.numCompletedIn(date) >= habit.timesToComplete {
            return false
        }else{
            habit.datesCompleted.append(date)
            saveToCoreData(habit)
            return true
        }
    }
    
    // uncomplete a habit on a certain date
    func uncompleteOn(habit: Habit, date: NSDate) -> Bool {
        
        if !(habit.numCompletedIn(date) > 0) {
            return false
        }
        
        for completion: NSDate in habit.datesCompleted {
            
            var beginning:NSDate
            var end:NSDate
            
            switch habit.frequency{
            case .Daily:
                beginning = completion.beginningOfDay
                end = completion.endOfDay
            case .Weekly:
                beginning = completion.beginningOfWeek
                end = completion.endOfWeek
            case .Monthly:
                beginning = completion.beginningOfMonth
                end = completion.endOfMonth
            }
            
            if(beginning...end).contains(date) {
                if let index = habit.datesCompleted.indexOf(completion) {
                    habit.datesCompleted.removeAtIndex(index)
                    saveToCoreData(habit)
                    return true
                }
            }
        }
        
        return false
    }
    
    func addToCoreData(habit: Habit) {
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let entityDescription =
            NSEntityDescription.entityForName("Habit",
                                              inManagedObjectContext: managedObjectContext!)
        
        let coreDataObject = HabitCoreData(entity: entityDescription!,
                                       insertIntoManagedObjectContext: managedObjectContext)
        
        coreDataObject.name = habit.name
        coreDataObject.frequencyInt = habit.frequency.rawValue
        coreDataObject.color = habit.color
        coreDataObject.icon = habit.icon
        coreDataObject.privat = habit.privat
        coreDataObject.daysToComplete = habit.daysToComplete
        coreDataObject.timeOfDayInt = Int16(habit.timeOfDay)
        coreDataObject.notifyConnectionsAt = habit.notifyConnectionsAt
        coreDataObject.remindUserAt = habit.remindUserAt
        coreDataObject.notificationSettingsInts = []
        coreDataObject.timesToCompleteInt = Int64(habit.timesToComplete)
        coreDataObject.createdAt = habit.createdAt
        coreDataObject.datesCompletedData = habit.datesCompleted
        coreDataObject.notificationsEnabled = habit.notificationsEnabled
        coreDataObject.usernamesToNotify = habit.usersToNotify.map {$0.name}
        
        do {
            try managedObjectContext?.save()
            habitCoreDataObjects[habit] = coreDataObject
        } catch let error as NSError {
            print("awww error: " + error.description)
        }
    }
    
    private func updateCoreData(habit: Habit) {
        
        guard let coreDataObject = habitCoreDataObjects[habit] else {
            return
        }
        
        coreDataObject.name = habit.name
        coreDataObject.frequencyInt = habit.frequency.rawValue
        coreDataObject.color = habit.color
        coreDataObject.icon = habit.icon
        coreDataObject.privat = habit.privat
        coreDataObject.daysToComplete = habit.daysToComplete
        coreDataObject.timeOfDayInt = Int16(habit.timeOfDay)
        coreDataObject.notifyConnectionsAt = habit.notifyConnectionsAt
        coreDataObject.remindUserAt = habit.remindUserAt
        coreDataObject.notificationSettingsInts = []
        coreDataObject.timesToCompleteInt = Int64(habit.timesToComplete)
        coreDataObject.createdAt = habit.createdAt
        coreDataObject.datesCompletedData = habit.datesCompleted
        coreDataObject.notificationsEnabled = habit.notificationsEnabled
        coreDataObject.save()
    }
    
    func saveToCoreData(habit: Habit) {
        if habitCoreDataObjects[habit] == nil {
            addToCoreData(habit)
        } else {
            updateCoreData(habit)
        }
    }
    
    func deleteFromCoreData(habit: Habit) {
        if let coreDataObject = habitCoreDataObjects[habit] {
            coreDataObject.delete()
        }
    }
}
