//
//  ServiceManager.swift
//  Ignite
//
//  Created by Josh Wright on 3/31/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import UIKit
import Parse
import Timepiece
import FBSDKLoginKit
import ParseFacebookUtilsV4

protocol ServiceObserver: class {
    func serviceDidUpdate()
}

class ServiceManager: NSObject {
    var habitRepository: HabitRepository = HabitRepository()
    var connectionReposity: ConnectionRepository = ConnectionRepository()
    
    private var user: User?
    
    var habitServiceObservers: [ServiceObserver] = []
    var connectionServiceObservers: [ServiceObserver] = []
    var accountServiceObservers: [ServiceObserver] = []
    
    override init() {
        user = User(parseUser: PFUser.currentUser())
        super.init()
        connectionReposity.initialize { (success) in
            if success {
                self.notifyConnectionServiceObservers()
            }
        }
    }
    
    func notifyHabitServiceObservers() {
        for observer in habitServiceObservers {
            observer.serviceDidUpdate()
        }
    }
    
    func notifyConnectionServiceObservers() {
        for observer in connectionServiceObservers {
            observer.serviceDidUpdate()
        }
    }
    
    func notifyAccountServiceObservers() {
        for observer in accountServiceObservers {
            observer.serviceDidUpdate()
        }
    }
}

extension ServiceManager : HabitService {
    
    var habits:[Habit] {
        return habitRepository.habits
    }
    
    func createHabit(habit: Habit) {
        habitRepository.createHabit(habit)
        notifyHabitServiceObservers()
    }
    
    func deleteHabit(habit: Habit) {
        habitRepository.deleteHabit(habit)
        notifyHabitServiceObservers()
    }
    
    func updateHabit(habit: Habit) {
        habitRepository.updateHabit(habit)
        notifyHabitServiceObservers()
    }
    
    func orderHabits(habits: [Habit]) {
        habitRepository.orderHabits(habits)
    }
    
    func isTracking(habit: Habit) -> Bool {
        return habitRepository.isTracking(habit)
    }
    
    // return whether the habit can be completed again
    func completeHabit(habit: Habit, on date: NSDate) -> Bool {
        if habit.canDoOn(date) {
            habit.datesCompleted.append(date);
            habitRepository.updateHabit(habit)
            return habit.canDoOn(date)
        } else {
            return false;
        }
    }
    
    // return whether the habit can be incompleted again
    func incompleteHabit(habit: Habit, on date: NSDate) -> Bool {
        if habit.numCompletedIn(date) > 0 {
            for completion in habit.datesCompleted {
                if (date.beginningOfDay...date.endOfDay).contains(completion) {
                    habit.datesCompleted.removeObject(completion)
                    habitRepository.updateHabit(habit)
                    break
                }
            }
            return habit.numCompletedIn(date) > 0
        } else {
            return false
        }
    }
    
    func addHabitServiceObserver(observer: ServiceObserver) {
        habitServiceObservers.append(observer)
    }
    
    func removeHabitServiceObserver(observer: ServiceObserver) {
        for i in 0..<habitServiceObservers.count {
            if habitServiceObservers[i] === observer {
                habitServiceObservers.removeAtIndex(i)
            }
        }
    }
}

extension ServiceManager : ConnectionService {
    
    var connections:[Connection] {
        return connectionReposity.connections
    }
    
    func connectWith(emailOfUser:String, callback: (success:Bool) -> ()) throws {
        try alreadyConnected(emailOfUser)
        connectionReposity.connectWith(emailOfUser, callback: callback)
        notifyConnectionServiceObservers()
    }
    
    private func alreadyConnected(string: String) throws {
        
        let emails = connections.map({otherUser($0).email})
        
        if(emails.contains(string)) {
            throw ConnectionServiceError.AlreadyConnected
        }else if(currentUser?.email == string){
            throw ConnectionServiceError.SelfConnection
        }
    }
    
    func approveConnection(connection: Connection) {
        connectionReposity.approveConnection(connection)
    }
    
    func otherUser(connection: Connection) -> User {
        return connection.sender.email == user?.email ? connection.receiver : connection.sender
    }
    
    func message(connection: Connection, text: String, callback:(success: Bool) -> ()) {
        connectionReposity.message(connection, text: text, callback: callback)
        notifyConnectionServiceObservers()
    }
    
    func sentByCurrentUser(connection: Connection) -> Bool {
        return connection.sender.email == currentUser?.email
    }
    
