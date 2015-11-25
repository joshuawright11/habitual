//
//  DaysCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class DaysCell: UITableViewCell, HabitDetailCell {


    @IBOutlet var dayButtons: [UIButton]!
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
        
        for bt in dayButtons {
            bt.backgroundColor = kColorBackground
            bt.layer.cornerRadius = 4.0
            bt.setTitleColor(kColorAccent, forState: .Normal)
            bt.titleLabel?.font = kFontSectionHeaderBold
            
            bt.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: .TouchUpInside)
        }
    }
    
    func buttonPressed(button: UIButton) {
        let string: String = (button.titleLabel?.text)!
        if habit!.daysToComplete.contains(string) {
            habit!.daysToComplete.removeAtIndex((habit!.daysToComplete.indexOf(string))!)
            button.setTitleColor(kColorAccent, forState: .Normal)
        }else{
            habit?.daysToComplete.append(string)
            button.setTitleColor(kColorAccentSecondary, forState: .Normal)
        }
    }
    
    func configure(habit: Habit) {
        self.habit = habit
        doAppearance()
        for bt in dayButtons {
            if self.habit!.daysToComplete.contains((bt.titleLabel?.text)!) {
                bt.setTitleColor(kColorAccentSecondary, forState: .Normal)
            }
        }
    }
    
}
