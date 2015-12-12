//
//  SignupViewController.swift
//  Habitual
//
//  Created by Josh Wright on 7/22/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit

// -TODO: Needs refactoring/documentation

class SignupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    var signupEnabled = true
    
    override func viewDidLoad() {
        doAppearance()
        
        setupKeyboardNotifications()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        let button = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel")
        self.navigationItem.leftBarButtonItem = button
    }
    
    func setupKeyboardNotifications() {
        Utilities.registerForNotification(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification)
        Utilities.registerForNotification(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        let insets = UIEdgeInsetsMake(0, 0, kbSize!.height, 0)
        
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        
        self.scrollView.scrollRectToVisible(passwordTextField.frame, animated: true)
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let insets = UIEdgeInsetsZero
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
    }
    
    func dismissKeyboard() {
        usernameTextField.endEditing(true)
        passwordTextField.endEditing(true)
        nameTextField.endEditing(true)
    }
    
    func doAppearance() {
        titleLabel.font = Fonts.mainTitle
        titleLabel.textColor = Colors.textMain
        
        infoLabel.font = Fonts.cellSubtitle
        infoLabel.textColor = Colors.textMain
        
        usernameTextField.delegate = self
        usernameTextField.layer.cornerRadius = 15
        usernameTextField.backgroundColor = Colors.textViewBackground
        let spacer1 = UIView(frame: CGRectMake(0, 0, 21, 21))
        usernameTextField.leftViewMode = .Always
        usernameTextField.leftView = spacer1
        
        let str1 = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName:Colors.textSecondary, NSFontAttributeName:Fonts.sectionHeader])
        usernameTextField.attributedPlaceholder = str1
        
        usernameTextField.textColor = Colors.background
        usernameTextField.font = Fonts.sectionHeader
        
        passwordTextField.delegate = self
        passwordTextField.layer.cornerRadius = 15
        passwordTextField.backgroundColor = Colors.textViewBackground
        let spacer2 = UIView(frame: CGRectMake(0, 0, 21, 21))
        passwordTextField.leftViewMode = .Always
        passwordTextField.leftView = spacer2
        
        let str2 = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:Colors.textSecondary, NSFontAttributeName:Fonts.sectionHeader])
        passwordTextField.attributedPlaceholder = str2
        
        passwordTextField.textColor = Colors.background
        passwordTextField.font = Fonts.sectionHeader
        
        nameTextField.delegate = self
        nameTextField.layer.cornerRadius = 15
        nameTextField.backgroundColor = Colors.textViewBackground
        let spacer3 = UIView(frame: CGRectMake(0, 0, 21, 21))
        nameTextField.leftViewMode = .Always
        nameTextField.leftView = spacer3
        
        let str3 = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName:Colors.textSecondary, NSFontAttributeName:Fonts.sectionHeader])
        nameTextField.attributedPlaceholder = str3
        
        nameTextField.textColor = Colors.background
        nameTextField.font = Fonts.sectionHeader
        
        loginButton.layer.cornerRadius = 15
        loginButton.setTitleColor(Colors.textMain, forState: .Normal)
        loginButton.titleLabel?.font = Fonts.cellTitle
        
        signupButton.setTitleColor(Colors.accent, forState: .Normal)
        signupButton.titleLabel?.font = Fonts.sectionHeader
        
        self.loginButton.setTitle("Sign up", forState: .Normal)
        self.signupButton.setTitle("Already have an account?", forState: .Normal)
    }
    
    func inputIsValid() -> Bool {
        if(usernameTextField.text?.characters.count < 5){
            Utilities.alertWarning("Username must be at least 5 characters", vc: self.navigationController!)
            return false
        }else if(passwordTextField.text?.characters.count < 5){
            Utilities.alertWarning("Password must be at least 5 characters", vc: self.navigationController!)
            return false
        }else if(signupEnabled && nameTextField.text?.componentsSeparatedByString(" ").count < 2){
            Utilities.alertWarning("Please enter your first and last name", vc: self.navigationController!)
            return false
        }
        return true
    }
    
    func cancel() {
        dismissKeyboard()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func toggleSignup(){
        
        signupEnabled = !signupEnabled
        
        if signupEnabled {
            self.nameTextField.hidden = false
            self.loginButton.setTitle("Sign up", forState: .Normal)
            self.signupButton.setTitle("Already have an account?", forState: .Normal)
        } else {
            self.nameTextField.hidden = true
            self.loginButton.setTitle("Login", forState: .Normal)
            self.signupButton.setTitle("Don't have an account?", forState: .Normal)
        }
    }
    
    @IBAction func complete(){
        
        if !inputIsValid() {
            return
        }
        
        if signupEnabled {
            WebServices.signup(usernameTextField.text!, password: passwordTextField.text!, name: nameTextField.text!) { (success, user) -> () in
                
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    AuthManager.currentUser = user
                    Utilities.postNotification(Notifications.reloadNetworkOnline)
                }else{
                    Utilities.alertError("An account with that username already exists", vc: self.navigationController!)
                }
            }
        } else {
            WebServices.login(usernameTextField.text!, password: passwordTextField.text!) { (success, user) -> () in
                if success {
                    AuthManager.currentUser = user
                    Utilities.postNotification(Notifications.reloadNetworkOnline)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }else{
                    Utilities.alertError("Invalid username or password", vc: self.navigationController!)
                }
            }
        }
    }
    
    // MARK - UITextFieldDelegate methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == .Next {
            self.scrollView.scrollRectToVisible(passwordTextField.frame, animated: true)
            if textField.isEqual(nameTextField) {
                usernameTextField.becomeFirstResponder()
            }else{
                passwordTextField.becomeFirstResponder()
            }
            
            return false
        } else {
            textField.resignFirstResponder()
            return true
        }
    }
}
