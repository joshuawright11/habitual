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

/*
    TODO: - Rather confusing, should only work through the AuthManager class
*/
public class WebServices: NSObject {
    
    static func login(username: String, password:String, callback: ((success: Bool, user: User?) -> ())?) {
        PFUser.logInWithUsernameInBackground(username, password: password) { (userLogged: PFUser?, error: NSError?) -> Void in
            if error == nil {
                let installation = PFInstallation.currentInstallation()
                installation["username"] = username
                installation.saveInBackground()
                
                let user: User = User(parseUser: userLogged!)
                
                if let callback = callback {callback(success: true, user: user)}
            }else{
                if let callback = callback {callback(success: false, user: nil)}
            }
        }
    }
    
    static func signup(username: String, password:String, callback:((success: Bool, user: User?) -> ())?) {
        let user = PFUser()
        user.username = username
        user.password = password
        user.email = "\(username)@false.com"
        
        user["following"] = []
        user["habits"] = []
        
        user.signUpInBackgroundWithBlock { (succes: Bool, error: NSError?) -> Void in
            if error == nil {
                let installation = PFInstallation.currentInstallation()
                installation["username"] = username
                installation.saveInBackground()
                
                let newUser: User = User(parseUser: user)
                
                if let callback = callback {callback(success: true, user: newUser)}
            }else{
                if let callback = callback {callback(success: false, user: nil)}
            }
        }
    }
    
    static func syncDataForUser(callback: ((success: Bool) -> ())?) {
        
        if let user = PFUser.currentUser(){
            var array:[JSON] = []
            
            for habit:Habit in AuthManager.currentUser!.habits {
                array.append(habit.toJSON())
            }
            
            user["habits"] = JSON(array).arrayObject
            user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if let callback = callback {callback(success: success)}
            })
        }
    }
}
