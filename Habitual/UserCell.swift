//
//  UserCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/9/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    func configure(user: User) {
        initialsLabel.text = String(user.username.characters.first!).capitalizedString
        titleLabel.text = user.username
        subtitleLabel.text = "\(user.statHabitsCompleted()) habits completed"
        infoLabel.text = "\(user.habits.count) habits"
        
        doAppearance()
    }
    
    func doAppearance() {
        backgroundColor = kColorBackground
        selectionStyle = UITableViewCellSelectionStyle.None
        
        titleLabel.textColor = kColorTextMain
        titleLabel.font = kFontCellTitle
        
        subtitleLabel.textColor = kColorTextMain
        subtitleLabel.font = kFontCellSubtitle
        
        infoLabel.textColor = kColorTextSecondary
        infoLabel.font = kFontSectionHeader
        
        initialsLabel.font = kFontInitials
        initialsLabel.textColor = kColorRed
        
        initialsLabel.layer.cornerRadius = 25.0
        initialsLabel.layer.borderWidth = 2.0
        initialsLabel.layer.borderColor = kColorRed.CGColor
        
        borderView.backgroundColor = kColorBackground
        borderView.layer.cornerRadius = 30.0
        borderView.layer.borderWidth = 2.0
        borderView.layer.borderColor = kColorRed.CGColor
    }
    
}
