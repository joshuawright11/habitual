//
//  ColorCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class ColorCell: UITableViewCell, HabitDetailCell {

    @IBOutlet var colorButtons: [UIButton]!
    @IBOutlet weak var titleLabel: UILabel!

    var selectedButton: UIButton?
    
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
        
        var i = 0
        for bt in colorButtons {
            bt.layer.cornerRadius = 8.0
            bt.backgroundColor = kColorArray[i++]
            bt.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: .TouchUpInside)
        }
    }
    
    func buttonPressed(button: UIButton) {
        if let selectedButton = selectedButton {
            selectedButton.layer.borderWidth = 0
        }
        
        button.layer.borderWidth = 3.0
        button.layer.borderColor = kColorAccentSecondary.CGColor
        selectedButton = button
        
        habit?.color = (selectedButton?.backgroundColor!.hexString)!
    }
    
    func configure(habit: Habit) {
        self.habit = habit
        doAppearance()
    }
    
}