    func numHabitsAccountableInConnection(connection: Connection) -> Int {
        let user = otherUser(connection)
        return user.habits.filter({$0.usersToNotify.contains({ (user) -> Bool in
            return user.email == currentUser?.email
        })}).count
    }
    
    func addConnectionServiceObserver(observer: ServiceObserver) {
        connectionServiceObservers.append(observer)
    }
    
    func removeConnectionServiceObserver(observer: ServiceObserver) {
        for i in 0..<connectionServiceObservers.count {
            if connectionServiceObservers[i] === observer {
                connectionServiceObservers.removeAtIndex(i)
            }
        }
    }
}

extension ServiceManager : AccountService {
    
    var isLoggedIn: Bool {
        return user != nil
    }
    
    var currentUser: User? {
        return user
    }
    
    var isFakeEmail: Bool {
        if let user = user {
            return user.email.containsString("@false.com")
        } else {
            return false
        }
    }
    
    func login(email: String, password:String, callback: (success: Bool) -> ()) {
        PFUser.logInWithUsernameInBackground(email, password: password) { (userLogged: PFUser?, error: NSError?) -> Void in
            if error == nil {
                
                self.user = User(parseUser: userLogged)
                self.notifyAccountServiceObservers()
                self.updateInstallation()
                
                callback(success: true)
            }else{
                callback(success: false)
            }
        }
    }
    
    func signup(email: String, password:String, name: String, callback: (success: Bool) -> ()) {
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
                
                self.user = User(parseUser: user)
                self.notifyAccountServiceObservers()
                self.updateInstallation()
                
                callback(success: true)
            }else{
                callback(success: false)
            }
        }
    }
    
    func connectWithFacebook(callback:(success: Bool) -> ()) {
        
        let fbPermissions = ["public_profile","email","user_friends"]
        
        if let currentParseUser = PFUser.currentUser() {
            PFFacebookUtils.linkUserInBackground(currentParseUser, withReadPermissions: fbPermissions, block: { (success, error) -> Void in
                if success {
                    self.updateUserInfoFromFacebook(false)
                }
                callback(success: success)
            })
        } else {
            PFFacebookUtils.logInInBackgroundWithReadPermissions(fbPermissions) { (user, error) -> Void in
                if let user = user {
                    self.updateUserInfoFromFacebook(user.isNew)
                    self.user = User(parseUser: user)
                    self.notifyAccountServiceObservers()
                    self.updateInstallation()
                    
                    callback(success: true)
                } else {
                    callback(success: false)
                }
            }
        }
    }
    
    private func updateUserInfoFromFacebook(newUser: Bool) {
        let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, email, first_name, last_name"])
        req.startWithCompletionHandler { (connection, result, error) -> Void in
            
            guard let result = result as? [String : AnyObject] else {
                return
            }
            
            let userId = result["id"] as! String
            let userEmail = result["email"] as! String
            
            let myUser = PFUser.currentUser()!
            
            let userProfileSmallURL = NSURL(string: "https://graph.facebook.com/\(userId)/picture")
            let pictureData = NSData(contentsOfURL: userProfileSmallURL!)
            if let pictureData = pictureData {
                let file = PFFile(data: pictureData)
                myUser.setObject(file!, forKey: "profilePicture")
            }
            
            myUser.email = userEmail
            myUser["fbId"] = userId
            
            if newUser {
                let userFirstName = result["first_name"] as! String
                let userLastName = result["last_name"] as! String
                
                myUser["name"] = "\(userFirstName) \(userLastName)"
                myUser["habits"] = []
                myUser["paymentDue"] = NSDate() + 1.year
                myUser["following"] = []
            }
            
            myUser.saveInBackground()
        }
    }
    
    func addAccountServiceObserver(observer: ServiceObserver) {
        accountServiceObservers.append(observer)
    }
    
    func removeAccountServiceObserver(observer: ServiceObserver) {
        for i in 0..<accountServiceObservers.count {
            if accountServiceObservers[i] === observer {
                accountServiceObservers.removeAtIndex(i)
            }
        }
    }
    
    private func updateInstallation() {
        
        guard let user = user else {
            return
        }
        
        let versionNumber = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        
        let installation = PFInstallation.currentInstallation()
        installation["versionNumber"] = versionNumber
        installation["username"] = user.email
        installation["deviceId"] = UIDevice.currentDevice().identifierForVendor?.UUIDString
        installation["operatingSystem"] = NSProcessInfo.processInfo().operatingSystemVersionString
        installation["platform"] = UIDeviceHardware.platformString()
        PFInstallation.currentInstallation().saveEventually()
    }
}
