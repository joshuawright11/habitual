//
//  ConnectionCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class ConnectionCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var checkiv: UIImageView!

    var habit:Habit?
    var username:String?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        if selected {
            if habit!.usernamesToNotify.contains(username!) {
                habit!.usernamesToNotify.removeAtIndex(habit!.usernamesToNotify.indexOf(username!)!)
                checkiv.tintColor = kColorBackground
            }else{
                habit!.usernamesToNotify.append(username!)
                checkiv.tintColor = kColorAccent
            }
        }
    }
    
    func doAppearance() {
        selectionStyle = UITableViewCellSelectionStyle.None
        nameLabel.font = kFontSectionHeader
        nameLabel.textColor = kColorTextMain
        nameLabel.text = username!
        initialsLabel.text = String(username!.capitalizedString.characters.first!)
        
        initialsLabel.font = kFontInitials
        initialsLabel.textColor = kColorRed
        
        initialsLabel.layer.cornerRadius = 22.0
        initialsLabel.layer.borderWidth = 2.0
        initialsLabel.layer.borderColor = kColorRed.CGColor
        
        checkiv.image = checkiv.image?.imageWithRenderingMode(.AlwaysTemplate)
        checkiv.tintColor = habit!.usernamesToNotify.contains(username!) ? kColorAccent : kColorBackground
    }
    
    func configure(habit: Habit, index: Int) {
        self.habit = habit
        self.username = AuthManager.currentUser?.connections[index].user.username
        doAppearance()
    }
}
