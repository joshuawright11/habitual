//
//  Habit.swift
//  Ignite
//
//  Created by Josh Wright on 11/25/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Timepiece


/// A model for the habits that a user can create in the app. Each `Habit` has
/// specific data about when it should be completed, to whom and how it should
/// be accountable, and various display settings.
public class Habit: NSObject {

    // ******************
    // MARK: - Properties
    // ******************
    
    /// The dates on which the `Habit` was completed.
    var datesCompleted: [NSDate]
    
    /// The frequency at which the habit should be repeated.
    var frequency:Frequency
    
    /// The name of the `Habit`
    var name: String
    
    /// The time and date the `Habit` was created at.
    var createdAt: NSDate
    
    /// Whether the `Habit` should be kept private and not shown to connections,
    /// except those to which the `Habit` is accountable.
    var privat: Bool
    
    /// The `String` value of the time to remind the user to complete the habit.
    /// Empty string (`""`) if the user should never be reminded.
    var remindUserAt: String
    
    /// The `String` value of the time to remind the users to which the habit is
    /// accountable, if the habit has not been completed by that time.
    var notifyConnectionsAt: String
    
    /// The time of day that a user aims to complete this `Habit`.
    ///     WARNING: Currently used to keep track of habit ordering, nothing to do
    ///     with time of day
    var timeOfDay: Int
    
    /// The amount of times a habit should be completed per `Frequency`.
    var timesToComplete: Int
    
    /// The `String` values of the days on which the habit should be completed.
    /// The format of the days are:
    ///
    ///     Sunday    : "Su"
    ///     Monday    : "M"
    ///     Tuesday   : "T"
    ///     Wednesday : "W"
    ///     Thursday  : "R"
    ///     Friday    : "F"
    ///     Saturday  : "Sa"
    var daysToComplete: [String]
    
    /// The filename of the habit's icon.
    var icon: String
    
    /// The hex value of the habit's color in the form "#RRGGBB".
    var color: String
    
    /// Whether the habit is accountable to any connections.
    var notificationsEnabled: Bool
    
    /// The `NotificationSetting`s describing when users to which the habit is 
    /// accountable should be notified.
    var notificationSettings:[NotificationSetting]
    
    /// The `User` objects of the users to which the habit is accountable.
    var usersToNotify: [User]
    
    var streakBadge: String {
        get {
            let emoji:String
            switch(currentStreak()) {
            case 0...1:
                emoji = ""
            case 2...5:
                emoji = "🔥"
            case 6...9:
                emoji = "⚡️"
            case 10...19:
                emoji = "✨"
            case 20...99:
                emoji = "🌟"
            default:
                emoji = "💯"
            }
            return emoji
        }
    }
    
    
    // ********************
    // MARK: - Initializers
    // ********************
    
    /// Basic initializer. This is used for when a habit is created in the app
    /// but has not yet been saved to Core Data or the server. This should never
    /// otherwise be called.
    override init() {
        datesCompleted = []
        frequency = .Daily
        name = ""
        createdAt = NSDate()
        privat = false
        remindUserAt = ""
        notifyConnectionsAt = ""
        timeOfDay = -1
        timesToComplete = 1
        daysToComplete = []
        icon = "compass"
        color = Colors.purple.hexString
        notificationsEnabled = false
        notificationSettings = [.None]
        usersToNotify = []
        
        super.init()
    }
    
    // ***************
    // MARK: - Methods
    // ***************

    /// Whether the habit should be completed on a certain day. Factors in this
    /// are the creation date of the `Habit` and the days of the week on which
    /// the `Habit` is available, if the `Habit` has a `Frequency` of `Daily`.
    /// 
    /// - parameter date: A date on which to see if the habit should be
    ///                   completed.
    ///
    /// - returns: Whether the `Habit` should be completed on `date`.
    public func availableOn(date: NSDate) -> Bool {
        
        if createdAt.beginningOfDay > date {return false}
        
        if(frequency == .Daily) {
            let dsotw = ["Su","M","T","W","R","F","Sa"]
            
            let dayOfWeek = dsotw[date.weekday-1]
            
            if !daysToComplete.contains(dayOfWeek) {return false}
        }
        
        return true
    }
    
