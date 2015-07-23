//
//  LocalNotificationHelper.swift
//  Habitual
//
//  Created by Josh Wright on 7/21/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import Foundation
import Timepiece

public func scheduleLocalNotifications() {

    var count = 0
    
    for habit:Habit in AuthManager.currentUser!.habits {
        if habit.datesCompleted.count == 0 || habit.canDo(){
            count++
        }
    }
    
    if count > 0 && NSDate() < (NSDate.today() + 18.hours){
        let notification = UILocalNotification()
        notification.fireDate = NSDate.today() + 17.hours + 35.minutes
        notification.alertTitle = "Habitual"
        notification.alertBody = "Don't forget you have habits to do today!"
        notification.repeatInterval = NSCalendarUnit.CalendarUnitDay
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}

public func cancelAllLocalNotifications() {
    
    UIApplication.sharedApplication().cancelAllLocalNotifications()
}
