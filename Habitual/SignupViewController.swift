//
//  SignupViewController.swift
//  Habitual
//
//  Created by Josh Wright on 7/22/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!

    override func viewDidLoad() {
        doAppearance()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        let button = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel")
        self.navigationItem.leftBarButtonItem = button
    }
    
    func dismissKeyboard() {
        usernameTextField.endEditing(true)
        passwordTextField.endEditing(true)
    }
    
    func doAppearance() {
        titleLabel.font = kFontMainTitle
        titleLabel.textColor = kColorTextMain
        
        infoLabel.font = kFontCellSubtitle
        infoLabel.textColor = kColorTextMain
        
        usernameTextField.delegate = self
        usernameTextField.layer.cornerRadius = 15
        usernameTextField.backgroundColor = kColorTextViewBackground
        let spacer1 = UIView(frame: CGRectMake(0, 0, 21, 21))
        usernameTextField.leftViewMode = .Always
        usernameTextField.leftView = spacer1
        
        let str1 = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName:kColorTextSecondary, NSFontAttributeName:kFontSectionHeader])
        usernameTextField.attributedPlaceholder = str1
        
        usernameTextField.textColor = kColorBackground
        usernameTextField.font = kFontSectionHeader
        
        passwordTextField.delegate = self
        passwordTextField.layer.cornerRadius = 15
        passwordTextField.backgroundColor = kColorTextViewBackground
        let spacer2 = UIView(frame: CGRectMake(0, 0, 21, 21))
        passwordTextField.leftViewMode = .Always
        passwordTextField.leftView = spacer2
        
        let str2 = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:kColorTextSecondary, NSFontAttributeName:kFontSectionHeader])
        passwordTextField.attributedPlaceholder = str2
        
        passwordTextField.textColor = kColorBackground
        passwordTextField.font = kFontSectionHeader
        
        nameTextField.delegate = self
        nameTextField.layer.cornerRadius = 15
        nameTextField.backgroundColor = kColorTextViewBackground
        let spacer3 = UIView(frame: CGRectMake(0, 0, 21, 21))
        nameTextField.leftViewMode = .Always
        nameTextField.leftView = spacer3
        
        let str3 = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName:kColorTextSecondary, NSFontAttributeName:kFontSectionHeader])
        nameTextField.attributedPlaceholder = str3
        
        nameTextField.textColor = kColorBackground
        nameTextField.font = kFontSectionHeader
        
        loginButton.layer.cornerRadius = 15
        loginButton.setTitleColor(kColorTextMain, forState: .Normal)
        loginButton.titleLabel?.font = kFontCellTitle
        
        signupButton.setTitleColor(kColorTextSecondary, forState: .Normal)
        signupButton.titleLabel?.font = kFontSectionHeader
        
        
        
//        gradientView.backgroundColor = UIColor.clearColor()
    }
    
//    @IBOutlet weak var gradientView: UIView!
//    func doGradient() {
//        gradientView.backgroundColor = UIColor.clearColor()
//        loginButton.backgroundColor = UIColor.clearColor()
//
//        gradientView.frame = loginButton.frame
//        
//        let gl = CAGradientLayer()
//        gl.colors = [kColorLogoOrange.CGColor, kColorLogoRed.CGColor]
//        gl.locations = [0.0, 1.0]
//        gl.frame = gradientView.frame
//        
//        gradientView.layer.insertSublayer(gl, atIndex: 0)
//        gradientView.layer.cornerRadius = 15
//    }
    
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signup(){
        WebServices.signup(usernameTextField.text!, password: passwordTextField.text!, name: nameTextField.text!) { (success, user) -> () in
            self.dismissViewControllerAnimated(true, completion: nil)
            AuthManager.currentUser = user
            Utilities.postNotification(kNotificationIdentifierReloadConnections)
        }
    }
    
    @IBAction func login(){
        WebServices.login(usernameTextField.text!, password: passwordTextField.text!) { (success, user) -> () in
            self.dismissViewControllerAnimated(true, completion: nil)
            AuthManager.currentUser = user
            Utilities.postNotification(kNotificationIdentifierReloadConnections)
        }
    }
    
    // MARK - UITextFieldDelegate methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
