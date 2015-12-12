//
//  AccountabilityCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

/// A cell representing the `notificationsEnabled` of the `Habit`.
class AccountabilityCell: HabitDetailCell {

    /// A `UISwitch` to toggle the 'notificationsEnabled' of the `Habit`
    @IBOutlet weak var swich: UISwitch! {
        didSet {
            swich.tintColor = kColorAccent
            swich.addTarget(self, action: Selector("swichChanged:"), forControlEvents: .ValueChanged)
        }
    }

    // ********************************
    // MARK: - HabitDetailCell Override
    // ********************************
    
    override func configure() {
        swich.setOn(habit.notificationsEnabled, animated: false)
    }
    
    // ***************
    // MARK: - Targets
    // ***************
    
    /// Change the notifications enabled property of the `Habit` whenever the
    /// switch is toggled.
    func swichChanged(swich: UISwitch) {
        habit?.notificationsEnabled = !habit!.notificationsEnabled
        Utilities.postNotification(kNotificationIdentifierToggleAccountability)
    }
}
