//
//  LocalNotificationHelper.swift
//  Habitual
//
//  Created by Josh Wright on 7/21/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import Foundation
import Timepiece

// -TODO: Needs refactoring/documentation

public func scheduleLocalNotifications() {
    
    cancelAllLocalNotifications()
    
    var count = 0
    
    if let user = AuthManager.currentUser {
        for habit:Habit in user.habits {
            if habit.datesCompleted.count == 0 || habit.canDoOn(){
                count++
            }
        }
    }
    
    let localNotificationsDisabled = Utilities.readUserDefaults(Notifications.localNotificationsDisabled)
    
    if !localNotificationsDisabled && count > 0 {
        let notification = UILocalNotification()
        if NSDate().hour > 19 {
            notification.fireDate = NSDate.tomorrow() + 19.hours
        }else{
            notification.fireDate = NSDate.today() + 19.hours
        }
        notification.alertTitle = "Ignite"

        notification.alertBody = "Don't forget you have \(count) habits left to do today!"
        notification.repeatInterval = NSCalendarUnit.Day
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}

public func cancelAllLocalNotifications() {
    
    UIApplication.sharedApplication().cancelAllLocalNotifications()
}
