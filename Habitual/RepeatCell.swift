//
//  RepeatCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

/// A cell representing the `Frequency` at which the `Habit` should be 
/// completed.
class RepeatCell: HabitDetailCell {

    /// A button representing the `Daily` `Frequency`.
    @IBOutlet weak var dayButton: UIButton! {
        didSet {
            dayButton.titleLabel!.font = kFontSectionHeaderBold
            dayButton.tintColor = kColorAccent
            dayButton.addTarget(self, action: Selector("buttonPressed:"),
                forControlEvents: .TouchUpInside)
        }
    }

    /// A button representing the `Weekly` `Frequency`.
    @IBOutlet weak var weekButton: UIButton! {
        didSet {
            weekButton.titleLabel!.font = kFontSectionHeaderBold
            weekButton.tintColor = kColorAccent
            weekButton.addTarget(self, action: Selector("buttonPressed:"),
                forControlEvents: .TouchUpInside)
        }
    }

    /// A button representing the `Monthly` `Frequency`.
    @IBOutlet weak var monthButton: UIButton! {
        didSet {
            monthButton.titleLabel!.font = kFontSectionHeaderBold
            monthButton.tintColor = kColorAccent
            monthButton.addTarget(self, action: Selector("buttonPressed:"),
                forControlEvents: .TouchUpInside)
        }
    }
    
    // ********************************
    // MARK: - HabitDetailCell Override
    // ********************************
    
    override func configure() {
        switch habit.frequency {
        case .Daily: dayButton.setTitleColor(kColorAccentSecondary, forState: .Normal)
        case .Weekly: weekButton.setTitleColor(kColorAccentSecondary, forState: .Normal)
        case .Monthly: monthButton.setTitleColor(kColorAccentSecondary, forState: .Normal)
        }
    }
    
    // ***************
    // MARK: - Targets
    // ***************
    
    /// Update the frequency of the `Habit` when a button is pressed and change
    /// toggle the color of the button.
    func buttonPressed(button: UIButton) {
        let string:String = (button.titleLabel?.text)!
        
        let initialFreq = habit?.frequency
        
        switch string {
        case "DAY": habit?.frequency = .Daily
        case "WEEK": habit?.frequency = .Weekly
        case "MONTH": habit?.frequency = .Monthly
        default: habit?.frequency = .Daily
        }
        
        dayButton.setTitleColor(kColorAccent, forState: .Normal)
        weekButton.setTitleColor(kColorAccent, forState: .Normal)
        monthButton.setTitleColor(kColorAccent, forState: .Normal)
        
        button.setTitleColor(kColorAccentSecondary, forState: .Normal)
        
        if(initialFreq == .Daily && habit?.frequency != .Daily)
            || (initialFreq != .Daily && habit?.frequency == .Daily)
        {Utilities.postNotification(kNotificationIdentifierToggleDOTW)}
    }
}
