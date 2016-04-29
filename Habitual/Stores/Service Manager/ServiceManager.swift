//
//  ServiceManager.swift
//  Ignite
//
//  Created by Josh Wright on 3/31/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import UIKit
import Parse

protocol ServiceObserver: class {
    func serviceDidUpdate()
}

class ServiceManager: NSObject {
    var habitRepository: HabitRepository = HabitRepository()
    var connectionReposity: ConnectionRepository = ConnectionRepository()
    
    internal var user: User?
    
    var habitServiceObservers: [ServiceObserver] = []
    var connectionServiceObservers: [ServiceObserver] = []
    var accountServiceObservers: [ServiceObserver] = []
    
    override init() {
        user = User(parseUser: PFUser.currentUser())
        super.init()
        connectionReposity.initialize { (success) in
            if success {
                self.notifyConnectionServiceObservers()
            }
        }
    }
    
    func notifyHabitServiceObservers() {
        for observer in habitServiceObservers {
            observer.serviceDidUpdate()
        }
    }
    
    func notifyConnectionServiceObservers() {
        for observer in connectionServiceObservers {
            observer.serviceDidUpdate()
        }
    }
    
    func notifyAccountServiceObservers() {
        for observer in accountServiceObservers {
            observer.serviceDidUpdate()
        }
    }
}