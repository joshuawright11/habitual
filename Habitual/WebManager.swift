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

public class WebServices: NSObject {
    
    static func login(username: String, password:String, callback: ((success: Bool) -> ())?) {
        PFUser.logInWithUsernameInBackground(username, password: password) { (userLogged: PFUser?, error: NSError?) -> Void in
            if error == nil {
                if let callback = callback {callback(success: true)}
            }else{
                if let callback = callback {callback(success: false)}
            }
        }
    }
    
    static func signup(username: String, password:String, callback:((success: Bool) -> ())?) {
        let user = PFUser()
        user.username = username
        user.password = password
        user.email = "\(username)@false.com"
        
        user["following"] = []
        user["habits"] = []
        
        user.signUpInBackgroundWithBlock { (succes: Bool, error: NSError?) -> Void in
            if error == nil {
                if let callback = callback {callback(success: true)}
            }else{
                if let callback = callback {callback(success: false)}
            }
        }
    }
    
    static func addConnection(username: String, callback:((success: Bool) -> ())?) {
        
        var query = PFUser.query()
        query?.whereKey("username", equalTo: username)
        
        query?.findObjectsInBackgroundWithBlock({ (user: [AnyObject]?, error: NSError?) -> Void in
            if user!.count == 1 {
                var following:[String] = PFUser.currentUser()!["following"] as! [String]
                following.append(username)
                PFUser.currentUser()!["following"] = following
                PFUser.currentUser()?.saveInBackgroundWithBlock(nil)
                if let callback = callback {callback(success: true)}
            }else{
                if let callback = callback {callback(success: false)}
            }
        })
    }
    
    static func getPendingConnections(username: String, callback:((success: Bool) -> ())?) {
        // TODO : Not now chief I'm in the zone
    }
    
    static func approveConnection(username: String, callback:((success: Bool) -> ())?) {
        // TODO : Not now chief I'm in the zone
    }
    
    static func getConnectionsData(callback:((users: [User], success: Bool) -> ())?) {
        
        var query = PFUser.query()

        var array:[String] = PFUser.currentUser()!["following"] as! [String]

        query?.whereKey("username", containedIn: array)
        
        query?.findObjectsInBackgroundWithBlock({ (users: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                
                var userArray:[User] = []
                for user:PFUser in users! as! [PFUser] {
                    userArray.append(User(parse: user))
                }
                
                if let callback = callback {
                    callback(users: userArray, success: error == nil)
                }
            }else{
                println("failz")
            }
        })
    }
    
    static func syncDataForUser(callback: ((success: Bool) -> ())?) {
        
        if let user = PFUser.currentUser(){
            var array:[JSON] = []
            
            for habit:Habit in AuthManager.currentUser!.habits {
                array.append(habit.toJSON())
            }
            
            PFUser.currentUser()!["habits"] = JSON(array).arrayObject
            PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if let callback = callback {callback(success: success)}
            })
        }
    }
}
