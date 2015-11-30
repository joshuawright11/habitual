//
//  NameCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import TextFieldEffects

class NameCell: UITableViewCell, HabitDetailCell, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
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
        let str = NSAttributedString(string: "Go for a run...", attributes: [NSForegroundColorAttributeName:kColorAccent, NSFontAttributeName:kFontSectionHeaderBold])
        textField.attributedPlaceholder = str
        
        titleLabel.font = kFontSectionHeader
        titleLabel.textColor = kColorTextMain
        
        textField.textColor = kColorAccentSecondary
        textField.font = kFontSectionHeaderBold
    }
    
    func configure(habit: Habit) {
        self.habit = habit
        textField.delegate = self
        
        textField.text = habit.name
        
        textField.addTarget(self, action: "textFieldChanged:", forControlEvents: .EditingChanged)
        
        doAppearance()
    }
    
    func textFieldChanged(textField: UITextField) {
        habit?.name = textField.text!
    }
    
    // MARK - UITextFieldDelegate methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        habit?.name = textField.text!
        return true
    }
}
