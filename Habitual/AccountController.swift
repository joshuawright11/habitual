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
            
            if upgrade {
                subtitleLabel.textAlignment = .Justified
                subtitleLabel.text = "Hey! Thanks for using Ignite. In order to better protect the security of your account and allow you to find friends using Ignite more easily, we now require that all users of Ignite have an account with a legitimate email. \n\nYou can do so by connecting with a Facebook account (which you can use to find friends using Ignite!), or entering your email address. We will never post on your Facebook or send you regular emails and, as always, your habits will not be visible to anyone you have not approved as a connection."
            } else {
                subtitleLabel.text = "Sign up for Ignite using Facebook or email.\n\n\nWe will never post on your Facebook or send you regular emails and your habits will not be visible to anyone you have not approved as a connection."
            }
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
            
            if upgrade {
                signUpButton.setTitle("Enter your email", forState: .Normal)
            }
        }
    }
    
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.titleLabel?.font = Fonts.message
            loginButton.tintColor = Colors.textSubtitle
            if upgrade {
                loginButton.hidden = true
            }
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
        
        if upgrade {
            PFFacebookUtils.linkUserInBackground(PFUser.currentUser()!, withReadPermissions: fbPermissions, block: { (success, error) -> Void in
                if success {
                    print("nice!")
                    self.getUserInfo()
                } else {
                    print("fail")
                }
            })
        } else {
            PFFacebookUtils.logInInBackgroundWithReadPermissions(fbPermissions) { (user, error) -> Void in
                
                if error != nil {
                    print("\(error?.localizedDescription)")
                    return
                }
                
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
    }
    
    var upgrade: Bool = false
    
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

                if !self.upgrade {
                    myUser["habits"] = []
                    myUser["paymentDue"] = NSDate() + 1.year
                    myUser["following"] = []
                }
                
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
        
        if upgrade {
            var tField: UITextField!
            
            func configurationTextField(textField: UITextField!)
            {
                textField.placeholder = "username@example.com"
                tField = textField
            }
            
            let alert = UIAlertController(title: "Enter Your Email", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addTextFieldWithConfigurationHandler(configurationTextField)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
            alert.addAction(UIAlertAction(title: "Finish", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
                if Utilities.validEmail(tField.text!) {
                    PFUser.currentUser()?.email = tField.text!
                    PFUser.currentUser()!["paymentDue"] = NSDate() + 1.year
                    PFUser.currentUser()?.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success {
                            Utilities.alertSuccess("Thanks!", vc: self.presentingViewController!)
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            Utilities.alertError("That email address is in use.", vc: self)
                        }
                    })
                } else {
                    Utilities.alertWarning("Invalid email.", vc: self)
                }
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("signin") as! SignupViewController
            vc.newAccount = sender == signUpButton
            presentViewController(vc, animated: true, completion: nil)
        }
    }
}
