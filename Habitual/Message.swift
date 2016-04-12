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
class Message: NSObject {

    /// The text of the message.
    var text: String
    
    /// The timestamp of when the message was sent.
    var timeStamp: NSDate
    
    /// The `User` who sent the message (with the receiver being the other 
    /// `User` in the `connection`).
    var sender: User
    
    /// The optional habit with which this `Message` is associated with. This is
    /// only used when the message text is related to a user's completion or 
    /// lack thereof of a `Habit`. A `Message` with a non-nil `habit` value can
    /// be referred to as an "accountability message" and should not ever be
    /// created in the app.
    var habit: Habit?
    
    init(sender: User) {
        text = ""
        timeStamp = NSDate()
        self.sender = sender
        habit = nil
    }
}
