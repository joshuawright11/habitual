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
            swich.tintColor = Colors.accent
            swich.addTarget(self, action: Selector("swichChanged:"), forControlEvents: .ValueChanged)
        }
    }
    
    var privat: Bool = false

    // ********************************
    // MARK: - HabitDetailCell Override
    // ********************************
    
    override func configure() {
        if privat {
            titleLabel.text = "This habit should be hidden from all of my connections, except those to whom it is accountable."
            swich.setOn(habit.privat, animated: false)
        } else {
            swich.setOn(habit.notificationsEnabled, animated: false)
        }
    }
    
    // ***************
    // MARK: - Targets
    // ***************
    
    /// Change the notifications enabled property of the `Habit` whenever the
    /// switch is toggled.
    func swichChanged(swich: UISwitch) {
        if privat {
            habit.privat = !habit.privat
        } else {
            habit?.notificationsEnabled = !habit!.notificationsEnabled
            Utilities.postNotification(Notifications.accountabilityToggled)
        }
    }
}
