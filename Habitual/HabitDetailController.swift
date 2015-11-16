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
    
    var connectionsToNotify:[String] = []
    var daysOfTheWeek:[String] = ["Su","M","T","W","R","F","Sa","Su"]
    var notificationSetting: NotificationSetting = .None
    var frequency: Frequency = .Daily
    
    var editingState = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doAppearance()
        
        if let habit = habit {
            self.navigationItem.title = habit.name
            
            connectionsToNotify = habit.usernamesToNotify

            frequency = habit.frequency
            
            let button = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "edit:")
            self.navigationItem.rightBarButtonItem = button
            
            self.tableView.reloadData()
        }else{
            self.navigationItem.title = "New Habit"
            
            let button = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "done:")
            self.navigationItem.rightBarButtonItem = button
            
            habit = Habit()
        }
    }
    
    func doAppearance() {
        self.tableView.backgroundColor = kColorBackground
    }
    
    func done(sender: UIBarButtonItem){

        Utilities.postNotification(kNotificationIdentifierHabitAddedOrDeleted)
        Utilities.postNotification(kNotificationIdentifierHabitDataChanged)
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func edit(sender: UIBarButtonItem){
        
        editingState = !editingState
        
        if editingState {
            self.navigationItem.rightBarButtonItem?.title = "Save"
        } else {
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            
//            let originalHabitState = habit!.notificationsEnabled
//            let originalHabitName = habit?.name
            
            habit?.frequency = frequency
            habit?.notificationSetting = notificationSetting
            habit?.usernamesToNotify = connectionsToNotify
            
            habit?.daysToComplete = daysOfTheWeek
            
//            if originalHabitState && !swltch.on {
//                ForeignNotificationManager.deleteHabitForCurrentUser(habit!)
//            }else if !originalHabitState && swltch.on {
//                ForeignNotificationManager.uploadHabitForCurrentUser(habit!)
//            }else if habit!.notificationsEnabled {
//                ForeignNotificationManager.updateHabitForCurrentUser(habit!, originalName: originalHabitName!)
//            }
            
            Utilities.postNotification(kNotificationIdentifierHabitAddedOrDeleted)
            Utilities.postNotification(kNotificationIdentifierHabitDataChanged)
        }
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
    
    func deletePressed(){
        let alert = UIAlertController(title: "Danger Zone", message: "You sure you want to delete? Can't be undone.", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            // do nothing
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action) in
            AuthManager.deleteHabitForCurrentUser(self.habit)
            self.navigationController?.popToRootViewControllerAnimated(true)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 3
        case 2:
            return 3
        case 3:
            return 1
        default:
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let id = cellIdentifierForIndexPath(indexPath)
        
        let cell: HabitDetailCell = tableView.dequeueReusableCellWithIdentifier(id) as! HabitDetailCell
        cell.configure(habit!)
        return cell as! UITableViewCell
    }
    
    func cellIdentifierForIndexPath(ip: NSIndexPath) -> String {
        switch ip.section {
        case 0:
            switch ip.row {
            case 0: return "name"
            case 1: return "icon"
            default: return "color"}
        case 1:
            switch ip.row {
            case 0: return "repeat"
            case 1: return "days"
            default: return "times"}
        default:
            switch ip.row {
            case 0: return "accountability"
            case 1: return "connections_header"
            default: return "connection"}
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: return 44
            case 1: return 218
            default: return 89}
        case 1:
            switch indexPath.row {
            case 0: return 80
            case 1: return 83
            default: return 102}
        default:
            switch indexPath.row {
            case 0: return 72
            case 1: return 44
            default: return 58}
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Basic Info"
        case 1: return "Scheduling"
        default: return "Accountability"
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        defer { tableView.deselectRowAtIndexPath(indexPath, animated: true) }
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! SelectConnectionsTableViewController
        
        vc.didFinish = {(usernames: [String]) in
            self.connectionsToNotify = usernames
        }
        
    }
}
