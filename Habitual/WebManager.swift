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
                user.habits = AuthManager.currentUser!.habits
                
                AuthManager.currentUser = user
                
                syncDataForCurrentUser(nil)
                
                if let callback = callback {callback(success: true, user: user)}
            }else{
                if let callback = callback {callback(success: false, user: nil)}
            }
        }
    }
    
    static func signup(username: String, password: String, name: String, callback:((success: Bool, user: User?) -> ())?) {
        let user = PFUser()
        user.username = username
        user.password = password
        user.email = "\(username)@false.com"
        
        user["name"] = name
        user["following"] = []
        user["habits"] = []
        
        user.signUpInBackgroundWithBlock { (succes: Bool, error: NSError?) -> Void in
            if error == nil {
                let installation = PFInstallation.currentInstallation()
                installation["username"] = username
                installation.saveInBackground()
                
                let newUser: User = User(parseUser: user)
                newUser.habits = AuthManager.currentUser!.habits
                
                AuthManager.currentUser = newUser
                
                syncDataForCurrentUser(nil)
                
                if let callback = callback {callback(success: true, user: newUser)}
            }else{
                if let callback = callback {callback(success: false, user: nil)}
            }
        }
    }
    
    static func syncDataForCurrentUser(callback: ((success: Bool) -> ())?) {
        
        for habit:Habit in AuthManager.currentUser!.habits {
            habit.uploadToServer()
        }
    }
}
