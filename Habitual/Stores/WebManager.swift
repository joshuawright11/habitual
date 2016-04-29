//
//  WebServices.swift
//  Habitual
//
//  Created by Josh Wright on 6/12/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import Foundation
import SwiftyJSON
import Locksmith
import Parse
import Timepiece

/*
    TODO: - Rather confusing, should only work through the AuthManager class
// -TODO: Needs refactoring/documentation
*/
public class WebServices: NSObject {
    
    static func getContacts(emails: [String], callback: (success: Bool, users:[User]) -> ()) {
        let query = PFUser.query()
        query?.whereKey("email", containedIn: emails)
        query?.findObjectsInBackgroundWithBlock({ (users: [PFObject]?, error) -> Void in
            if let error = error {
                print("Error! \(error.localizedDescription)")
                callback(success: false, users: [])
            } else {
                var userList: [User] = []
                for parseUser: PFUser in users as! [PFUser] {
                    if let user = User(parseUser: parseUser) {
                        userList.append(user)
                    }
                }
                callback(success: true, users: userList)
            }
        })
    }
    
    static func getFBFriends(fbIds: [String], callback: (success: Bool, users:[User]) -> ()) {
        let query = PFUser.query()
        query?.whereKey("fbId", containedIn: fbIds)
        query?.findObjectsInBackgroundWithBlock({ (users: [PFObject]?, error) -> Void in
            if let error = error {
                print("Error! \(error.localizedDescription)")
                callback(success: false, users: [])
            } else {
                var userList: [User] = []
                for parseUser: PFUser in users as! [PFUser] {
                    if let user = User(parseUser: parseUser) {
                        userList.append(user)
                    }
                }
                callback(success: true, users: userList)
            }
        })
    }
}
