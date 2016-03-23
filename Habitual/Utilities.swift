//
//  Utilities.swift
//  Habitual
//
//  Created by Josh Wright on 6/12/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import Foundation
import UIKit
import TSMessages

// -TODO: Needs refactoring/documentation

public class Utilities {
    
    public static func alertError(string:String, vc: UIViewController){
        TSMessage.showNotificationInViewController(vc, title: "Uh oh", subtitle: string, image: nil, type: .Error, duration: 2.0, callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .NavBarOverlay, canBeDismissedByUser: true)
    }
    
    public static func alertWarning(string:String, vc: UIViewController){
        TSMessage.showNotificationInViewController(vc, title: "Hey!", subtitle: string, image: nil, type: .Warning, duration: 2.0, callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .NavBarOverlay, canBeDismissedByUser: true)
    }
    
    public static func alertSuccess(string:String, vc: UIViewController){
        TSMessage.showNotificationInViewController(vc, title: "Success!", subtitle: string, image: nil, type: .Success, duration: 2.0, callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .NavBarOverlay, canBeDismissedByUser: true)
    }
    
    public static func globalAlert(title: String, text: String){
        TSMessage.showNotificationWithTitle(title, subtitle: text, type: .Message)
    }
    
    public static func dateFromString(string: String) -> NSDate {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "YYYY-MM-DD:hh:mm:ss:ZZZZ"
        
        let date: NSDate? = dateFormatter.dateFromString(string);
        
        if let date = date {
            return date
        }else{
            return NSDate()
        }
    }
    
    public static func stringFromDate(date: NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "YYYY-MM-DD:hh:mm:ss:ZZZZ"
        
        let string: String = dateFormatter.stringFromDate(date);
        
        return string
    }
    
    public static func monthDayStringFromDate(date: NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        
        return dateFormatter.stringFromDate(date).componentsSeparatedByString(",")[0]
    }
    
    public static func monthYearStringFromDate(date: NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        
        return dateFormatter.stringFromDate(date)
    }
    
    public static func hourMinuteStringFromDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        return dateFormatter.stringFromDate(date)
    }
    
    public static func dateFromHourMinuteString(string: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        if let date = dateFormatter.dateFromString(string) {
            return date
        } else {
            return NSDate()
        }
    }
    
    public static func registerForNotification(object: AnyObject, selector:Selector, name:String){
        
        NSNotificationCenter.defaultCenter().addObserver(object, selector: selector, name: name, object: nil)
    }
    
    public static func postNotification(name: String, data: String = "", secondaryData: Bool = false) {
        
        let info:[NSObject:AnyObject] = ["data":data,"secondaryData":secondaryData]
        
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil, userInfo: info)
    }
    
    public static func writeUserDefaults(key: String, bool: Bool) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setBool(bool, forKey: key)
    }
    
    public static func readUserDefaults(key: String) -> Bool {
        let ud = NSUserDefaults.standardUserDefaults()
        
        if let bool = ud.objectForKey(key) {
            return bool as! Bool
        }else{
            return false
        }
    }
    
    public static func writeString(key: String, string: String) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setValue(string, forKey: key)
    }
    
    public static func readString(key: String) -> String {
        let ud = NSUserDefaults.standardUserDefaults()
        
        if let string = ud.objectForKey(key) {
            return string as! String
        } else {
            return ""
        }

    }
    
    public static func incrementBadgeNumber() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    public static func clearBadgeNumber() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    public static func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    public static func validEmail(email: String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if(!emailTest.evaluateWithObject(email)){
            return false
        }
        return true
    }
    
    public static func log(text: String) {
        print("---> \(text). Line: \(#line) File: \(#file) Column:\(#column) Function:\(#function)")
    }
}
