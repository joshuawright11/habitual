//
//  AuthManager.swift
//  Habitual
//
//  Created by Josh Wright on 6/12/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import Foundation
import SwiftyJSON
import Locksmith
import Parse

// -TODO: Needs refactoring/documentation

/// A Singleton class to manage the current user. All accesses of the current user should be made through 
/// this class. Allows for logging in and logging out over the web, as well as storing the currently logged 
/// in user's data locally to prevent the need for logging in every time a user is cleared from memory.
public class AuthManager : NSObject{
    
    /// Wrapper for the currently logged in user. This is so that the user variable can be private.
    static var currentUser:User? {
        
        /**
            Returns the currently logged in user. If the user is not in memory, loads them before
            returning.
        */
        get{
        
            if (self.user == nil){
                self.user = loadUser();
                if socialEnabled {
                    loadHabitParseObjects()
                    user?.getConnections({ (success) -> () in
                        if(success) {Utilities.postNotification(Notifications.reloadNetworkOnline)}
        })
                }
            }
            return self.user
        }
        
        /**
            Sets a new user. Stores that user's information into NSUserDefaults for later access.
        
            - parameter newUser: The user to set as the currently logged in user.
        */
        set(newUser){
            self.user = newUser;
        }
    }
    
    /// Whether the social features are enabled (currently if the user is logged into an account).
    static var socialEnabled:Bool {get{return PFUser.currentUser() != nil ? true : false}}
    
    /// The currently logged in user. Wrapped by currentUser for getting and setting.
    private static var user:User?
    
    /**
        Logs the user in via the WebServices class. The only way a user should be logged in.
        
        - parameter username: The username with which to attempt a login.
        - parameter password: The password with which to attempt a login.
        - parameter callback: The closure to call upon completion of the login request. 'valid' is True 
            when the request succeeds and False if it fails.
    */
    public static func login(username: String, password:String, callback: ((success: Bool) -> ())?) {

        WebServices.login(username, password: password) { (success, user) -> () in

            if username == user!.username{
            
                let dict:Dictionary = ["username":username,"password":password]
                
                do{
                    try Locksmith.saveData(dict, forUserAccount: "Habitual")
                }catch{
                    
                }
                self.currentUser = user
            }
            
            if let callback = callback{
                callback(success: (username == user!.username))
            }
        }
    }
    
    /**
        Logs the current user out, clearing their keychain data and wiping their data from the 
        AuthManager and NSUserDefaults.
    */
    public static func logout() {
        user = nil;
        do{
            try Locksmith.deleteDataForUserAccount("Habitual")
        }catch {
            
        }
        clearUser()
        
    }
    
    /**
        Checks to see if there is currently a logged in user.
    
        - returns: True if there is a user logged in, False if not.
    */
    public static func isLoggedIn() -> Bool{
        
        if let currentUser = currentUser {
            return currentUser.username != ""
        }else{
            return false
        }
    }
    
    /**
        Private helper method to clear all user data from NSUserDefaults
    */
    private static func clearUser() {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.removeObjectForKey("currentUser")
    }
    
    
    public static func reloadHabits() -> [Habit]?{
        user?.habits = CoreDataManager.getHabitsOfCurrentUser()
        if socialEnabled {
            loadHabitParseObjects()
        }
        return user?.habits
    }
    
    /**
        Private helper method to load a user that might be logged in from NSUserDefualts to memory.
        To prevent the need to log in again after closing the application.
    */
    private static func loadUser() -> User? {
        
        if socialEnabled {
            let loadedUser = User(parseUser: PFUser.currentUser()!, withHabits: false)
            loadedUser.habits = CoreDataManager.getHabitsOfCurrentUser()
            return loadedUser
        }else{
            let newUser = User()
            newUser.habits = CoreDataManager.getHabitsOfCurrentUser()
            
            return newUser
        }
    }
    
    private static func loadHabitParseObjects() {
        
        let parseObjects = PFUser.currentUser()!["habits"] as! [PFObject]
        
        for habit in user!.habits {
            
            let filtered = parseObjects.filter({$0.objectId == habit.coreDataObject!.objectId})
            if filtered.count == 1 {
                habit.parseObject = filtered.first
            }else{
                habit.uploadToServer(nil)
            }
        }
    }
}
