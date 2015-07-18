//
//  User.swift
//  Habitual
//
//  Created by Josh Wright on 6/12/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import SwiftyJSON

class User: PObject {
    
    let username:String
    
    var habits:[Habit]
    
    required init(json: JSON) {
        username = json["username"].stringValue
        habits = []
        super.init(json: json)
    }
    
    func toJSON() -> JSON{
        
        var json: JSON = [
            "username":username
        ]
        
        return json;
    }
}
