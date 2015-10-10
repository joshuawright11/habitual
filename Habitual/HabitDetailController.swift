//
//  HabitDetailController.swift
//  Habitual
//
//  Created by Josh Wright on 7/13/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit

class HabitDetailController: UITableViewController {
    
    var habit:Habit?
    
    var notificationsEnabled: Bool = false
    
    // UI Controls
    @IBOutlet var swltch: UISwitch?
    @IBOutlet var textField: UITextField?
    @IBOutlet var frequencyLabel: UILabel?
    @IBOutlet var connectionsToNotifyLabel: UILabel?
    @IBOutlet var eventLabel: UILabel?
    
    var connectionsToNotify = []
    var notificationSetting: NotificationSetting = .None
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let habit = habit {
            self.navigationItem.title = habit.name
        }else{
            self.navigationItem.title = "New Habit"

            let button = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "done:")

            self.navigationItem.rightBarButtonItem = button

        }
    }
    
    func done(sender: UIBarButtonItem){
        
        AuthManager.addHabitForCurrentUser(self.textField!.text!, frequency: Frequency(rawValue: 0)!, notificationsEnabled: true)

        Utilities.postNotification(kNotificationIdentifierHabitAddedOrDeleted)
        Utilities.postNotification(kNotificationIdentifierHabitDataChanged)
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func detailForIndex(index: Int) -> String{
        switch index {
        case 0:
            return habit == nil ? "Enter name here" : habit!.name
        case 1:
            return habit == nil ? "Daily" : habit!.frequency.name()
        default:
            return "\(habit!.datesCompleted.count)"
        }
    }
    
    @IBAction func switchChanged() {
        self.notificationsEnabled = !self.notificationsEnabled
        
        self.tableView.reloadData()
    }
    
    func deletePressed(){
        let alert = UIAlertController(title: "Danger Zone", message: "You sure you want to delete? Can't be undone.", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            // do nothing
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action) in
            if let habit = self.habit {
                let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDel.managedObjectContext?.deleteObject(habit)
                Utilities.postNotification(kNotificationIdentifierHabitAddedOrDeleted)
            }
            
            self.navigationController?.popToRootViewControllerAnimated(true)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == 2 && habit == nil {
                return 0
            }else{
                return 44
            }
        case 1:
            if AuthManager.socialEnabled {
                if notificationsEnabled {
                    return 44
                } else if indexPath.row == 0 {
                    return 44
                } else {
                    return 0
                }
            }else{
                return 44
            }
        case 2:
            if habit == nil {
                return 0
            } else {
                return 44
            }
        default:
            return 44
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 1{
            let currentFreq = Frequency.frequencyForName(frequencyLabel!.text!)
            let nextIndex = (Frequency.allValues.indexOf(currentFreq)!+1) % Frequency.allValues.count
            
            frequencyLabel?.text = "\(Frequency.allValues[nextIndex])"
        }else if indexPath.section == (AuthManager.socialEnabled ? 2 : 1) {
            deletePressed()
        }else if AuthManager.socialEnabled && indexPath.section == 1 {
            if indexPath.row == 1 {
            }else if indexPath.row == 2{
                let currentSett = NotificationSetting.notificationSettingForName(eventLabel!.text!)
                let nextIndex = (NotificationSetting.allValues.indexOf(currentSett)!+1) % NotificationSetting.allValues.count
                
                eventLabel?.text = "\(NotificationSetting.allValues[nextIndex])"
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
}
