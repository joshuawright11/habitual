//
//  CoreDataManager.swift
//  Ignite
//
//  Created by Josh Wright on 11/25/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataManager: NSObject {

    static let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    public static func getHabitsOfCurrentUser() -> [Habit]{
        let entityDescription =
        NSEntityDescription.entityForName("Habit",
            inManagedObjectContext: managedObjectContext!)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        
        var error: NSError?
        
        var objects: [AnyObject]?
        do {
            objects = try managedObjectContext?.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            print("Error: \(error?.description)")
            objects = nil
        }
        
        var habits:[Habit] = []
        
        if let results = objects {
            if results.count > 0 {
                
                for result in results{
                    let habit = result as! HabitCoreData
                    habits.append(Habit(coreDataObject: habit))
                }
            }
        }
        return habits;
    }
    
    public static func clearHabitsOfCurrentUser() {
        let entityDescription =
        NSEntityDescription.entityForName("Habit",
            inManagedObjectContext: managedObjectContext!)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        
        var error: NSError?
        
        var objects: [AnyObject]?
        do {
            objects = try managedObjectContext?.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            print("Error: \(error?.description)")
            objects = nil
        }
        
        if let results = objects {
            
            if results.count > 0 {
                
                for result in results{
                    let habit = result as! HabitCoreData
                    managedObjectContext?.deleteObject(habit)
                }
                do {
                    try managedObjectContext?.save()
                } catch _ {
                }
                AuthManager.currentUser?.habits = [];
            }
        }
    }
}
