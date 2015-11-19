//
//  User.swift
//  Habitual
//
//  Created by Josh Wright on 6/12/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import SwiftyJSON
import Parse

class User: ParseObject {
    
    let username:String
    
    var habits:[Habit]
    
    var connections:[Connection]
    
    init(){
        username = "0xdeadbeef"
        habits = []
        connections = []
        super.init(parseObject: nil)
    }
    
    init(parseUser: PFUser) {
        username = parseUser.username!
        
        habits = []
        
        for json:AnyObject in parseUser["habits"] as! Array<AnyObject> {
            let json = JSON(json)
            habits.append(Habit(json: json))
        }
        
        connections = []
        
        super.init(parseObject: parseUser)
    }
    
    func toJSON() -> JSON{
        
        let json: JSON = [
            "username":username,
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
        for habit:Habit in habits {
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
