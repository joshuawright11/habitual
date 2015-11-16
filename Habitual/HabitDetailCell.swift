//
//  HabitDetailCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Foundation

protocol HabitDetailCell {
    var habit: Habit? {get set}
    
    func configure(habit:Habit)
    
}