    /// Whether the habit is able to be completed on a certain date. This
    /// differs from `availableOn(date:NSDate)` in that it reuturns true only if
    /// the `Habit` has not already been completed the maximum amount of times
    /// on the date.
    ///
    /// - parameter date: A date on which to see if the habit can be completed.
    ///
    /// - returns: Whether the `Habit` can be completed on `date`.
    public func canDoOn(date: NSDate = NSDate()) -> Bool {
        let timesDone = numCompletedIn(date)
        return availableOn(date) && timesDone < timesToComplete
    }
    
    /// Count and return the number of times the `Habit` has been completed in 
    /// the `Frequency` unit containing a date. An example would be (assuming 
    /// the `Habit` has a `frequency` of `Weekly`) the amount of times the habit
    /// has been done in the full week containing the date.
    ///
    /// - Note: Days begin at 12AM, Weeks begin on Sunday and Months begin on 
    ///         the 1st.
    ///
    /// - parameter date: The date that's `Frequency` unit should have the
    ///                   number of times a habit was completed in it counted.
    ///
    /// - returns: The number of times the `Habit` was completed in the 
    ///            `Frequency` unit of `date`.
    public func numCompletedIn(date: NSDate) -> Int {
        
        var count = 0
        
        let first: NSDate, last: NSDate
        
        switch frequency {
        case .Daily:
            first = date.beginningOfDay
            last = date.endOfDay
        case .Weekly:
            first = date.beginningOfWeek
            last = date.endOfWeek
        case .Monthly:
            first = date.beginningOfMonth
            last = date.endOfMonth
        }
        
        for completion: NSDate in datesCompleted {
            if(first...last).contains(completion) {count += 1}
        }
        
        return count
    }
    
    /// Simple method for determining whether a date is in the current
    /// `Frequency` unit. Primarily used to see if completing a habit might
    /// warrent a server call to notify users to which the habit is accountable.
    ///
    /// - parameter date: The date that should be checked to see if it is in the
    ///                   current `Frequency` unit.
    ///
    /// - returns: Whether `date` is in the current `Frequency` unit.
    public func dateInCurrentFrequency(date: NSDate) -> Bool {
        
        let now = NSDate()
        
        switch frequency {
        case .Daily:
            return date >= now.beginningOfDay
        case .Weekly:
            return date >= now.beginningOfWeek
        case .Monthly:
            return date >= now.beginningOfMonth
        }
    }
    
    /// When the habit must next be completed by.
    ///
    /// - returns: The date and time at which the habit must be completed by.
    public func dueOn() -> NSDate {
        if datesCompleted.count < 1 { // If the habit has just been created base
            switch frequency {        // the due date off of the creation date.
            case .Daily:
                return createdAt.endOfDay
            case .Weekly:
                return createdAt.endOfWeek
            case .Monthly:
                return createdAt.endOfMonth
            }
        }
        
        let lastCompletedOn = datesCompleted.sort().last!
        let countDone = numCompletedIn(lastCompletedOn)
        if countDone < timesToComplete { // If the habit has not been fully
            switch frequency {           // completed this `Frequency` unit
            case .Daily:                 // return the end of this unit.
                return lastCompletedOn.endOfDay
            case .Weekly:
                return lastCompletedOn.endOfWeek
            case .Monthly:
                return lastCompletedOn.endOfMonth
            }
        }
        
        switch frequency { // If the habit has been fully completed this
        case .Daily:       // `Frequency` unit, return the end of this unit plus
            return lastCompletedOn.endOfDay + 1.day // one unit.
        case .Weekly:
            return lastCompletedOn.endOfWeek + 1.week
        case .Monthly:
            return lastCompletedOn.endOfMonth + 1.month
        }
    }
    
    
    /// Whether the habit was completed during the current frequency.
    ///
    /// - returns: Whether the habit was completed during the current frequency.
    public func completed() -> Bool {
        switch frequency {
        case .Daily:
            return datesCompleted.sort().last > NSDate().beginningOfDay
        case .Weekly:
            return datesCompleted.sort().last > NSDate().beginningOfWeek
        case .Monthly:
            return datesCompleted.sort().last > NSDate().beginningOfMonth
        }
    }
    
