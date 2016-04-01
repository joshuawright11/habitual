//
//  ConnectionCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

/// A cell representing a connection that a `Habit` could be accountable to.
///
/// - note: This class is NOT a subclass of `HabitDetailCell`.
class ConnectionCell: UITableViewCell {

    /// A `UILabel` representing the name of the `Connection`.
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            selectionStyle = UITableViewCellSelectionStyle.None
            nameLabel.font = Fonts.sectionHeader
            nameLabel.textColor = Colors.textMain
        }
    }

    /// A `UILabel` representing the initials of the `Connection`.
    @IBOutlet weak var initialsLabel: UILabel! {
        didSet {
            initialsLabel.font = Fonts.initials

            
            initialsLabel.layer.cornerRadius = 22.0
            initialsLabel.layer.borderWidth = 2.0
            initialsLabel.layer.backgroundColor = Colors.background.CGColor
            
            Styler.viewShaderSmall(initialsLabel)
        }
    }
    
    /// A `UIImageView` representing whether the habit is accountable to this 
    /// connection.
    @IBOutlet weak var checkiv: UIImageView! {
        didSet {
            checkiv.image = checkiv.image?.imageWithRenderingMode(.AlwaysTemplate)
        }
    }
    
    /// The `Habit` to which this cell is associated.
    var habit:Habit!
    
    /// The `Connection` this cell represents.
    var user:User!
    
    /// The color related to the user
    var color: UIColor!
    
    // *********************************
    // MARK: - UITableViewCell Overrides
    // *********************************
    
    override func setSelected(selected: Bool, animated: Bool) {
        if selected {
            if habit!.usersToNotify.contains(user) {
                habit!.usersToNotify.removeAtIndex(habit!.usersToNotify.indexOf(user)!)
                checkiv.tintColor = Colors.background
            }else{
                habit!.usersToNotify.append(user)
                checkiv.tintColor = color
            }
        }
    }

    // ***************
    // MARK: - Methods
    // ***************
    
    /// Configure the cell with a `Habit` and a `Connection`.
    func configure(habit: Habit, user: User, color: UIColor) {
        self.habit = habit
        self.user = user

        initialsLabel.textColor = color
        initialsLabel.layer.borderColor = color.CGColor
        
        nameLabel.text = user.name
        let names:[String] = user.name.componentsSeparatedByString(" ")
        initialsLabel.text = String(names[0].characters.first!) + String(names[1].characters.first!)
        
        if let cdo = habit.coreDataObject {
            let contains:Bool = cdo.usernamesToNotify.contains(user.name)
            checkiv.tintColor = contains ? color : Colors.background
            let habitContains:Bool = habit.usersToNotify.map({$0.name}).contains(user.name)
            if(contains && !(habitContains)){
                habit.usersToNotify.append(user)
            }
        }else{
            checkiv.tintColor = habit.usersToNotify.map({$0.name}).contains(user.name) ? color : Colors.background
        }
    }
}
