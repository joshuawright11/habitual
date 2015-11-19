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
    let approved:Bool
    
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
    }
    
    func saveToServer() {
        parseObject!.saveEventually()
    }
    
    func approve() {
        parseObject!["approved"] = true
        parseObject!.saveEventually()
    }
    
    func delete() {
        parseObject!.deleteEventually()
    }
}
