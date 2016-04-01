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
class Connection: ParseObject {
    
    /// The user who originally sent the connection request.
    let sender:User
    
    /// The user who originally received the connection request.
    let receiver:User
    
    /// Whether this `Connection` has been approved by the `receiver`.
    var approved:Bool
    
    /// The color associated with this `Connection`. Used purely for design 
    /// purposes and is unique to each user's app.
    var color: UIColor?
    
    /// A computed variable to see if the currently logged in `User` was the 
    /// original sender of this message.
    var sentByCurrentUser: Bool {
        get{return AuthManager.currentUser?.username == sender.username}
    }
    
    /// All the messages associated with this `Connection`.
    var messages:[Message]?
    
    /// Computed property to return the "other" `User` of this `Connection`.
    /// That is, not the currently logged in `User`.
    var user:User {
        get{
            if(AuthManager.currentUser?.username == sender.username) {
                return receiver
            }else{
                return sender
            }
        }
    }
    
    /// Computed property to return the number of habits of the other user that 
    /// are accountable to the current user.
    var numAccountable: Int {
        get {
            return user.habits.filter({$0.usersToNotify.contains({$0.username == AuthManager.currentUser?.username})}).count
        }
    }
    
    /// Basic initializer to create a new `Connection` with a `User` to connect
    /// to. Creates a connection with the currently logged in `User` as the
    /// sender, and the parameter as the receiver.
    ///
    /// - parameter receiver: The `User` create a connection with. Should not be
    ///   the current user
    init(receiver: User) {

        self.sender = AuthManager.currentUser!
        self.receiver = receiver
        self.approved = false
        
        let parseObject = PFObject(className: "Connection")
        parseObject["sender"] = AuthManager.currentUser?.parseObject
        parseObject["receiver"] = receiver.parseObject
        parseObject["approved"] = false
        parseObject["privateApproved"] = false

        super.init(parseObject: parseObject)
    }
    
    /// Initialize with a Parse `PFObject` object.
    ///
    /// - parameter parseObject: The `PFObject` object with which to initialize.
    override init(parseObject: PFObject) {
        sender = User(parseUser: parseObject["sender"] as! PFUser, withHabits: true)
        receiver = User(parseUser: parseObject["receiver"] as! PFUser, withHabits: true)

        approved = parseObject["privateApproved"] as! Bool

        super.init(parseObject: parseObject)
        
        loadMessages(nil)
    }
}
