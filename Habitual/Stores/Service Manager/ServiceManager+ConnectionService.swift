//
//  ServiceManager+ConnectionService.swift
//  Ignite
//
//  Created by Josh Wright on 4/28/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import Foundation

extension ServiceManager : ConnectionService {
    
    var connections:[Connection] {
        return connectionReposity.connections
    }
    
    func connectWith(emailOfUser:String, callback: (success:Bool) -> ()) throws {
        try alreadyConnected(emailOfUser)
        connectionReposity.connectWith(emailOfUser) { (success) in
            callback(success: success)
            self.notifyConnectionServiceObservers()
        }
    }
    
    func isConnectedWith(user: User) -> Bool {
        let emails = connections.map({otherUser($0).email})
        return emails.contains(user.email)
    }
    
    private func alreadyConnected(string: String) throws {
        
        let emails = connections.map({otherUser($0).email})
        
        if(emails.contains(string)) {
            throw ConnectionServiceError.AlreadyConnected
        }else if(currentUser?.email == string){
            throw ConnectionServiceError.SelfConnection
        }
    }
    
    func approveConnection(connection: Connection) {
        connectionReposity.approveConnection(connection)
        notifyConnectionServiceObservers()
    }
    
    func otherUser(connection: Connection) -> User {
        return connection.sender.email == user?.email ? connection.receiver : connection.sender
    }
    
    func message(connection: Connection, text: String, callback:(success: Bool) -> ()) {
        connectionReposity.message(connection, text: text, callback: callback)
        notifyConnectionServiceObservers()
    }
    
    func sentByCurrentUser(connection: Connection) -> Bool {
        return connection.sender.email == currentUser?.email
    }
    
    func numHabitsAccountableInConnection(connection: Connection) -> Int {
        let user = otherUser(connection)
        return user.habits.filter({$0.emailsToNotify.contains({ (email) -> Bool in
            return email == currentUser?.email
        })}).count
    }
    
    func addConnectionServiceObserver(observer: ServiceObserver) {
        connectionServiceObservers.append(observer)
    }
    
    func removeConnectionServiceObserver(observer: ServiceObserver) {
        for i in 0..<connectionServiceObservers.count {
            if connectionServiceObservers[i] === observer {
                connectionServiceObservers.removeAtIndex(i)
            }
        }
    }
}
