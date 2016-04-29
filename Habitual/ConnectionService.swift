//
//  ConnectionService.swift
//  Ignite
//
//  Created by Josh Wright on 4/28/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import Foundation

enum ConnectionServiceError: ErrorType {
    case AlreadyConnected
    case SelfConnection
}

protocol ConnectionService {
    var connections:[Connection] {get}
    
    func connectWith(emailOfUser:String, callback: (success:Bool) -> ()) throws
    func isConnectedWith(user: User) -> Bool
    func approveConnection(connection: Connection)
    func message(connection: Connection, text: String, callback:(success: Bool) -> ())
    func otherUser(connection: Connection) -> User
    func sentByCurrentUser(connection: Connection) -> Bool
    func numHabitsAccountableInConnection(connection: Connection) -> Int
    
    func addConnectionServiceObserver(observer: ServiceObserver)
    func removeConnectionServiceObserver(observer: ServiceObserver)
}
