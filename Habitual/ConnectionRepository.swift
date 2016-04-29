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
    
    override init() {
        super.init()
    }
    
    func initialize(connectionsLoaded callback: (success: Bool) -> ()) {
        getConnections { (success) in
            callback(success: success)
        }
    }
    
    var connections: [Connection] = []
    
    var connectionParseObjects: [Connection : PFObject] = [:]
    
    func connectWith(emailOfUser:String, callback: (success:Bool) -> ()) {
        let query1 = PFUser.query()
        query1!.whereKey("email", equalTo: emailOfUser)
        
        /// acounting for version 1.0 of the app, smfh
        
        let query2 = PFUser.query()
        query2!.whereKey("username", equalTo: emailOfUser)
        
        let query = PFQuery.orQueryWithSubqueries([query1!, query2!])
        
        query.getFirstObjectInBackgroundWithBlock({ (user, error) -> Void in
            if user != nil{
                let connectionParseObject = PFObject(className: "Connection")
                connectionParseObject["sender"] = PFUser.currentUser()
                connectionParseObject["receiver"] = user
                connectionParseObject.saveInBackground()
                
                let connection = Connection(parseObject: connectionParseObject)!
                
                self.connections.append(connection)
                
                callback(success: true)
            }else{
                callback(success: false)
            }
        })
    }
    
    /// The method which which all messages should be sent. A message is
    /// created with current connection (with the current `User` as a sender),
    /// sent to the server, appended to `messages` and then returned.
    ///
    /// - parameter text: The text of the message to send.
    func message(connection: Connection, text: String, callback:(success: Bool) -> ()) {
        guard let connectionParseObject = connectionParseObjects[connection] else {
            fatalError("You need a connection")
        }
        
        let messageParseObject = PFObject(className: "Message")
        messageParseObject["connection"] = connectionParseObject
        messageParseObject["sender"] = PFUser.currentUser()
        messageParseObject["text"] = text
        
        messageParseObject.saveInBackground()
        
        let message = Message(parseObject: messageParseObject)!
        connection.messages.append(message)
    }
    
    /// Approve the `Connection`. The approved `Connection` is then saved to the
    /// server.
    func approveConnection(connection: Connection) {
        if let parseObject = connectionParseObjects[connection] {
            parseObject["privateApproved"] = true
            connection.approved = true
            parseObject.saveInBackground()
        }
    }
}

internal extension User {
    
    /// Initialize with a Parse `PFUser` object.
    ///
    /// - parameter parseUser: The `PFUser` object with which to initialize.
    /// - parameter withHabits: Whether the habits of the parseUser are
    ///   available and should be loaded.
    convenience init?(parseUser: PFUser?) {
        
        self.init()
        
        guard let parseUser = parseUser else {
            return nil
        }
        
        email = parseUser.username!
        habits = []
        connections = []
        name = parseUser["name"] as! String
        
        for parseObject in parseUser["habits"] as! [PFObject] {
            if let habit = Habit(parseObject: parseObject) {
                if !habit.privat {
                    habits.append(habit)
                } else if !(habit.usersToNotify.filter({$0.email == email}).isEmpty) {
                    habits.append(habit)
                }
            }
        }
    }
}

private extension Connection {
    
    /// Initialize with a Parse `PFObject` object.
    ///
    /// - parameter parseObject: The `PFObject` object with which to initialize.
    convenience init?(parseObject: PFObject) {

        guard let sender = User(parseUser: parseObject["sender"] as? PFUser), receiver = User(parseUser: parseObject["receiver"] as? PFUser) else {
            return nil
        }
        
        self.init(sender: sender, receiver: receiver, color: UIColor.cyanColor())
        
        approved = parseObject["privateApproved"] as! Bool
    }
}

private extension ConnectionRepository {
    
    /// TODO TODO TODO
    /// DO NOT FETCH PRIVATE HABITS THAT AREN'T ACCOUNTABLE
    func getConnections(callback:((success: Bool) -> ())?){
        
        guard let currentUser = PFUser.currentUser() else {
            return
        }
        
        let sender = PFQuery(className: "Connection")
        sender.whereKey("sender", equalTo: currentUser)
        let receiver = PFQuery(className: "Connection")
        receiver.whereKey("receiver", equalTo: currentUser)
        
        let or = PFQuery.orQueryWithSubqueries([sender, receiver])
        or.includeKey("sender")
        or.includeKey("receiver")
        or.includeKey("sender.habits")
        or.includeKey("sender.habits.usersToNotify")
        or.includeKey("receiver.habits")
        or.includeKey("receiver.habits.usersToNotify")
        or.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let objects = objects {
                self.connections = []
                var count = 0
                var total = objects.count
                for o in objects {
                    guard let connection = Connection(parseObject: o) else {
                        continue
                    }
                    
                    self.loadMessages(connection) { (success) -> () in
                        total -= 1
                        if total == 0 {Utilities.postNotification(Notifications.reloadNetworkOffline)}
                    }
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
    
    /// Load every `Message` associated with this connection from the server and
    /// replace the content of `messages` with the results.
    ///
    /// - parameter callback: A closure which is called with `success`, a `Bool`
    ///   describing whether the API call was successful and the messages were
    ///   loaded.
    func loadMessages(connection: Connection, callback:((success: Bool) -> ())?) {
        let query = PFQuery(className: "Message")
        guard let parseObject = connectionParseObjects[connection] else {
            return
        }
        query.whereKey("connection", equalTo: parseObject)
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
                
                connection.messages = messages
                
                if let callback = callback {
                    callback(success: true)
                }
            }
        }
    }
    
    /// Save the underlying 'PFObject' to the server.
    func saveToServer(connection: Connection) {
        if let parseObject = connectionParseObjects[connection] {
            parseObject.saveInBackground()
        }
    }
    
    /// Delete the 'Connection' from the server.
    func deleteFromServer(connection: Connection) {
        if let parseObject = connectionParseObjects[connection] {
            parseObject.deleteInBackground()
        }
    }
}