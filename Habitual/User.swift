//
//  User.swift
//  Habitual
//
//  Created by Josh Wright on 6/12/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import SwiftyJSON
import Parse

/// A user of Ignite. Accessible to all classes.
class User: ParseObject {
    
    /// The user's username
    let username:String
    
    /// The user's habits.
    var habits:[Habit]
    
    /// The connections in which a user is a member of. This value must always
    /// be loaded asynchronously with `getConnections()`.
    var connections:[Connection]
    
    /// The user's full name, separated with spaces.
    var name:String
    
    /// Basic initializer. Generates a user with empty/bogus data fields.
    override init(){
        username = "0xdeadbeef"
        habits = []
        connections = []
        name = ""
        
        super.init()
    }
    
    /// Initialize with a Parse `PFUser` object.
    /// 
    /// - parameter parseUser: The `PFUser` object with which to initialize.
    /// - parameter withHabits: Whether the habits of the parseUser are
    ///   available and should be loaded.
    init(parseUser: PFUser, withHabits: Bool) {
        username = parseUser.username!
        habits = []
        
        if PFUser.currentUser()!.objectId != parseUser.objectId && withHabits {
            for parseObject in parseUser["habits"] as! [PFObject] {
                habits.append(Habit(parseObject: parseObject))
            }
        }
        connections = []
        name = parseUser["name"] as! String
        super.init(parseObject: parseUser)
    }
    
    /// A method to find the number of times this user has completed any habit.
    ///
    /// - returns: The number of times this user has completed any habit.
    func statHabitsCompleted() -> Int{
        var count = 0;
        for habit:Habit in habits {
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
        if habits.count == 0 {
            return "no habits!"
        }else{
            var mostCompletedHabit = habits[0]
            for habit:Habit in habits {
                if habit.datesCompleted.count > mostCompletedHabit.datesCompleted.count {
                    mostCompletedHabit = habit
                }
            }
            return mostCompletedHabit.name
        }
    }
    
    func statHabitCompletionPercentageForDate(date: NSDate) -> Double {
        
        var available = 0.0, completed = 0.0
        for habit in habits {
            if habit.availableOn(date) {
                available += 1
                if !habit.canDoOn(date) {
                    completed += 1
                } else {
                    print("")
                }
            }
        }
        
        return completed/available * 100.0
    }
}
