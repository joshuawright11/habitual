//
//  DaysCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

/// A cell representing the days of the week on which the `Habit` should be 
/// completed.
class DaysCell: HabitDetailCell {
    
    /// 7 Buttons representing the days of the week.
    @IBOutlet var dayButtons: [UIButton]! {
        didSet {
            for bt in dayButtons {
                bt.backgroundColor = Colors.background
                bt.layer.cornerRadius = 4.0
                bt.setTitleColor(Colors.accent, forState: .Normal)
                bt.titleLabel?.font = Fonts.sectionHeaderBold
                
                bt.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: .TouchUpInside)
            }
        }
    }

    // ********************************
    // MARK: - HabitDetailCell Override
    // ********************************
    
    override func configure() {
        for bt in dayButtons {
            if self.habit!.daysToComplete.contains((bt.titleLabel?.text)!) {
                bt.setTitleColor(Colors.accentSecondary, forState: .Normal)
            }
        }
    }
    
    // ***************
    // MARK: - Targets
    // ***************
    
    /// When a button is pressed toggle its color and update the 
    /// `daysToComplete` of the `Habit`.
    func buttonPressed(button: UIButton) {
        let string: String = (button.titleLabel?.text)!
        if habit!.daysToComplete.contains(string) {
            habit!.daysToComplete.removeAtIndex((habit!.daysToComplete.indexOf(string))!)
            button.setTitleColor(Colors.accent, forState: .Normal)
        }else{
            habit?.daysToComplete.append(string)
            button.setTitleColor(Colors.accentSecondary, forState: .Normal)
        }
    }
}
