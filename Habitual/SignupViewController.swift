//
//  SignupViewController.swift
//  Habitual
//
//  Created by Josh Wright on 7/22/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func signup(){
        WebServices.signup(usernameTextField.text, password: passwordTextField.text) { (user) -> () in
            self.dismissViewControllerAnimated(true, completion: nil)
            Utilities.postNotification(kNotificationIdentifierUserLoggedIn)
        }
    }
    
    @IBAction func login(){
        WebServices.login(usernameTextField.text, password: passwordTextField.text) { (user) -> () in
            self.dismissViewControllerAnimated(true, completion: nil)
            Utilities.postNotification(kNotificationIdentifierUserLoggedIn)
        }
    }
}
