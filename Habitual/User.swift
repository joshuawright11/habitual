//
//  User.swift
//  Habitual
//
//  Created by Josh Wright on 6/12/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import SwiftyJSON
import Parse

class User: PObject {
    
    let username:String
    
    var habits:[Habit]
    
    var following:[String]
    
    required init(json: JSON) {
        username = json["username"].stringValue
        habits = []
        following = []
        super.init(json: json)
    }
    
    init(parse: PFUser) {
        username = parse.username!
        
        habits = []
        
        for json:AnyObject in parse["habits"] as! Array<AnyObject> {
            let json = JSON(json)
            habits.append(Habit(json: json))
        }
        
        following = []
        
        super.init(json: nil)
    }
    
    func toJSON() -> JSON{
        
        var json: JSON = [
            "username":username,
            "following":following
        ]
        
        return json;
    }
    
    func statHabitsCompleted() -> Int{
        var count = 0;

        for habit:Habit in habits {
            count += habit.datesCompleted.count
        }
        
        return count
    }
    
    func statLongestStreak() -> Int {
        var longestStreak = 0
        for habit:Habit in habits{
            if habit.longestStreak() > longestStreak {
                longestStreak = habit.longestStreak()
            }
        }
        return longestStreak
    }
    
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
}
