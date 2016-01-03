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
    
    var connectionColor: UIColor! {
        didSet {
            iv.tintColor = connectionColor
        }
    }
    
    var habit: Habit! {
        didSet {
            titleLabel.text = habit.name + " " + habit.streakBadge
            
            if finished! {
                circleView.backgroundColor = UIColor(hexString: habit.color)
                circleView.layer.borderWidth = 0
            } else {
                circleView.backgroundColor = Colors.barBackground
                circleView.layer.borderColor = UIColor(hexString: habit.color).CGColor
                circleView.layer.borderWidth = 2
            }
            
            if habit.usersToNotify.filter({$0.username == AuthManager.currentUser?.username}).count > 0 {
                iv.hidden = false
                iv.tintColor = connectionColor
            }else{
                iv.hidden = true
            }
        }
    }
    
    var finished: Bool!
}
