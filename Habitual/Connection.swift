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

class Connection: ParseObject {
    let sender:User
    let receiver:User
    var approved:Bool
    
    var sentByCurrentUser: Bool {
        get{return AuthManager.currentUser?.username == sender.username}
    }
    
    var messages:[Message]?
    
    var user:User {
        get{
            if(AuthManager.currentUser?.username == sender.username) {
                return receiver
            }else{
                return sender
            }
        }
    }
    
    init(user: User) {

        self.sender = AuthManager.currentUser!
        self.receiver = user
        self.approved = false
        
        let parseObject = PFObject(className: "Connection")
        parseObject["sender"] = AuthManager.currentUser?.parseObject
        parseObject["receiver"] = user.parseObject
        parseObject["approved"] = false

        super.init(parseObject: parseObject)
    }
    
    override init(parseObject: PFObject?) {
        sender = User(parseUser: parseObject!["sender"] as! PFUser)
        receiver = User(parseUser: parseObject!["receiver"] as! PFUser)
        approved = parseObject!["approved"] as! Bool

        super.init(parseObject: parseObject)
        
        loadMessages(nil)
    }
    
    func sendMessage(text: String) -> Message {
        let message = Message(text: text, connection: self)
        message.send()
        messages?.append(message)
        return message
    }
    
    func loadMessages(callback:((success: Bool) -> ())?) {
        let query = PFQuery(className: "Message")
        query.whereKey("connection", equalTo: self.parseObject!)
        query.orderByAscending("timeStamp")
        query.includeKey("sender")
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
    
    func saveToServer() {
        parseObject!.saveEventually()
    }
    
    func approve() {
        parseObject!["approved"] = true
        approved = true
        parseObject!.saveEventually()
    }
    
    func delete() {
        parseObject!.deleteEventually()
    }
}
