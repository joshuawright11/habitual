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
    
    /// The user's username
    var email:String
    
    /// The user's habits.
    var habits:[Habit]
    
    /// The connections in which a user is a member of. This value must always
    /// be loaded asynchronously with `getConnections()`.
    var connections:[Connection]
    
    /// The user's full name, separated with spaces.
    var name:String
    
    var profileImageURL: String?
    
    var joined: NSDate
    
    override init() {
        self.email =  ""
        self.habits = []
        self.connections = []
        self.name = ""
        self.joined = NSDate()
    }
}
