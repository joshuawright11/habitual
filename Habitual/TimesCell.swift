//
//  TimesCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class TimesCell: UITableViewCell, HabitDetailCell {

    @IBOutlet weak var timesLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
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
        timesLabel.font = kFontSectionHeader
        timesLabel.textColor = kColorAccent
        
        stepper.tintColor = kColorAccent
    }
    
    func configure(habit: Habit) {
        self.habit = habit
        doAppearance()
        stepper.value = Double(habit.timesToComplete)
        self.timesLabel.text = "\(Int(stepper.value))"
        stepper.addTarget(self, action: Selector("stepperChanged:"), forControlEvents: .ValueChanged)
    }
    
    func stepperChanged(stepper: UIStepper) {
        habit?.timesToComplete = Int(stepper.value)
        timesLabel.text = "\(habit!.timesToComplete)"
    }
}
