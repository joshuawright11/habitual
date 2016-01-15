//
//  SocialMediaUser.swift
//  Ignite
//
//  Created by Josh Wright on 12/31/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class SocialMediaUser: NSObject {
    
    let name: String
    let imageURL: String
    let id: String
    
    init(fbjson: NSDictionary) {
        let firstName = fbjson["first_name"] as! String
        let lastName = fbjson["last_name"] as! String
        name = firstName + " " + lastName
        id = fbjson["id"] as! String
        imageURL = "https://graph.facebook.com/\(id)/picture?type=large"
    }
}
