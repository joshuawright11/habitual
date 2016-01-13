//
//  Habit+Web.swift
//  Ignite
//
//  Created by Josh Wright on 11/26/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Foundation
import Parse

// -TODO: Needs refactoring/documentation

extension Habit {
    
    public func uploadToServer(callback: ((Bool) -> ())?) {

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
    
    private func addToServer(callback: ((Bool) -> ())?) {
        guard let user = AuthManager.currentUser else {
            print("ERROR! User is not loaded!")
            return
        }
        
        parseObject = PFObject(className: "Habit")
        parseObject!["owner"] = user.parseObject
        updateOnServer(callback)
    }
    
    private func updateOnServer(callback: ((Bool) -> ())?) {
        
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
    
    public func saveCompletionData() {
        parseObject!["datesCompleted"] = datesCompleted
        parseObject!["due"] = dueOn()
        parseObject?.saveInBackground()
    }
    
    public func deleteFromServer() {
        parseObject!.deleteInBackground()
        WebServices.syncUserHabits()
    }
}
