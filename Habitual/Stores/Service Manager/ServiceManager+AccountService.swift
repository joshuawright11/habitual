//
//  ServiceManager+AccountService.swift
//  Ignite
//
//  Created by Josh Wright on 4/28/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import Foundation
import Parse
import Timepiece
import FBSDKLoginKit
import ParseFacebookUtilsV4

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
