//
//  HabitService.swift
//  Ignite
//
//  Created by Josh Wright on 4/28/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import Foundation


protocol HabitService {
    var habits:[Habit] {get}
    
    func createHabit(habit: Habit)
    func deleteHabit(habit: Habit)
    func updateHabit(habit: Habit)
    
    func completeHabit(habit: Habit, on date: NSDate) -> Bool
    func incompleteHabit(habit: Habit, on date: NSDate) -> Bool
    
    func orderHabits(habits: [Habit])
    
    func isTracking(habit: Habit) -> Bool
    
    func addHabitServiceObserver(observer: ServiceObserver)
    func removeHabitServiceObserver(observer: ServiceObserver)
}
