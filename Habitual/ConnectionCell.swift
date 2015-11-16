//
//  ConnectionCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class ConnectionCell: UITableViewCell, HabitDetailCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var piciv: UIImageView!
    @IBOutlet weak var checkiv: UIImageView!

    var habit:Habit?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func doAppearance() {
        selectionStyle = UITableViewCellSelectionStyle.None
        nameLabel.font = kFontSectionHeader
        nameLabel.textColor = kColorTextMain
    }
    
    func configure(habit: Habit) {
        self.habit = habit
        doAppearance()
    }
}
