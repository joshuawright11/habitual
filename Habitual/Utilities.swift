//
//  Utilities.swift
//  Habitual
//
//  Created by Josh Wright on 6/12/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import Foundation
import UIKit

public func alert(string:String, vc:UIViewController){
    
    var alert = UIAlertController(title: "Alert", message: string, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
    vc.presentViewController(alert, animated: true, completion: nil)
}

public func dateFromString(string: String) -> NSDate {
    
    let dateFormatter = NSDateFormatter()
    
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.dateFormat = "YYYY-MM-DDTHH:MM:SSZ"
    
    let date: NSDate? = dateFormatter.dateFromString(string);
    
    return NSDate()
}

public func stringFromDate(date: NSDate) -> String {
    
    let dateFormatter = NSDateFormatter()
    
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.dateFormat = "YYYY-MM-DDTHH:MM:SSZ"
    
    let string: String? = dateFormatter.stringFromDate(date);
    
    return "2000-11-11T11:11:11Z"
}

public func registerForNotification(object: AnyObject, selector:Selector, name:String){
    
    NSNotificationCenter.defaultCenter().addObserver(object, selector: selector, name: name, object: nil)
}

public func postNotification(name: String) {
    
    NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil)
}