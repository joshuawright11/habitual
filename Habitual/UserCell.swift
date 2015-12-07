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
    @IBOutlet weak var acceptButton: UIButton!
    
    var connection:Connection!
    var color: UIColor!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Styler.viewShader(borderView)
    }
    
    func configure(connection: Connection) {
        self.connection = connection
        let user = connection.user
        
        let names = user.name.componentsSeparatedByString(" ")
        
        initialsLabel.text = (String(names[0].characters.first!) + String(names[1].characters.first!)).uppercaseString
        titleLabel.text = user.name
        doAppearance()
    }
    
    func doAppearance() {
        
        infoLabel.text = "\(connection.user.habits.count) habits"
        if connection.approved {
            subtitleLabel.text = connection.messages?.last?.text ?? "\(connection.user.statHabitsCompleted())"
        }else{
            subtitleLabel.text = connection.sentByCurrentUser ? "Pending acceptance" : "Wants to connect"
        }
        
        color = connection.approved ? connection.color : kColorTextSecondary
        let textColor = connection.approved ? kColorTextMain : kColorTextSecondary
        
        if connection.approved || connection.sentByCurrentUser {
            acceptButton.hidden = true
            infoLabel.hidden = false
        }else{
            acceptButton.backgroundColor = kColorGreen.colorWithAlphaComponent(0.7)
            acceptButton.titleLabel?.font = kFontSectionHeader
            acceptButton.tintColor = kColorTextMain
            acceptButton.addTarget(self, action: Selector("approve"), forControlEvents: .TouchUpInside)
            acceptButton.layer.cornerRadius = 15.0
            infoLabel.hidden = true
        }
        
        backgroundColor = kColorBackground
        selectionStyle = UITableViewCellSelectionStyle.None
        
        titleLabel.textColor = textColor
        titleLabel.font = kFontCellTitle
        
        subtitleLabel.textColor = kColorTextSubtitle
        subtitleLabel.font = kFontCellSubtitle
        
        infoLabel.textColor = kColorTextSubtitle
        infoLabel.font = kFontSectionHeader
        
        initialsLabel.font = kFontInitials
        initialsLabel.textColor = color
        
        initialsLabel.layer.backgroundColor = kColorBackground.CGColor
        
        initialsLabel.layer.cornerRadius = 25.0
        initialsLabel.layer.borderWidth = 2.0
        initialsLabel.layer.borderColor = color.CGColor
        
        borderView.backgroundColor = color.colorWithAlphaComponent(0.3)
        borderView.layer.cornerRadius = 15.0
//        borderView.layer.borderWidth = 2.0
//        borderView.layer.borderColor = color.CGColor
    }
    
    func approve() {
        connection.approve()
        doAppearance()
    }
    
}
