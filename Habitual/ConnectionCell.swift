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
    var user:User!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        if selected {
            if habit!.usersToNotify.contains(user) {
                habit!.usersToNotify.removeAtIndex(habit!.usersToNotify.indexOf(user)!)
                checkiv.tintColor = kColorBackground
            }else{
                habit!.usersToNotify.append(user)
                checkiv.tintColor = kColorAccent
            }
        }
    }
    
    func doAppearance() {
        selectionStyle = UITableViewCellSelectionStyle.None
        nameLabel.font = kFontSectionHeader
        nameLabel.textColor = kColorTextMain
        nameLabel.text = user?.name
        
        let names:[String] = user!.name.componentsSeparatedByString(" ")
        
        initialsLabel.text = String(names[0].characters.first) + String(names[1].characters.first)
        
        initialsLabel.font = kFontInitials
        initialsLabel.textColor = kColorRed
        
        initialsLabel.layer.cornerRadius = 22.0
        initialsLabel.layer.borderWidth = 2.0
        initialsLabel.layer.borderColor = kColorRed.CGColor
        
        checkiv.image = checkiv.image?.imageWithRenderingMode(.AlwaysTemplate)
        checkiv.tintColor = habit!.usersToNotify.contains(user) ? kColorAccent : kColorBackground
    }
    
    func configure(habit: Habit, index: Int) {
        self.habit = habit
        self.user = AuthManager.currentUser?.connections[index].user
        doAppearance()
    }
}
