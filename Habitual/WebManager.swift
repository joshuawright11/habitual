//
//  WebServices.swift
//  Habitual
//
//  Created by Josh Wright on 6/12/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import Foundation
import SwiftyJSON
import Locksmith
import Parse
import Timepiece

/*
    TODO: - Rather confusing, should only work through the AuthManager class
// -TODO: Needs refactoring/documentation
*/
public class WebServices: NSObject {
    
    static func login(email: String, password:String, callback: ((success: Bool, user: User?) -> ())?) {
        PFUser.logInWithUsernameInBackground(email, password: password) { (userLogged: PFUser?, error: NSError?) -> Void in
            if error == nil {
                let installation = PFInstallation.currentInstallation()
                installation["username"] = email
                installation.saveInBackground()
                
                let user: User = User(parseUser: userLogged!, withHabits: false)
                user.habits = AuthManager.currentUser!.habits
                
                AuthManager.currentUser = user
                
                syncDataForCurrentUser(nil)
                
                if let callback = callback {callback(success: true, user: user)}
            }else{
                if let callback = callback {callback(success: false, user: nil)}
            }
        }
    }
    
    static func signup(email: String, password: String, name: String, callback:((success: Bool, user: User?) -> ())?) {
        let user = PFUser()
        user.username = email
        user.password = password
        user.email = email
        
        user["name"] = name
        user["following"] = []
        user["habits"] = []
        user["paymentDue"] = NSDate().endOfDay + 1.year
        
        user.signUpInBackgroundWithBlock { (succes: Bool, error: NSError?) -> Void in
            if error == nil {
                let installation = PFInstallation.currentInstallation()
                installation["username"] = email
                installation.saveInBackground()
                
                let newUser: User = User(parseUser: user, withHabits: false)
                newUser.habits = AuthManager.currentUser!.habits
                
                AuthManager.currentUser = newUser
                
                syncDataForCurrentUser(nil)
                
                if let callback = callback {callback(success: true, user: newUser)}
            }else{
                if let callback = callback {callback(success: false, user: nil)}
            }
        }
    }
    
    private static func syncDataForCurrentUser(callback: ((success: Bool) -> ())?) {
        var count = AuthManager.currentUser!.habits.count
        for habit:Habit in AuthManager.currentUser!.habits {
            habit.uploadToServer({ (success) -> () in
                count--
                if(count == 0) {
                    syncUserHabits()
                }
            })
        }
    }
    
    static func syncUserHabits() {
        var objects:[PFObject] = []
        
        for habit in AuthManager.currentUser!.habits {
            objects.append(habit.parseObject!)
        }
        
        AuthManager.currentUser!.parseObject!["habits"] = objects
        AuthManager.currentUser!.parseObject!.saveInBackground()
    }
    
    /// Overwrite whatever is on the server with whatever is in Core Data
    static func updateAllData() {
        PFUser.currentUser()?.saveInBackground()
        let query = PFQuery(className: "Habit")
        query.whereKey("owner", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            let cdObjects = AuthManager.currentUser!.habits
            for object in objects! {
                let objectId = object.objectId
                let array = cdObjects.filter({$0.objectId == objectId})
                if array.count == 0 { // object on server but not CoreData
                    object.deleteInBackground()
                }else{
                    array.first!.uploadToServer(nil)
                }
            }
        }
    }
    
    static func getContacts(emails: [String], callback: (success: Bool, users:[User]) -> ()) {
        let query = PFUser.query()
        query?.whereKey("email", containedIn: emails)
        query?.findObjectsInBackgroundWithBlock({ (users: [PFObject]?, error) -> Void in
            if let error = error {
                print("Error! \(error.localizedDescription)")
                callback(success: false, users: [])
            } else {
                var userList: [User] = []
                for parseUser: PFUser in users as! [PFUser] {
                    let user = User(parseUser: parseUser, withHabits: false)
                    userList.append(user)
                }
                callback(success: true, users: userList)
            }
        })
    }
    
    static func getFBFriends(fbIds: [String], callback: (success: Bool, users:[User]) -> ()) {
        let query = PFUser.query()
        query?.whereKey("fbId", containedIn: fbIds)
        query?.findObjectsInBackgroundWithBlock({ (users: [PFObject]?, error) -> Void in
            if let error = error {
                print("Error! \(error.localizedDescription)")
                callback(success: false, users: [])
            } else {
                var userList: [User] = []
                for parseUser: PFUser in users as! [PFUser] {
                    let user = User(parseUser: parseUser, withHabits: false)
                    userList.append(user)
                }
                callback(success: true, users: userList)
            }
        })
    }
}
