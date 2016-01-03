//
//  HabitCell.swift
//  Habitual
//
//  Created by Josh Wright on 7/10/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit

// -TODO: Needs refactoring/documentation

class HabitCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var coloriv: UIImageView!
    @IBOutlet weak var checkiv: UIImageView!
    
    var habit:Habit!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func doAppearance() {
        titleLabel.font = Fonts.cellTitle
        titleLabel.textColor = Colors.textMain
        repeatLabel.font = Fonts.cellSubtitle
        repeatLabel.textColor = Colors.textSubtitle
        countLabel.font = Fonts.sectionHeader
        countLabel.textColor = Colors.textMain
        
        coloriv.backgroundColor = UIColor(hexString: habit.color)
        self.checkiv.image = self.checkiv.image?.imageWithRenderingMode(.AlwaysTemplate)
                self.checkiv.tintColor = UIColor(hexString: habit.color)
        coloriv.layer.cornerRadius = 10.0
        
        checkiv.layer.backgroundColor = Colors.background.CGColor
    }
    
    func configureForHabit(habit: Habit) {
        
        self.habit = habit
        selectionStyle = .None
        doAppearance()
        
        self.titleLabel.text = habit.name
        self.countLabel.text = "\(habit.datesCompleted.count) "
        self.repeatLabel.text = repeatTextForHabit(habit)
    }
    
    func repeatTextForHabit(habit: Habit) -> String{
        
        let timesString = habit.timesToComplete != 1 ? "\(habit.timesToComplete)x " : "Once "
        
        let repeatString:String
        switch habit.frequency{
        case .Daily:
            repeatString = "a day "
        case .Weekly:
            repeatString = "a week "
        case .Monthly:
            repeatString = "a month "
        }
        
        var sRepeatString = ""
        if habit.frequency != .Daily {
            
        }else if habit.daysToComplete.count == 7 {
            sRepeatString = "every day"
        }else{
            for var i = 0; i < habit.daysToComplete.count; i++ {
                if i == 0 {sRepeatString += "every \(habit.daysToComplete[i])"}
                else if i == habit.daysToComplete.count - 1 {sRepeatString += " and \(habit.daysToComplete[i])"}
                else{
                    sRepeatString += ", \(habit.daysToComplete[i])"
                }
            }
        }
        
        return timesString+repeatString+sRepeatString
    }
}
