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
    
    internal var habits: [Habit] = []
    
    override init() {
        super.init()
        
    }
    
    internal func createHabit(habit: Habit) {
        
    }
    
    internal func deleteHabit(habit: Habit) {
        
    }
    
    internal func updateHabit(habit: Habit) {
        
    }
    
    private func loadHabitsFromCoreData() {
        
    }
}

private extension HabitRepository {
    static let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    private static func getHabitsOfCurrentUser() -> [Habit]{
        let entityDescription =
            NSEntityDescription.entityForName("Habit",
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
                    let habit = result as! HabitCoreData
                    habits.append(Habit(coreDataObject: habit))
                }
            }
        }
        return habits;
    }
    
    private static func clearHabitsOfCurrentUser() {
        let entityDescription =
            NSEntityDescription.entityForName("Habit",
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
                AuthManager.currentUser?.habits = [];
            }
        }
    }
}

private extension Habit {
    
    func uploadToServer(callback: ((Bool) -> ())?) {
        
        if let _ = parseObject {
            updateOnServer(callback)
        }else{
            if(callback == nil){
                addToServer({ (success) -> () in
                    WebServices.syncUserHabits()
                })
            }else{
                addToServer(callback)
            }
        }
    }
    
    func addToServer(callback: ((Bool) -> ())?) {
        guard let user = AuthManager.currentUser else {
            print("ERROR! User is not loaded!")
            return
        }
        
        parseObject = PFObject(className: "Habit")
        parseObject!["owner"] = user.parseObject
        updateOnServer(callback)
    }
    
    func updateOnServer(callback: ((Bool) -> ())?) {
        
        parseObject!["creationDate"] = createdAt
        parseObject!["datesCompleted"] = datesCompleted
        parseObject!["timesToComplete"] = timesToComplete
        parseObject!["frequency"] = frequency.toString()
        parseObject!["name"] = name
        parseObject!["due"] = dueOn()
        if coreDataObject?.usernamesToNotify.count == usersToNotify.count {
            parseObject!["usersToNotify"] = usersToNotify.map({$0.parseObject!})
        }
        parseObject!["daysToComplete"] = daysToComplete
        parseObject!["notifyConnectionsAt"] = notifyConnectionsAt
        parseObject!["timeOfDay"] = String(timeOfDay)
        parseObject!["timesToComplete"] = timesToComplete
        parseObject!["icon"] = icon
        parseObject!["color"] = color
        parseObject!["notificationsEnabled"] = notificationsEnabled
        parseObject!["notificationSettings"] = notificationSettings.map({$0.toString()})
        parseObject!["private"] = privat
        
        parseObject!.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                self.coreDataObject!.objectId = self.parseObject!.objectId!
                self.coreDataObject?.save()
                if let callback = callback {callback(true)}
            } else {
                print("ERROR! \(error?.code)")
                if let callback = callback {callback(false)}
            }
        })
    }
    
    func saveCompletionData() {
        parseObject!["datesCompleted"] = datesCompleted
        parseObject!["due"] = dueOn()
        parseObject?.saveInBackground()
    }
    
    func deleteFromServer() {
        parseObject!.deleteInBackground()
        WebServices.syncUserHabits()
    }
}

private extension Habit {
    
    func completeOn(date: NSDate) -> Bool {
        
        if numCompletedIn(date) >= timesToComplete {
            return false
        }else{
            datesCompleted.append(date)
            saveToCoreData(true)
            return true
        }
    }
    
    // uncomplete a habit on a certain date
    func uncompleteOn(date: NSDate) -> Bool {
        
        if !(numCompletedIn(date) > 0) {
            return false
        }
        
        for completion: NSDate in datesCompleted {
            
            var beginning:NSDate
            var end:NSDate
            
            switch frequency{
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
                if let index = datesCompleted.indexOf(completion) {
                    datesCompleted.removeAtIndex(index)
                    saveToCoreData(true)
                    return true
                }
            }
        }
        
        return false
    }
    
    private func addToCoreData() {
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let entityDescription =
            NSEntityDescription.entityForName("Habit",
                                              inManagedObjectContext: managedObjectContext!)
        
        coreDataObject = HabitCoreData(entity: entityDescription!,
                                       insertIntoManagedObjectContext: managedObjectContext)
        
        coreDataObject!.name = name
        coreDataObject!.frequencyInt = frequency.rawValue
        coreDataObject!.color = color
        coreDataObject!.icon = icon
        coreDataObject!.privat = privat
        coreDataObject!.daysToComplete = daysToComplete
        coreDataObject!.timeOfDayInt = Int16(timeOfDay)
        coreDataObject!.notifyConnectionsAt = notifyConnectionsAt
        coreDataObject!.remindUserAt = remindUserAt
        coreDataObject!.notificationSettingsInts = []
        coreDataObject!.timesToCompleteInt = Int64(timesToComplete)
        coreDataObject!.createdAt = createdAt
        coreDataObject!.datesCompletedData = datesCompleted
        coreDataObject!.notificationsEnabled = notificationsEnabled
        coreDataObject!.usernamesToNotify = usersToNotify.map {$0.name}
        
        if let po = parseObject {
            coreDataObject!.objectId = po.objectId!
        }
        
        do {
            try managedObjectContext?.save()
            AuthManager.currentUser?.habits.append(self)
        } catch let error as NSError {
            print("awww error: " + error.description)
        }
    }
    
    private func updateCoreData() {
        coreDataObject!.name = name
        coreDataObject!.frequencyInt = frequency.rawValue
        coreDataObject!.color = color
        coreDataObject!.icon = icon
        coreDataObject!.privat = privat
        coreDataObject!.daysToComplete = daysToComplete
        coreDataObject!.timeOfDayInt = Int16(timeOfDay)
        coreDataObject!.notifyConnectionsAt = notifyConnectionsAt
        coreDataObject!.remindUserAt = remindUserAt
        coreDataObject!.notificationSettingsInts = []
        coreDataObject!.timesToCompleteInt = Int64(timesToComplete)
        coreDataObject!.createdAt = createdAt
        coreDataObject!.datesCompletedData = datesCompleted
        coreDataObject!.notificationsEnabled = notificationsEnabled
        if(AuthManager.currentUser?.connections.count != 0) {
            coreDataObject!.usernamesToNotify = usersToNotify.map {$0.name}
        }
        coreDataObject!.save()
    }
    
    func saveCompletionCoreData() {
        coreDataObject!.datesCompletedData = datesCompleted
        coreDataObject?.save()
    }
    
    func saveToCoreData(completion: Bool) {
        
        defer {
            if(AuthManager.currentUser?.parseObject != nil){
                if completion {
                    saveCompletionData()
                } else{
                    uploadToServer(nil)
                }
            }
        }
        
        if completion {
            saveCompletionCoreData()
        } else {
            if let _ = coreDataObject {
                updateCoreData()
            } else {
                addToCoreData()
            }
        }
    }
    
    func saveOrder() {
        if let coreDataObject = coreDataObject {
            coreDataObject.save()
        } else {
            print("Error! No core data object")
        }
    }
    
    func deleteFromCoreData() {
        if let coreDataObject = coreDataObject {
            coreDataObject.delete()
            deleteFromServer()
            Utilities.postNotification(Notifications.habitDataChanged)
        }else{
            fatalError("Not a core data object!")
        }
    }
}
