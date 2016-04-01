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
class User: NSObject {
    
    /// The parse object
    var parseObject: PFObject
    
    /// The user's username
    let email:String
    
    /// The user's habits.
    var habits:[Habit]
    
    /// The connections in which a user is a member of. This value must always
    /// be loaded asynchronously with `getConnections()`.
    var connections:[Connection]
    
    /// The user's full name, separated with spaces.
    var name:String
    
    /// Initialize with a Parse `PFUser` object.
    /// 
    /// - parameter parseUser: The `PFUser` object with which to initialize.
    /// - parameter withHabits: Whether the habits of the parseUser are
    ///   available and should be loaded.
    init?(parseUser: PFUser?) {
        
        guard let parseUser = parseUser else {
            return nil
        }
        
        self.parseObject = parseUser
        
        email = parseUser.username!
        habits = []
        connections = []
        name = parseUser["name"] as! String
        super.init()
        
        for parseObject in parseUser["habits"] as! [PFObject] {
            let habit = Habit(parseObject: parseObject)
            if let habit = habit {
                if !habit.privat {
                    habits.append(habit)
                } else if !(habit.usersToNotify.filter({$0.email == email}).isEmpty) {
                    habits.append(habit)
                }
            }
        }
    }
}
