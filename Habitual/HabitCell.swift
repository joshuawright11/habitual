//
//  HabitCell.swift
//  Habitual
//
//  Created by Josh Wright on 7/10/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit

class HabitCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureForHabit(habit: Habit) {

        self.titleLabel.text = habit.name
        self.countLabel.text = "\(habit.datesCompleted.count) completions"
        self.repeatLabel.text = repeatTextForHabit(habit)
    }
    
    func repeatTextForHabit(habit: Habit) -> String{
        
        switch habit.frequency{
        case .Daily:
            return "\(habit.timesToComplete) per day"
        case .Weekly:
            return "\(habit.timesToComplete) per week"
        case .Monthly:
            return "\(habit.timesToComplete) per month"
        }
    }
}
