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
            dayButton.titleLabel!.font = Fonts.sectionHeader
            dayButton.tintColor = Colors.accent
            dayButton.addTarget(self, action: Selector("buttonPressed:"),
                forControlEvents: .TouchUpInside)
        }
    }

    /// A button representing the `Weekly` `Frequency`.
    @IBOutlet weak var weekButton: UIButton! {
        didSet {
            weekButton.titleLabel!.font = Fonts.sectionHeader
            weekButton.tintColor = Colors.accent
            weekButton.addTarget(self, action: Selector("buttonPressed:"),
                forControlEvents: .TouchUpInside)
        }
    }

    /// A button representing the `Monthly` `Frequency`.
    @IBOutlet weak var monthButton: UIButton! {
        didSet {
            monthButton.titleLabel!.font = Fonts.sectionHeader
            monthButton.tintColor = Colors.accent
            monthButton.addTarget(self, action: Selector("buttonPressed:"),
                forControlEvents: .TouchUpInside)
        }
    }
    
    // ********************************
    // MARK: - HabitDetailCell Override
    // ********************************
    
    override func configure() {
        switch habit.frequency {
        case .Daily:
            dayButton.setTitleColor(Colors.accentSecondary, forState: .Normal)
            dayButton.titleLabel?.font = Fonts.sectionHeaderBold
        case .Weekly:
            weekButton.setTitleColor(Colors.accentSecondary, forState: .Normal)
            weekButton.titleLabel?.font = Fonts.sectionHeaderBold
        case .Monthly:
            monthButton.setTitleColor(Colors.accentSecondary, forState: .Normal)
            monthButton.titleLabel?.font = Fonts.sectionHeaderBold
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
        
        dayButton.setTitleColor(Colors.accent, forState: .Normal)
        dayButton.titleLabel?.font = Fonts.sectionHeader
        weekButton.setTitleColor(Colors.accent, forState: .Normal)
        weekButton.titleLabel?.font = Fonts.sectionHeader
        monthButton.setTitleColor(Colors.accent, forState: .Normal)
        monthButton.titleLabel?.font = Fonts.sectionHeader
        
        button.setTitleColor(Colors.accentSecondary, forState: .Normal)
        button.titleLabel?.font = Fonts.sectionHeaderBold
        
        if(initialFreq == .Daily && habit?.frequency != .Daily)
            || (initialFreq != .Daily && habit?.frequency == .Daily)
        {Utilities.postNotification(Notifications.dotwToggled)}
    }
}
