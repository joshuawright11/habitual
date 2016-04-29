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

public class HabitReminderManager {
    
    var habitService: HabitService
    
    init(habitService: HabitService) {
        self.habitService = habitService
    }
    
    public func scheduleLocalNotifications() {
        
        cancelAllLocalNotifications()
        
        var count = 0
    
        for habit:Habit in habitService.habits {
            if habit.datesCompleted.count == 0 || habit.canDoOn(){
                count += 1
            }
        }
        
        let localNotificationsDisabled = Utilities.readUserDefaults(Notifications.localNotificationsDisabled)
        
        if !localNotificationsDisabled && count > 0 {
            let notification = UILocalNotification()
            
            var timeString = Utilities.readString(Notifications.reminderTime)
            if timeString == "" {
                timeString = "7:00 PM"
            }
            
            let date = Utilities.dateFromHourMinuteString(timeString)
            
            if NSDate().hour > date.hour || (NSDate().hour == date.hour && NSDate().minute >= date.minute) {
                notification.fireDate = NSDate.tomorrow() + date.hour.hours + date.minute.minutes
            }else{
                notification.fireDate = NSDate.today() + date.hour.hours + date.minute.minutes
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

}
