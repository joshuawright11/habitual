//
//  Message.swift
//  Ignite
//
//  Created by Josh Wright on 11/18/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import Parse

/// An object to represent any messages sent via the in app chat. Each `Message`
/// is associated with a connection.
class Message: ParseObject {

    /// The text of the message.
    var text: String
    
    /// The timestamp of when the message was sent.
    var timeStamp: NSDate {
        get{
            return parseObject!.createdAt!
        }
    }
    
    /// A computed property for whether the message was sent by the current
    /// user. If false, the `Message` was sent by the other user of the
    /// message's `connection`.
    var sentByCurrentUser: Bool {
        get{
            return sender.username == AuthManager.currentUser!.username
        }
    }
    
    /// The `User` who sent the message (with the receiver being the other 
    /// `User` in the `connection`).
    var sender: User
    
    /// The optional habit with which this `Message` is associated with. This is
    /// only used when the message text is related to a user's completion or 
    /// lack thereof of a `Habit`. A `Message` with a non-nil `habit` value can
    /// be referred to as an "accountability message" and should not ever be
    /// created in the app.
    var habit: PFObject?
    
    /// Initialize with a Parse `PFObject` object.
    ///
    /// - parameter parseObject: The `PFObject` object with which to initialize.
    override init(parseObject: PFObject) {
        text = parseObject["text"] as! String
        sender = User(parseUser: (parseObject["sender"] as! PFUser), withHabits: false)
        if let po = parseObject["habit"] { // No habit data is stored, just a
            habit = po as? PFObject        // placeholder `PFObject` to show
        }else{                             // there is one.
            habit = nil
        }
        
        super.init(parseObject: parseObject)
    }
    
    /// The basic initializer for when a message is sent and needs to be
    /// created. This creates the message but does not send it. For the 
    /// `Message` to be sent to the server, the `send()` method must be called.
    /// 
    /// - parameter text: The text of the `Message`.
    /// - parameter connection: The `Connection` with which the `Message` will
    ///   be associated.
    init(text: String, connection: Connection) {
        self.text = text
        self.sender = AuthManager.currentUser!
        self.habit = nil
        
        let parseObject = PFObject(className: "Message")
        parseObject["connection"] = connection.parseObject
        parseObject["text"] = self.text
        parseObject["sender"] = self.sender.parseObject
        
        super.init(parseObject: parseObject)
    }
    
    /// A method to save the `Message` to the server asynchronously.
    func send() {
        self.parseObject?.saveInBackground()
    }
}
