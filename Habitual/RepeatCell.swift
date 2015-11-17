//
//  RepeatCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class RepeatCell: UITableViewCell, HabitDetailCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!

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
        dayButton.titleLabel!.font = kFontSectionHeader
        dayButton.tintColor = kColorAccent
        weekButton.titleLabel!.font = kFontSectionHeader
        weekButton.tintColor = kColorAccent
        monthButton.titleLabel!.font = kFontSectionHeader
        monthButton.tintColor = kColorAccent
        
        dayButton.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: .TouchUpInside)
        weekButton.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: .TouchUpInside)
        monthButton.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: .TouchUpInside)
    }
    
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
    
    func configure(habit: Habit) {
        self.habit = habit
        doAppearance()
        switch habit.frequency {
        case .Daily: dayButton.setTitleColor(kColorAccentSecondary, forState: .Normal)
        case .Weekly: weekButton.setTitleColor(kColorAccentSecondary, forState: .Normal)
        case .Monthly: monthButton.setTitleColor(kColorAccentSecondary, forState: .Normal)
        }
    }
    
}
