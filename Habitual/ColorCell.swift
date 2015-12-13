//
//  ColorCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

/// A cell representing the color of the `Habit`.
class ColorCell: HabitDetailCell {

    /// Buttons representing the possible colors a `Habit` could be.
    @IBOutlet var colorButtons: [UIButton]! {
        didSet {
            var i = 0
            for bt in colorButtons {
                bt.layer.cornerRadius = 8.0
                bt.backgroundColor = Colors.rainbow[i++]
                bt.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: .TouchUpInside)
            }
        }
    }

    /// The button reflecting the currently selected color.
    var selectedButton: UIButton? {
        willSet {
            if let selectedButton = selectedButton {
                selectedButton.layer.borderWidth = 0
            }
        }
        
        didSet {
            if let selectedButton = selectedButton {
                selectedButton.layer.borderWidth = 3.0
                selectedButton.layer.borderColor = Colors.accentSecondary.CGColor
            }
        }
    }
    
    // ********************************
    // MARK: - HabitDetailCell Override
    // ********************************
    
    override func configure() {
        for bt in colorButtons {
            if bt.backgroundColor!.hexString == habit.color {
                selectedButton = bt
                bt.layer.borderWidth = 3.0
                bt.layer.borderColor = Colors.accentSecondary.CGColor
            }
        }
    }
    
    // ***************
    // MARK: - Targets
    // ***************
    
    /// Changes the color of a habit when a button is pressed.
    func buttonPressed(button: UIButton) {
        selectedButton = button
        habit?.color = (selectedButton?.backgroundColor!.hexString)!
    }
}
