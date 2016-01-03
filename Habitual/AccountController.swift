//
//  AccountController.swift
//  Ignite
//
//  Created by Josh Wright on 12/29/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import ParseFacebookUtilsV4
import Timepiece

class AccountController: UIViewController {

    let fbPermissions = ["public_profile","email","user_friends"]
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = Fonts.mainTitle
        }
    }
    
    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = Fonts.message
            subtitleLabel.textColor = Colors.textSubtitle
        }
    }
    
    @IBOutlet weak var fbButton: UIButton! {
        didSet {
            fbButton.layer.cornerRadius = 4
            Styler.viewShaderSmall(fbButton)
        }
    }
    
    @IBOutlet weak var orLabel: UILabel! {
        didSet {
            orLabel.font = Fonts.secondaryLight
            orLabel.textColor = Colors.textSubtitle
        }
    }
    
    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            signUpButton.backgroundColor = Colors.barBackground
            signUpButton.layer.cornerRadius = 7
            signUpButton.layer.borderWidth = 2
            signUpButton.layer.borderColor = Colors.textMain.CGColor
            Styler.viewShaderSmall(signUpButton)
        }
    }
    
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.titleLabel?.font = Fonts.message
            loginButton.tintColor = Colors.textSubtitle
        }
    }
    
    @IBOutlet weak var rightSpacer: UIView! {
        didSet {
            rightSpacer.backgroundColor = Colors.textSubtitle
        }
    }
    
    @IBOutlet weak var leftSpacer: UIView! {
        didSet {
            leftSpacer.backgroundColor = Colors.textSubtitle
        }
    }
    
    @IBAction func fbAccount() {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(fbPermissions) { (user, error) -> Void in
            if let user = user {
                self.getUserInfo()
                if user.isNew {
                    /// New user signed up with facebook
                    
                } else {
                    /// the user logged in to an existing account

                }
            } else {
                /// user cancelled the login
            }
        }
    }
    
    private func getUserInfo() {
        let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, email, first_name, last_name"])
        req.startWithCompletionHandler { (connection, result, error) -> Void in
            if error != nil {
                print("\(error.localizedDescription)")
            } else if result != nil {
                let userId = result["id"] as! String
                let userFirstName = result["first_name"] as! String
                let userLastName = result["last_name"] as! String
                let userEmail = result["email"] as! String
                let userProfileSmallURL = NSURL(string: "https://graph.facebook.com/\(userId)/picture")
                let pictureData = NSData(contentsOfURL: userProfileSmallURL!)
                
                let myUser:PFUser = PFUser.currentUser()!
                
                if let pictureData = pictureData {
                    let file = PFFile(data: pictureData)
                    myUser.setObject(file!, forKey: "profilePicture")
                }
                
                myUser["name"] = "\(userFirstName) \(userLastName)"
                myUser.email = userEmail
                myUser["habits"] = []
                myUser["paymentDue"] = NSDate() + 1.year
                myUser["following"] = []
                
                myUser.saveInBackground()
                
                AuthManager.currentUser = User(parseUser: myUser, withHabits: false)
                Utilities.postNotification(Notifications.reloadNetworkOnline)
                self.dismissViewControllerAnimated(true, completion: nil)
                
            } else {
                print("no result")
            }
        }
    }
    
    @IBAction func emailAccount(sender: UIButton) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("signin") as! SignupViewController
        vc.newAccount = sender == signUpButton
        presentViewController(vc, animated: true, completion: nil)
    }
}
