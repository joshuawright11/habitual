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
    
    var parseObject: PFObject
    
    /// The timestamp of when the message was sent.
    var timeStamp: NSDate {
        get{
            return parseObject.createdAt!
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
    init?(parseObject: PFObject) {
        guard let sender = User(parseUser: parseObject["sender"] as? PFUser) else {
            return nil
        }
        
        self.parseObject = parseObject
        self.sender = sender
        
        text = parseObject["text"] as! String
        
        if let po = parseObject["habit"] { // No habit data is stored, just a
            habit = po as? PFObject        // placeholder `PFObject` to show
        }else{                             // there is one.
            habit = nil
        }
        
        super.init()
    }
}
