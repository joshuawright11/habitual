//
//  AccountabilityCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class AccountabilityCell: UITableViewCell, HabitDetailCell {

    @IBOutlet weak var swich: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    
    var habit:Habit?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func doAppearance() {
        selectionStyle = UITableViewCellSelectionStyle.None
        titleLabel.font = kFontSectionHeader
        titleLabel.textColor = kColorTextMain
        
        swich.tintColor = kColorAccent
    }
    
    func configure(habit: Habit) {
        self.habit = habit
        swich.addTarget(self, action: Selector("swichChanged:"), forControlEvents: .ValueChanged)
        swich.setOn(habit.notificationsEnabled, animated: false)
        doAppearance()
    }
    
    func swichChanged(swich: UISwitch) {
        habit?.notificationsEnabled = !habit!.notificationsEnabled
        Utilities.postNotification(kNotificationIdentifierToggleAccountability)
    }
}
