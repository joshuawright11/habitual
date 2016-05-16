//
//  ServiceManager+HabitService.swift
//  Ignite
//
//  Created by Josh Wright on 4/28/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import Foundation

extension ServiceManager : HabitService {
    
    var habits:[Habit] {
        return habitRepository.habits
    }
    
    func createHabit(habit: Habit) {
        habitRepository.createHabit(habit, serviceManager: self)
        notifyHabitServiceObservers()
    }
    
    func deleteHabit(habit: Habit) {
        habitRepository.deleteHabit(habit)
        notifyHabitServiceObservers()
    }
    
    func updateHabit(habit: Habit) {
        habitRepository.updateHabit(habit, serviceManager: self)
        notifyHabitServiceObservers()
    }
    
    func orderHabits(habits: [Habit]) {
        habitRepository.orderHabits(habits)
    }
    
    func isTracking(habit: Habit) -> Bool {
        return habitRepository.isTracking(habit)
    }
    
    // return whether the habit can be completed again
    func completeHabit(habit: Habit, on date: NSDate) -> Bool {
        if habit.canDoOn(date) {
            habit.datesCompleted.append(date);
            habitRepository.updateHabit(habit, serviceManager: self)
            return habit.canDoOn(date)
        } else {
            return false;
        }
    }
    
    // return whether the habit can be incompleted again
    func incompleteHabit(habit: Habit, on date: NSDate) -> Bool {
        if habit.numCompletedIn(date) > 0 {
            for completion in habit.datesCompleted {
                if (date.beginningOfDay...date.endOfDay).contains(completion) {
                    habit.datesCompleted.removeObject(completion)
                    habitRepository.updateHabit(habit, serviceManager: self)
                    break
                }
            }
            return habit.numCompletedIn(date) > 0
        } else {
            return false
        }
    }
    
    func addHabitServiceObserver(observer: ServiceObserver) {
        habitServiceObservers.append(observer)
    }
    
    func removeHabitServiceObserver(observer: ServiceObserver) {
        for i in 0..<habitServiceObservers.count {
            if habitServiceObservers[i] === observer {
                habitServiceObservers.removeAtIndex(i)
            }
        }
    }
}
