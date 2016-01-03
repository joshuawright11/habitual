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
    @IBOutlet weak var usernameTextField: UITextField! {
        didSet {
            usernameTextField.layer.cornerRadius = 7
            Styler.viewShaderSmall(usernameTextField)
        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.layer.cornerRadius = 7
            Styler.viewShaderSmall(passwordTextField)
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.layer.cornerRadius = 7
            Styler.viewShaderSmall(nameTextField)
        }
    }
    
    @IBOutlet weak var nameTextFieldHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.layer.cornerRadius = 7
            Styler.viewShaderSmall(loginButton)
        }
    }

    
    var newAccount = true
    
    override func viewDidLoad() {
        doAppearance()
        
        if(!newAccount) {
            nameTextFieldHeight.constant = 0
        }
        
        setupKeyboardNotifications()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
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
        
        usernameTextField.delegate = self
        usernameTextField.backgroundColor = Colors.textMain.colorWithAlphaComponent(0.03)
        let spacer1 = UIView(frame: CGRectMake(0, 0, 21, 21))
        usernameTextField.leftViewMode = .Always
        usernameTextField.leftView = spacer1
        
        let str1 = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName:Colors.textSubtitle, NSFontAttributeName:Fonts.message])
        usernameTextField.attributedPlaceholder = str1
        
        usernameTextField.textColor = Colors.textMain
        usernameTextField.font = Fonts.message
        
        passwordTextField.delegate = self
        passwordTextField.backgroundColor = Colors.textMain.colorWithAlphaComponent(0.03)
        let spacer2 = UIView(frame: CGRectMake(0, 0, 21, 21))
        passwordTextField.leftViewMode = .Always
        passwordTextField.leftView = spacer2
        
        let str2 = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:Colors.textSubtitle, NSFontAttributeName:Fonts.message])
        passwordTextField.attributedPlaceholder = str2
        
        passwordTextField.textColor = Colors.textMain
        passwordTextField.font = Fonts.message
        
        nameTextField.delegate = self
        nameTextField.backgroundColor = Colors.textMain.colorWithAlphaComponent(0.03)
        let spacer3 = UIView(frame: CGRectMake(0, 0, 21, 21))
        nameTextField.leftViewMode = .Always
        nameTextField.leftView = spacer3
        
        let str3 = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName:Colors.textSubtitle, NSFontAttributeName:Fonts.message])
        nameTextField.attributedPlaceholder = str3
        
        nameTextField.textColor = Colors.textMain
        nameTextField.font = Fonts.message
        
        loginButton.setTitleColor(Colors.textMain, forState: .Normal)
        loginButton.titleLabel?.font = Fonts.message
        
        self.loginButton.setTitle("Sign up", forState: .Normal)
        
        if (!newAccount) {
            loginButton.setTitle("Log in", forState: .Normal)
            nameTextField.hidden = true
        }
    }
    
    func inputIsValid() -> Bool {
        
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if(!emailTest.evaluateWithObject(usernameTextField.text)){
            Utilities.alertWarning("Invalid email.", vc: self)
            return false
        }else if(passwordTextField.text?.characters.count < 5){
            Utilities.alertWarning("Password must be at least 5 characters.", vc: self)
            return false
        }else if(newAccount && nameTextField.text?.componentsSeparatedByString(" ").count < 2){
            Utilities.alertWarning("Please enter your first and last name.", vc: self)
            return false
        }
        return true
    }
    
    func cancel() {
        dismissKeyboard()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func complete(){
        
        if !inputIsValid() {
            return
        }
        
        if newAccount {
            WebServices.signup(usernameTextField.text!, password: passwordTextField.text!, name: nameTextField.text!) { (success, user) -> () in
                
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    AuthManager.currentUser = user
                    Utilities.postNotification(Notifications.reloadNetworkOnline)
                }else{
                    Utilities.alertError("An account with that email already exists", vc: self)
                }
            }
        } else {
            WebServices.login(usernameTextField.text!, password: passwordTextField.text!) { (success, user) -> () in
                if success {
                    AuthManager.currentUser = user
                    Utilities.postNotification(Notifications.reloadNetworkOnline)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }else{
                    Utilities.alertError("Invalid email or password", vc: self)
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
