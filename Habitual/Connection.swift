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
    
    /// The method which which all messages should be sent. A message is
    /// created with current connection (with the current `User` as a sender), 
    /// sent to the server, appended to `messages` and then returned.
    ///
    /// - parameter text: The text of the message to send.
    ///
    /// - returns: The newly created `Message` that has been asynchronously sent
    ///   to the server.
    func sendMessage(text: String) -> Message {
        let message = Message(text: text, connection: self)
        message.send()
        messages?.append(message)
        return message
    }
    
    /// Load every `Message` associated with this connection from the server and
    /// replace the content of `messages` with the results.
    ///
    /// - parameter callback: A closure which is called with `success`, a `Bool`
    ///   describing whether the API call was successful and the messages were
    ///   loaded.
    func loadMessages(callback:((success: Bool) -> ())?) {
        let query = PFQuery(className: "Message")
        query.whereKey("connection", equalTo: self.parseObject!)
        query.orderByAscending("timeStamp")
        query.includeKey("sender")
        query.includeKey("habit")
        query.findObjectsInBackgroundWithBlock { (parseObjects, error) -> Void in
            if let parseObjects = parseObjects {
                var messages: [Message] = []
                for parseObject in parseObjects {
                    let message = Message(parseObject: parseObject)
                    messages.append(message)
                }
                
                self.messages = messages
                
                if let callback = callback {
                    callback(success: true)
                }
            }
        }
    }

    /// Save the underlying 'PFObject' to the server.
    func saveToServer() {
        parseObject!.saveInBackground()
    }
    
    /// Approve the `Connection`. The approved `Connection` is then saved to the
    /// server.
    func approve() {
        parseObject!["privateApproved"] = true
        approved = true
        parseObject!.saveInBackground()
    }
    
    /// Delete the 'Connection' from the server.
    func deleteFromServer() {
        parseObject!.deleteInBackground()
    }
}
