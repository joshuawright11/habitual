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
import CoreData

/// A Singleton class to manage the current user. All accesses of the current user should be made through 
/// this class. Allows for logging in and logging out over the web, as well as storing the currently logged 
/// in user's data locally to prevent the need for logging in every time a user is cleared from memory.
public class AuthManager : NSObject{
    
    static let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    /// Wrapper for the currently logged in user. This is so that the user variable can be private.
    static var currentUser:User? {
        
        /**
            Returns the currently logged in user. If the user is not in memory, loads them before
            returning.
        */
        get{
        
            if (self.user == nil){
                self.user = loadUser();
            }
            return self.user
        }
        
        /**
            Sets a new user. Stores that user's information into NSUserDefaults for later access.
        
            :param: newUser The user to set as the currently logged in user.
        */
        set(newUser){
            
            self.user = newUser;
            storeUser(self.user)
        }
    }
    
    /// The currently logged in user. Wrapped by currentUser for getting and setting.
    private static var user:User?
    
    /**
        Logs the user in via the WebServices class. The only way a user should be logged in.
        
        :param: username The username with which to attempt a login.
        :param: password The password with which to attempt a login.
        :param: callback The closure to call upon completion of the login request. 'valid' is True 
            when the request succeeds and False if it fails.
    */
    public static func login(username:String, password:String, callback: ((valid:Bool) -> ())?){
        
        WebServices.testCredentials(username, password: password) { (user) -> () in
            
            if username == user.username{
                
                let dict:Dictionary = ["username":username,"password":password]
                let error = Locksmith.saveData(dict, forUserAccount: kKeychainUserAccount)
                
                self.currentUser = user
            }
            
            if let callback = callback{
                callback(valid: (username == user.username))
            }
        }
    }
    
    /**
        Logs the current user out, clearing their keychain data and wiping their data from the 
        AuthManager and NSUserDefaults.
    */
    public static func logout() {
        user = nil;
        Locksmith.deleteDataForUserAccount(kKeychainUserAccount)
        clearUser()
        
    }
    
    /**
        Checks to see if there is currently a logged in user.
    
        :returns: True if there is a user logged in, False if not.
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
    
    /**
        Private helper method to load a user that might be logged in from NSUserDefualts to memory.
        To prevent the need to log in again after closing the application.
    */
    private static func loadUser() -> User?{
        
        let ud = NSUserDefaults.standardUserDefaults()
        let jsonString:String? = ud.objectForKey("currentUser") as? String;
        
        if let jsonString = jsonString, dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            
            let json = JSON(data: dataFromString)
            var loadedUser = User(json: json)
            loadedUser.habits = getHabitsOfCurrentUser()
            return user
        }else{
            let user = User(json: JSON("username:name"))
            user.habits = getHabitsOfCurrentUser()
            return user
        }
    }
    
    /**
        Private helper method to store the user in NSUserDefaults so that their information can be
        loaded into memory again without the need to log back in.
    */
    private static func storeUser(user: User?){
        if let user = user {
            let ud = NSUserDefaults.standardUserDefaults()
            
            let string = user.toJSON().rawString()
            
            if let string = string {
                ud.setObject(string, forKey: "currentUser")
            }
        }
    }
    
    public static func addHabitForCurrentUser(name:String, repeat:Repeat){
        
        let entityDescription =
        NSEntityDescription.entityForName("Habit",
            inManagedObjectContext: managedObjectContext!)
        
        let habit = Habit(entity: entityDescription!,
            insertIntoManagedObjectContext: managedObjectContext)
        
        habit.name = name
        habit.repeat = repeat
        habit.datesCompleted = []
        
        var error: NSError?
        
        managedObjectContext?.save(&error)
        
        if let err = error {println("Aww error: " + err.description)}
        else {user?.habits.append(habit)}
    }
    
    /**
        Private helper method to load a User's Habits from CoreData when a user is loaded from
        NSUserDefaults (meaning that the user must already have been logged in).
    */
    private static func getHabitsOfCurrentUser() -> [Habit]{
        let entityDescription =
        NSEntityDescription.entityForName("Habit",
            inManagedObjectContext: managedObjectContext!)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        
        var error: NSError?
        
        var objects = managedObjectContext?.executeFetchRequest(request,
            error: &error)
        
        var habits:[Habit] = []
        
        if let results = objects {
            
            if results.count > 0 {
                
                for result in results{
                    let habit = result as! Habit
                    habits.append(habit)
                }
            } else {println("u dun messed up now")}
        }
        return habits;
    }
    
    public static func clearHabitsOfCurrentUser() {
        let entityDescription =
        NSEntityDescription.entityForName("Habit",
            inManagedObjectContext: managedObjectContext!)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        
        var error: NSError?
        
        var objects = managedObjectContext?.executeFetchRequest(request,
            error: &error)
        
        if let results = objects {
            
            if results.count > 0 {
                
                for result in results{
                    let habit = result as! Habit
                    managedObjectContext?.deleteObject(habit)
                }
                managedObjectContext?.save(nil)
                user?.habits = [];
            } else {println("u dun messed up now")}
        }
    }
}
