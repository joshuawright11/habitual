//
//  AccountService.swift
//  Ignite
//
//  Created by Josh Wright on 4/28/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import Foundation

protocol AccountService {
    var isLoggedIn: Bool { get }
    var currentUser: User? { get }
    
    var isFakeEmail: Bool { get }
    
    func login(email: String, password:String, callback: (success: Bool) -> ())
    func signup(email: String, password:String, name: String, callback: (success: Bool) -> ())
    func connectWithFacebook(callback:(success: Bool) -> ())
    
    func addAccountServiceObserver(observer: ServiceObserver)
    func removeAccountServiceObserver(observer: ServiceObserver)
}
