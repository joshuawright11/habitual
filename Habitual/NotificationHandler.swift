//
//  NotificationHandler.swift
//  Ignite
//
//  Created by Josh Wright on 11/23/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Foundation
import Parse

// -TODO: Needs refactoring/documentation

class NotificationHandler: NSObject {

    static func handPush(state: UIApplicationState, userInfo: [NSObject : AnyObject]) {
        if state == .Inactive || state == .Background {
            PFPush.handlePush(userInfo)
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            Utilities.incrementBadgeNumber()
        }

        let action = userInfo["action"] as! String
        
        switch action {
        case Notifications.reloadChat:
            Utilities.postNotification(Notifications.reloadChat)
            Utilities.globalAlert("Message", text: userInfo["aps"]!["alert"] as! String)
        case Notifications.reloadNetworkOnline:
            Utilities.postNotification(Notifications.reloadNetworkOnline)
            Utilities.globalAlert("Connections", text: userInfo["aps"]!["alert"] as! String)
        default:
            return
            
        }
    }
}
