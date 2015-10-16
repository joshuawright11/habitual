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
import Parse

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
                if socialEnabled {
                    reloadConnectionsData(nil)
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
            storeUser(self.user)
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
                    try Locksmith.saveData(dict, forUserAccount: kKeychainUserAccount)
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
            try Locksmith.deleteDataForUserAccount(kKeychainUserAccount)
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
        user?.habits = getHabitsOfCurrentUser()
        return user?.habits
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
            let loadedUser = User(json: json)
            loadedUser.habits = getHabitsOfCurrentUser()
            
            return loadedUser
        }else{
            let newUser = User(json: JSON("username:name"))
            newUser.habits = getHabitsOfCurrentUser()
            return newUser
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
    
    public static func reloadConnectionsData(callback: ((success: Bool) ->())?) {
        WebServices.getConnectionsData { (users, success) -> () in
            self.user?.following = users
            if let callback = callback { callback(success: success) }
        }
    }
    
    public static func addHabitForCurrentUser(name:String, frequency:Frequency, notificationsEnabled: Bool, notificationSetting: NotificationSetting, usernamesToNotify: [String]){
        
        let entityDescription =
        NSEntityDescription.entityForName("Habit",
            inManagedObjectContext: managedObjectContext!)
        
        let habit = Habit(entity: entityDescription!,
            insertIntoManagedObjectContext: managedObjectContext)
        
        habit.name = name
        habit.frequency = frequency
        habit.datesCompleted = []
        habit.notificationsEnabled = notificationsEnabled
        habit.notificationSetting = notificationSetting
        habit.usernamesToNotify = usernamesToNotify
        
        do {
            try managedObjectContext?.save()
            user?.habits.append(habit)
        } catch let error as NSError {
            print("awww error: " + error.description)
        }
        
        if habit.notificationsEnabled {
            ForeignNotificationManager.uploadHabitForCurrentUser(habit)
        }
    }
    
    public static func deleteHabitForCurrentUser(habit: Habit?) {
        if let habit = habit {
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDel.managedObjectContext?.deleteObject(habit)

            ForeignNotificationManager.deleteHabitForCurrentUser(habit)
            
            if habit.notificationsEnabled {
                Utilities.postNotification(kNotificationIdentifierHabitAddedOrDeleted)
            }
        }
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
        
        var objects: [AnyObject]?
        do {
            objects = try managedObjectContext?.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            objects = nil
        }
        
        var habits:[Habit] = []
        
        if let results = objects {
            
            if results.count > 0 {
                
                for result in results{
                    let habit = result as! Habit
                    habits.append(habit)
                }
            }
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
        
        var objects: [AnyObject]?
        do {
            objects = try managedObjectContext?.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            objects = nil
        }
        
        if let results = objects {
            
            if results.count > 0 {
                
                for result in results{
                    let habit = result as! Habit
                    managedObjectContext?.deleteObject(habit)
                }
                do {
                    try managedObjectContext?.save()
                } catch _ {
                }
                user?.habits = [];
            }
        }
    }
}
