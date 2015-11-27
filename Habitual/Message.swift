//
//  Message.swift
//  Ignite
//
//  Created by Josh Wright on 11/18/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import Parse

class Message: ParseObject {
    var text: String
    var timeStamp: NSDate {
        get{
            return parseObject!.createdAt!
        }
    }
    var sender: User
    var habit: PFObject?
    
    override init(parseObject: PFObject) {
        text = parseObject["text"] as! String
        sender = User(parseUser: parseObject["sender"] as! PFUser)
        if let po = parseObject["habit"] {
            habit = po as? PFObject
        }else{
            habit = nil
        }
        
        super.init(parseObject: parseObject)
    }
    
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
    
    func send() {
        self.parseObject?.saveEventually()
    }
    
    func sentByCurrentUser() -> Bool {
        return sender.username == AuthManager.currentUser!.username
    }
}
