//
//  Connection.swift
//  Ignite
//
//  Created by Josh Wright on 11/18/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import SwiftyJSON
import Parse

/// A class to represent the various connections between users in Ignite. Each
/// `Connection` has two users, described as `sender` and `receiver`.
class Connection: NSObject {
    
    /// The user who originally sent the connection request.
    let sender:User
    
    /// The user who originally received the connection request.
    let receiver:User
    
    /// Whether this `Connection` has been approved by the `receiver`.
    var approved:Bool
    
    /// The color associated with this `Connection`. Used purely for design 
    /// purposes and is unique to each user's app.
    var color: UIColor
    
    /// All the messages associated with this `Connection`.
    var messages:[Message]

    init(sender: User, receiver: User, color: UIColor) {
        self.color = color
        self.sender = sender
        self.receiver = receiver
        approved = false
        messages = []
    }
}