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
    
    var parseObject: PFObject
    
    /// The user who originally sent the connection request.
    let sender:User
    
    /// The user who originally received the connection request.
    let receiver:User
    
    /// Whether this `Connection` has been approved by the `receiver`.
    var approved:Bool
    
    /// The color associated with this `Connection`. Used purely for design 
    /// purposes and is unique to each user's app.
    var color: UIColor!
    
    /// All the messages associated with this `Connection`.
    var messages:[Message]?
    
    /// Initialize with a Parse `PFObject` object.
    ///
    /// - parameter parseObject: The `PFObject` object with which to initialize.
    init?(parseObject: PFObject) {
        
        guard let sender = User(parseUser: parseObject["sender"] as? PFUser), receiver = User(parseUser: parseObject["receiver"] as? PFUser) else {
            return nil
        }

        self.sender = sender
        self.receiver = receiver
        self.parseObject = parseObject
        
        approved = parseObject["privateApproved"] as! Bool
        
        super.init()
    }
}
