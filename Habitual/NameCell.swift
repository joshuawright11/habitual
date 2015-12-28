//
//  NameCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import TextFieldEffects

/// A cell representing the name of the `Habit`.
class NameCell: HabitDetailCell, UITextFieldDelegate {

    /// A `UITextField` in which the user will enter the name of their habit.
    @IBOutlet weak var textField: UITextField! {
        didSet {
            let str = NSAttributedString(string: "Habit name here...", attributes: [NSForegroundColorAttributeName:Colors.accent, NSFontAttributeName:Fonts.buttonSelected])
            textField.attributedPlaceholder = str
            textField.textColor = Colors.accentSecondary
            textField.font = Fonts.buttonSelected
            textField.delegate = self
            textField.addTarget(self, action: "textFieldChanged:", forControlEvents: .EditingChanged)
        }
    }
    
    // ********************************
    // MARK: - HabitDetailCell Override
    // ********************************
    
    override func configure() {
        textField.text = habit.name
    }
    
    // ***************
    // MARK: - Targets
    // ***************
    
    /// Called whenever the `UITextField` changes, so that the `habit` name can
    /// be updated.
    func textFieldChanged(textField: UITextField) {
        habit.name = textField.text!
    }
    
    // ***********************************
    // MARK: - UITextFieldDelegate Methods
    // ***********************************
    
    /// Dismiss the keyboard when `return` is pressed.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