    /// Calculate the overall completion percentage for the `Habit`.
    ///
    /// - returns: The completion percentage, 0.0 - 100.0, of the `Habit` since
    ///            it was created.
    public func getCompletionPercentage() -> Double{
        let perc = (Double(datesCompleted.count)/unitsSinceBegan())*100.0
        return perc/Double(timesToComplete)
    }
    
    /// The number of `Frequency` units since the habit was created. Rounded up.
    ///
    /// - returns: The number of `Frequency` units, currently either Days,
    ///            Weeks or Months.
    private func unitsSinceBegan() -> Double {
        let today = NSDate()
        
        let startOfFirstInterval: NSDate
        switch frequency {
        case .Daily:
            startOfFirstInterval = createdAt.beginningOfDay
        case .Weekly:
            startOfFirstInterval = createdAt.beginningOfWeek
        case .Monthly:
            startOfFirstInterval = createdAt.beginningOfMonth
        }
        
        let daysSinceBegan = (today.endOfDay.timeIntervalSinceDate(startOfFirstInterval))/86400
        let unitsSinceBegan: Double
        
        switch frequency {
        case .Daily:
            
            if daysToComplete.count < 7 {
                var days = 0
                var date = createdAt.beginningOfDay
                
                let dsotw = ["Su","M","T","W","T","F","Sa"]
                
                while(date < NSDate()) {
                    if(daysToComplete.contains(dsotw[date.weekday-1])) {
                        days += 1
                    }
                    date = date + 1.day
                }
                unitsSinceBegan = days == 0 ? Double(1) : Double(days)
                
            }else{
                unitsSinceBegan = ceil(daysSinceBegan)
            }
        case .Weekly:
            unitsSinceBegan = ceil(daysSinceBegan/7)
        case .Monthly:
            unitsSinceBegan = ceil(daysSinceBegan/30.417)
        }
        
        return unitsSinceBegan
    }
    
    /// DOESNT WORK
    
    public func currentStreak(onDate: NSDate = NSDate()) -> Int {
        
        var yesterunit:NSDate
        let beginning: (NSDate) -> (NSDate)
        let unit:Duration
        
        switch frequency {
        case .Daily:
            yesterunit = NSDate().beginningOfDay - 1.day
            beginning = {(date) in return date.beginningOfDay}
            unit = 1.day
        case .Weekly:
            yesterunit = NSDate().beginningOfWeek - 1.week
            beginning = {(date) in return date.beginningOfWeek}
            unit = 1.week
        case .Monthly:
            yesterunit = NSDate().beginningOfMonth - 1.month
            beginning = {(date) in return date.beginningOfMonth}
            unit = 1.month
        }
        
        // ignore everything in the current unit
        let sortedCompletions = datesCompleted.filter({$0 < (beginning(onDate))}).sort().reverse()
        let overflow = datesCompleted.filter({$0 >= (beginning(onDate))})
        
        if sortedCompletions.first == nil || sortedCompletions.first < yesterunit {
            return overflow.count >= timesToComplete ?  1 : 0;
        }
        
        var count = overflow.count >= timesToComplete ? 1 : 0
        
        var after: NSDate = beginning(yesterunit)
        var leftToComplete = timesToComplete
        
        for date in sortedCompletions {
                if(date > after + unit) {continue}
                else if date >= after {
                    leftToComplete -= 1
                    if leftToComplete == 0 {
                        count += 1
                        leftToComplete = timesToComplete
                        after = after - unit
                    }
                } else {
                    return count
                }
        }
        return count
    }
    
    public static func emoji(streak: Int) -> String {
        let emoji:String
        switch(streak) {
        case 0...1:
            emoji = ""
        case 2...5:
            emoji = "🔥"
        case 6...9:
            emoji = "⚡️"
        case 10...19:
            emoji = "✨"
        case 20...99:
            emoji = "🌟"
        default:
            emoji = "💯"
        }
        
        return emoji
    }
}
