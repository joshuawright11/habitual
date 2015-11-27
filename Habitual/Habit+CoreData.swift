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

extension Habit {
    private func addToCoreData() {
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let entityDescription =
        NSEntityDescription.entityForName("Habit",
            inManagedObjectContext: managedObjectContext!)
        
        coreDataObject = HabitCoreData(entity: entityDescription!,
            insertIntoManagedObjectContext: managedObjectContext)
        
        coreDataObject!.name = name
        coreDataObject!.frequency = frequency
        coreDataObject!.color = color
        coreDataObject!.icon = icon
        coreDataObject!.privat = privat
        coreDataObject!.daysToComplete = daysToComplete
        coreDataObject!.timeOfDayInt = timeOfDay.rawValue
        coreDataObject!.notifyConnectionsAt = notifyConnectionsAt
        coreDataObject!.remindUserAt = remindUserAt
        coreDataObject!.notificationSettings = notificationSettings
        coreDataObject!.timesToComplete = timesToComplete
        coreDataObject!.createdAt = createdAt
        coreDataObject!.datesCompleted = datesCompleted
        coreDataObject!.notificationsEnabled = notificationsEnabled
        coreDataObject!.notificationSettings = notificationSettings
        coreDataObject!.usernamesToNotify = usersToNotify.map {$0.name}
        
        do {
            try managedObjectContext?.save()
            AuthManager.currentUser?.habits.append(self)
        } catch let error as NSError {
            print("awww error: " + error.description)
        }
    }
    
    private func updateCoreData() {
        coreDataObject!.name = name
        coreDataObject!.frequency = frequency
        coreDataObject!.color = color
        coreDataObject!.icon = icon
        coreDataObject!.privat = privat
        coreDataObject!.daysToComplete = daysToComplete
        coreDataObject!.timeOfDayInt = timeOfDay.rawValue
        coreDataObject!.notifyConnectionsAt = notifyConnectionsAt
        coreDataObject!.remindUserAt = remindUserAt
        coreDataObject!.notificationSettings = notificationSettings
        coreDataObject!.timesToComplete = timesToComplete
        coreDataObject!.createdAt = createdAt
        coreDataObject!.datesCompleted = datesCompleted
        coreDataObject!.notificationsEnabled = notificationsEnabled
        coreDataObject!.notificationSettings = notificationSettings
        coreDataObject!.usernamesToNotify = usersToNotify.map {$0.name}
        coreDataObject!.save()
    }
    
    func saveToCoreData() {
        
        defer {
            if(AuthManager.currentUser?.parseObject != nil){ uploadToServer() }
        }
        
        if let _ = coreDataObject {
            updateCoreData()
        }else{
            addToCoreData()
        }
    }
    
    func deleteFromCoreData() {
        if let coreDataObject = coreDataObject {
            coreDataObject.delete()
            if AuthManager.socialEnabled {
                deleteFromServer()
            }else{
                print("ERROR USER IS EMPTY")
            }
            Utilities.postNotification(kNotificationIdentifierHabitAddedOrDeleted)
        }else{
            fatalError("Not a core data object!")
        }
    }
}
