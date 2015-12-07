//
//  User+Web.swift
//  Ignite
//
//  Created by Josh Wright on 11/18/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Parse

extension User
{
    func getConnections(callback:((success: Bool) -> ())?){
        
        let sender = PFQuery(className: "Connection")
        sender.whereKey("sender", equalTo: parseObject!)
        let receiver = PFQuery(className: "Connection")
        receiver.whereKey("receiver", equalTo: parseObject!)
        
        let or = PFQuery.orQueryWithSubqueries([sender, receiver])
        or.includeKey("sender")
        or.includeKey("receiver")
        or.includeKey("sender.habits")
        or.includeKey("receiver.habits")
        or.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let objects = objects {
                self.connections = []
                var count = 0
                var total = objects.count
                for o in objects {
                    let connection = Connection(parseObject: o)
                    connection.loadMessages({ (success) -> () in
                        total -= 1
                        if total == 0 {Utilities.postNotification(kNotificationIdentifierReloadConnectionsOffline)}
                    })
                    connection.color = kColorArray[count++ % 6]
                    self.connections.append(connection)
                }
                if let callback = callback {
                    callback(success: true)
                }
            }
        }
    }
    
    func addConnection(username: String, callback:((success: Bool) -> ())?) {
        
        let test = self.connections.filter({$0.user.username == username})
        if test.count != 0 {
            if let callback = callback { callback(success: false) }
        }else{
            let query = PFUser.query()
            query!.whereKey("username", equalTo: username)
            
            query!.getFirstObjectInBackgroundWithBlock({ (user, error) -> Void in
                
                if let user = user{
                    let connection = Connection(user: User(parseUser: user as! PFUser, withHabits: false))
                    connection.saveToServer()
                    
                    self.connections.append(connection)
                    
                    if let callback = callback {callback(success: true)}
                }else{
                    if let callback = callback {callback(success: false)}
                }
            })
        }
    }
}
