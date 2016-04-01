//
//  TimesCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

/// A cell representing the number of times the `Habit` should be completed per
/// `Frequency`.
class TimesCell: HabitDetailCell {

    @IBOutlet weak var timesLabel: UILabel! {
        didSet {
            timesLabel.font = Fonts.sectionHeaderBold
            timesLabel.textColor = Colors.accent
        }
    }
    
    @IBOutlet weak var stepper: UIStepper! {
        didSet {
            stepper.tintColor = Colors.accent
            stepper.addTarget(self, action: #selector(TimesCell.stepperChanged(_:)), forControlEvents: .ValueChanged)
        }
    }
    
    // ********************************
    // MARK: - HabitDetailCell Override
    // ********************************
    
    override func configure() {
        stepper.value = Double(habit.timesToComplete)
        timesLabel.text = "\(Int(stepper.value))"
    }
    
    // ***************
    // MARK: - Targets
    // ***************
    
    /// Called when the value of `stepper` is changed. Changes the `habit`
    /// timesToComplete property and updates the `timesLabel`.
    func stepperChanged(stepper: UIStepper) {
        habit?.timesToComplete = Int(stepper.value)
        timesLabel.text = "\(habit!.timesToComplete)"
    }
}
