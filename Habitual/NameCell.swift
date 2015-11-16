//
//  NameCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class NameCell: UITableViewCell, HabitDetailCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    
    var habit:Habit?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func doAppearance() {
        selectionStyle = UITableViewCellSelectionStyle.None
        let str = NSAttributedString(string: "The name of my habit is...", attributes: [NSForegroundColorAttributeName:kColorTextSecondary, NSFontAttributeName:kFontSectionHeader])
        textField.attributedPlaceholder = str
        
        textField.textColor = kColorTextMain
        textField.font = kFontSectionHeader
    }
    
    func configure(habit: Habit) {
        self.habit = habit
        textField.delegate = self
        doAppearance()
    }
    
    // MARK - UITextFieldDelegate methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        habit?.name = textField.text!
        return true
    }
}
