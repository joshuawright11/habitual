//
//  ConnectionRepository.swift
//  Ignite
//
//  Created by Josh Wright on 4/1/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import UIKit
import Parse

class ConnectionRepository: NSObject {
    var connections: [Connection] = []
    
    func connectWith(emailOfUser:String, callback: (success:Bool) -> ()) {
        
    }
    
    func message(connection: Connection, text: String, callback:(success: Bool) -> ()) {
        
    }
    
    func approveConnection(connection: Connection) {
        
    }
}

private extension User {
    
    /// TODO TODO TODO
    /// DO NOT FETCH PRIVATE HABITS THAT AREN'T ACCOUNTABLE
    func getConnections(callback:((success: Bool) -> ())?){
        
        let sender = PFQuery(className: "Connection")
        sender.whereKey("sender", equalTo: parseObject)
        let receiver = PFQuery(className: "Connection")
        receiver.whereKey("receiver", equalTo: parseObject)
        
        let or = PFQuery.orQueryWithSubqueries([sender, receiver])
        or.includeKey("sender")
        or.includeKey("receiver")
        or.includeKey("sender.habits")
        or.includeKey("sender.habits.usersToNotify")
        or.includeKey("receiver.habits")
        or.includeKey("receiver.habits.usersToNotify")
        or.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let objects = objects {
                print("connections loaded \(objects.count)")
                self.connections = []
                var count = 0
                var total = objects.count
                for o in objects {
                    guard let connection = Connection(parseObject: o) else {
                        continue
                    }
                    
                    connection.loadMessages({ (success) -> () in
                        total -= 1
                        if total == 0 {Utilities.postNotification(Notifications.reloadNetworkOffline)}
                    })
                    connection.color = Colors.rainbow[count % 6]
                    count += 1
                    self.connections.append(connection)
                }
                if let callback = callback {
                    callback(success: true)
                }
            } else {
                print("error loading connections")
            }
        }
    }
    
    func addConnection(email: String, callback:((success: Bool) -> ())?) {
        
        let query1 = PFUser.query()
        query1!.whereKey("email", equalTo: email)
        
        /// acounting for version 1.0 of the app, smfh
        
        let query2 = PFUser.query()
        query2!.whereKey("username", equalTo: email)
        
        let query = PFQuery.orQueryWithSubqueries([query1!, query2!])
        
        query.getFirstObjectInBackgroundWithBlock({ (user, error) -> Void in
            
            if user != nil{
                if let callback = callback {callback(success: true)}
            }else{
                if let callback = callback {callback(success: false)}
            }
        })

    }
}

private extension Connection {
    
    /// The method which which all messages should be sent. A message is
    /// created with current connection (with the current `User` as a sender),
    /// sent to the server, appended to `messages` and then returned.
    ///
    /// - parameter text: The text of the message to send.
    ///
    /// - returns: The newly created `Message` that has been asynchronously sent
    ///   to the server.
    func sendMessage(text: String) -> Message {
        let message = Message(parseObject: PFObject(className: "Message"))
        return message!
    }
    
    /// Load every `Message` associated with this connection from the server and
    /// replace the content of `messages` with the results.
    ///
    /// - parameter callback: A closure which is called with `success`, a `Bool`
    ///   describing whether the API call was successful and the messages were
    ///   loaded.
    func loadMessages(callback:((success: Bool) -> ())?) {
        let query = PFQuery(className: "Message")
        query.whereKey("connection", equalTo: self.parseObject)
        query.orderByAscending("timeStamp")
        query.includeKey("sender")
        query.includeKey("habit")
        query.findObjectsInBackgroundWithBlock { (parseObjects, error) -> Void in
            if let parseObjects = parseObjects {
                var messages: [Message] = []
                for parseObject in parseObjects {
                    if let message = Message(parseObject: parseObject) {
                        messages.append(message)
                    }
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
        parseObject.saveInBackground()
    }
    
    /// Approve the `Connection`. The approved `Connection` is then saved to the
    /// server.
    func approve() {
        parseObject["privateApproved"] = true
        approved = true
        parseObject.saveInBackground()
    }
    
    /// Delete the 'Connection' from the server.
    func deleteFromServer() {
        parseObject.deleteInBackground()
    }
}