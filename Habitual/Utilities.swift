//
//  Utilities.swift
//  Habitual
//
//  Created by Josh Wright on 6/12/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import Foundation
import UIKit

public class Utilities {
    
    public static func alert(string:String, vc:UIViewController){
        
        let alert = UIAlertController(title: "Alert", message: string, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okie Dokie Artichokie", style: UIAlertActionStyle.Default, handler: nil))
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    public static func dateFromString(string: String) -> NSDate {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "YYYY-MM-DD:hh:mm:ss:ZZZZ"
        
        let date: NSDate = dateFormatter.dateFromString(string)!;
        
        return date
    }
    
    public static func stringFromDate(date: NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "YYYY-MM-DD:hh:mm:ss:ZZZZ"
        
        let string: String = dateFormatter.stringFromDate(date);
        
        return string
    }
    
    public static func registerForNotification(object: AnyObject, selector:Selector, name:String){
        
        NSNotificationCenter.defaultCenter().addObserver(object, selector: selector, name: name, object: nil)
    }
    
    public static func postNotification(name: String) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil)
    }
}
