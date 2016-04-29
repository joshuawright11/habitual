//
//  Array+HabitStats.swift
//  Ignite
//
//  Created by Josh Wright on 4/1/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import Foundation

extension Array where Element : Habit {
    
    /// A method to find the number of times this user has completed any habit.
    ///
    /// - returns: The number of times this user has completed any habit.
    func statHabitsCompleted() -> Int{
        var count = 0;
        for habit:Habit in self {
            count += habit.datesCompleted.count
        }
        
        return count
    }
    
    //    func statLongestStreak() -> Int {
    //        var longestStreak = 0
    //        for habit:Habit in habits {
    //            if habit.longestStreak() > longestStreak {
    //                longestStreak = habit.longestStreak()
    //            }
    //        }
    //        return longestStreak
    //    }
    
    /// A method to find the name of the habit that the user has completed the
    /// most.
    ///
    /// - returns: The name of the habit that has been completed the most times.
    func statMostCompletedHabit() -> String{
        if count == 0 {
            return "no habits!"
        }else{
            var mostCompletedHabit: Habit = self[0]
            for habit:Habit in self {
                if habit.datesCompleted.count > mostCompletedHabit.datesCompleted.count {
                    mostCompletedHabit = habit
                }
            }
            return mostCompletedHabit.name
        }
    }
    
    func statHabitCompletionPercentageForDate(date: NSDate) -> Double {
        
        var available = 0.0, completed = 0.0
        for habit in self {
            if habit.availableOn(date) {
                available += 1
                if !habit.canDoOn(date) {
                    completed += 1
                }
            }
        }
        
        return completed/available * 100.0
    }
}
