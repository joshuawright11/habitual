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
        if state == UIApplicationState.Inactive {
            PFPush.handlePush(userInfo)
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }else{
            Utilities.postNotification(kNotificationChatReceived)
        }
    }
}
