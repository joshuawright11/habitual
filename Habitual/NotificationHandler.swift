//
//  NotificationHandler.swift
//  Ignite
//
//  Created by Josh Wright on 11/23/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Foundation
import Parse

class NotificationHandler: NSObject {

    static func handPush(state: UIApplicationState, userInfo: [NSObject : AnyObject]) {
        if state == .Inactive || state == .Background{
            PFPush.handlePush(userInfo)
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            Utilities.incrementBadgeNumber()
        }else{
            
            Utilities.incrementBadgeNumber()
            
            let action = userInfo["action"] as! String
            
            switch action {
            case kNotificationChatReceived:
                Utilities.postNotification(kNotificationChatReceived)
            case kNotificationIdentifierReloadConnections:
                Utilities.postNotification(kNotificationIdentifierReloadConnections)
            default:
                return
            }
        }
    }
}
