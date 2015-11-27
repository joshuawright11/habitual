//
//  Habit+Web.swift
//  Ignite
//
//  Created by Josh Wright on 11/26/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Foundation
import Parse

extension Habit {
    
    
    public func uploadToServer() {
        if let _ = parseObject {
            updateOnServer()
        }else{
            addToServer()
        }
    }
    
    private func addToServer() {
        
        guard let user = AuthManager.currentUser else {
            print("ERROR! User is not loaded!")
            return
        }
        
        parseObject = PFObject(className: "Habit")
        parseObject!["owner"] = user.parseObject
        updateOnServer()
    }
    
    private func updateOnServer() {
        
        parseObject!["creationDate"] = createdAt
        parseObject!["datesCompleted"] = datesCompleted
        parseObject!["timesToComplete"] = timesToComplete
        parseObject!["frequency"] = frequency.name()
        parseObject!["name"] = name
        parseObject!["due"] = dueOn()
        parseObject!["usersToNotify"] = usersToNotify.map({$0.parseObject!})
        parseObject!["daysToComplete"] = daysToComplete
        parseObject!["notifyConnectionsAt"] = notifyConnectionsAt
        parseObject!["timeOfDay"] = timeOfDay.name()
        parseObject!["timesToComplete"] = timesToComplete
        parseObject!["icon"] = icon
        parseObject!["color"] = color
        parseObject!["notificationsEnabled"] = notificationsEnabled
        parseObject!["notificationSettings"] = notificationSettings.map({$0.toString()})
        
        var habits = AuthManager.currentUser?.parseObject!["habits"] as! [PFObject]
        
        parseObject!.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            if success {
                if self.coreDataObject!.objectId == "" {
                    self.coreDataObject!.objectId = self.parseObject!.objectId!
                    self.coreDataObject?.save()
                    self.objectId = self.coreDataObject!.objectId
                }
                
                let filtered = habits.filter({$0.objectId == self.parseObject!.objectId})
                if(filtered.count == 0){
                    habits.append(self.parseObject!)
                    AuthManager.currentUser?.parseObject!["habits"] = habits
                    AuthManager.currentUser?.parseObject?.saveInBackground()
                }
            }else{
                print("ERROR! \(error?.code)")
            }
        })
    }
    
    public func deleteFromServer() {
        
        print("delete from server")
        let habits = AuthManager.currentUser?.parseObject!["habits"] as! [PFObject]
        
        let filtered = habits.filter({$0.objectId != self.parseObject?.objectId})

        AuthManager.currentUser?.parseObject!["habits"] = filtered
        AuthManager.currentUser?.parseObject?.saveInBackground()
        
        parseObject!.deleteInBackground()
    }
}
