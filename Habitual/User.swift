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
    var name:String
    
    override init(){
        username = "0xdeadbeef"
        habits = []
        connections = []
        name = ""
        
        super.init()
    }
    
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
    
//    func statLongestStreak() -> Int {
//        var longestStreak = 0
//        for habit:Habit in habits {
//            if habit.longestStreak() > longestStreak {
//                longestStreak = habit.longestStreak()
//            }
//        }
//        return longestStreak
//    }
    
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
