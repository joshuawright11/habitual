//
//  HabitGlanceCell.swift
//  Ignite
//
//  Created by Josh Wright on 12/26/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class HabitGlanceCell: UITableViewCell {
    
    static let reuseIdentifier = "HabitGlance"
    static let height = CGFloat(22)
    
    @IBOutlet weak var circleView: UIView! {
        didSet {
            circleView.layer.cornerRadius = 5.5
        }
    }
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = Fonts.body
            titleLabel.textColor = Colors.textSubtitle
        }
    }
    @IBOutlet weak var iv: UIImageView! {
        didSet {
            iv.image = UIImage(named: "chain")?.imageWithRenderingMode(.AlwaysTemplate)
        }
    }
    
    private var connectionColor: UIColor! {
        didSet {
            iv.tintColor = connectionColor
        }
    }
    
    private var habit: Habit! {
        didSet {
            titleLabel.text = habit.name + " " + habit.streakBadge
        }
    }
    
    func configureForHabit(habit: Habit, color: UIColor, accountable: Bool, completed: Bool) {
        
        self.habit = habit
        iv.hidden = !accountable
        
        if completed {
            circleView.backgroundColor = UIColor(hexString: habit.color)
            circleView.layer.borderWidth = 0
        } else {
            circleView.backgroundColor = Colors.background
            circleView.layer.borderColor = UIColor(hexString: habit.color).CGColor
            circleView.layer.borderWidth = 2
        }
    }
}
