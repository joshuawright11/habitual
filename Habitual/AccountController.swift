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
    
    var accountService: AccountService!

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
            
            if accountService.isFakeEmail {
                subtitleLabel.textAlignment = .Justified
                subtitleLabel.text = "In order to better protect the security of your account, we now require that all users of Ignite have an account with a legitimate email. \n\nYou can do so by connecting with a Facebook account or entering your email address. You public habits will not be visible to anyone except your connections."
            } else {
                subtitleLabel.text = "Sign in to Ignite using Facebook or email."
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
            
            if accountService.isFakeEmail {
                signUpButton.setTitle("Enter your email", forState: .Normal)
            }
        }
    }
    
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.titleLabel?.font = Fonts.message
            loginButton.tintColor = Colors.textSubtitle
            if accountService.isFakeEmail {
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
    
    override func viewDidLoad() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
    }
    
    @IBAction func fbAccount() {
        
        accountService.connectWithFacebook({ (success) in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                Utilities.alertError("Something went wrong", vc: self)
            }
        })
    }
    
    @IBAction func emailAccount(sender: UIButton) {
        
        if accountService.isFakeEmail {
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
            presentViewController(alert, animated: true, completion: nil)
        } else {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("signin") as! SignupController
            vc.newAccount = sender == signUpButton
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
