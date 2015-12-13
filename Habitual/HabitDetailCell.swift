//
//  HabitDetailCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Foundation

/// A base class for any cell in the `HabitDetailController`. Each cell must
/// have a `Habit` that it can access when setting data, as well as a title
/// label to describe what property of the `Habit` it will modify.
///
/// - warning: Any subclass of this MUST override the `configure()` method.
class HabitDetailCell:UITableViewCell {
    
    /// The `UILabel` describing what properties the cell will modify.
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = Fonts.sectionHeader
            titleLabel.textColor = Colors.textMain
            selectionStyle = .None
        }
    }
    
    /// The `Habit` object a cell will modify.
    var habit: Habit! {
        
        /// When a new `habit` is set, configure the cell for that habit.
        didSet {
            configure()
        }
    }
    
    // *******************************
    // MARK: - Pseudo-Abstract Methods
    // *******************************
    
    /// Configure the cell when a new `habit` is set. This method will be called
    /// whenever `habit` is set. This method must always be overrided by any
    /// subclass.
    func configure(){ fatalError("You must override this method!") }
}
