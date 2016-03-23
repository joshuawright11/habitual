//
//  Habit+CoreData.swift
//  Ignite
//
//  Created by Josh Wright on 11/26/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Foundation
import CoreData
import Parse

// -TODO: Needs refactoring/documentation

extension Habit {
    
    public func completeOn(date: NSDate) -> Bool {
        
        if numCompletedIn(date) >= timesToComplete {
            return false
        }else{
            datesCompleted.append(date)
            saveToCoreData(true)
            return true
        }
    }
    
    // uncomplete a habit on a certain date
    public func uncompleteOn(date: NSDate) -> Bool {
        
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
