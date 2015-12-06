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
    
    var canInteract = true // user can interact with elements
    var editng = false // user has pressed edit button
    
    var dotwOn = true
    var accountabilityOn = false
    
    var originalHabitName:String?
    var originalHabitState:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doAppearance()
        
        Utilities.registerForNotification(self, selector: Selector("toggleDOTW"), name: kNotificationIdentifierToggleDOTW)
        Utilities.registerForNotification(self, selector: Selector("toggleAccountability"), name: kNotificationIdentifierToggleAccountability)
        
        if let habit = habit {
            self.navigationItem.title = habit.name

            canInteract = false
            accountabilityOn = habit.notificationsEnabled
            self.tableView.reloadData()
            
            let button = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "edit:")
            self.navigationItem.rightBarButtonItem = button
            
            self.tableView.reloadData()
            if(habit.frequency != .Daily) {toggleDOTW()}
        }else{
            self.navigationItem.title = "New Habit"
            
            let button = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "done:")
            self.navigationItem.rightBarButtonItem = button
            
            habit = Habit()
        }
    }
    
    func doAppearance() {
        self.tableView.backgroundColor = kColorBackground
        
        Styler.navBarShader(self)
    }
    
    func done(sender: UIBarButtonItem) {

        if habit?.name == "" {
            Utilities.alertWarning("Your habit needs a name", vc: self.navigationController!)
            return
        }
        
        habit?.createdAt = NSDate()
        habit?.saveToCoreData()
        
        Utilities.postNotification(kNotificationIdentifierHabitAddedOrDeleted)
        Utilities.postNotification(kNotificationIdentifierHabitDataChanged)
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func edit(sender: UIBarButtonItem){
        
        editng = !editng
        
        self.tableView.beginUpdates()
        if editng {
            
            self.tableView.insertSections(NSIndexSet(index: AuthManager.socialEnabled ? 3 : 2), withRowAnimation: .Automatic)
            
            self.navigationItem.rightBarButtonItem?.title = "Save"
            canInteract = true
            
            originalHabitName = habit?.name
            originalHabitState = habit?.notificationsEnabled
            
            for cell in tableView.visibleCells {cell.userInteractionEnabled = true}
            
        } else {
            
            if habit?.coreDataObject == nil {
                AuthManager.currentUser?.habits.append(habit!)
            }
            
            habit?.saveToCoreData()
            
            self.tableView.deleteSections(NSIndexSet(index: AuthManager.socialEnabled ? 3 : 2), withRowAnimation: .Automatic)
            
            canInteract = false
            for cell in tableView.visibleCells {cell.userInteractionEnabled = false}
            
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            
            Utilities.postNotification(kNotificationIdentifierHabitAddedOrDeleted)
            Utilities.postNotification(kNotificationIdentifierHabitDataChanged)
            
            navigationController?.popToRootViewControllerAnimated(true)
        }
        self.tableView.endUpdates()
    }
    
    func toggleDOTW() {
        dotwOn = !dotwOn
        self.tableView.beginUpdates()
        if(!dotwOn){
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1)], withRowAnimation: .Automatic)
        }else{
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1)], withRowAnimation: .Automatic)
        }
        self.tableView.endUpdates()
    }
    
    func toggleAccountability() {
        accountabilityOn = !accountabilityOn
        self.tableView.beginUpdates()
        if(!accountabilityOn){
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 2)], withRowAnimation: .Automatic)
            
            for var i = 0; i < (AuthManager.currentUser?.connections.count)!; i++ {
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 2+i, inSection: 2)], withRowAnimation: .Automatic)
            }
        }else{
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 2)], withRowAnimation: .Automatic)
            
            for var i = 0; i < (AuthManager.currentUser?.connections.count)!; i++ {
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 2+i, inSection: 2)], withRowAnimation: .Automatic)
            }
        }
        self.tableView.endUpdates()
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
            AuthManager.currentUser!.habits.removeAtIndex(AuthManager.currentUser!.habits.indexOf(self.habit!)!)
            self.habit?.deleteFromCoreData()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if editng {return AuthManager.socialEnabled ? 4 : 3}
        else {return AuthManager.socialEnabled ? 3 : 2}
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return dotwOn ? 3 : 2
        case 2:
            return accountabilityOn ? 2+(AuthManager.currentUser?.connections.count)! : 1
        case 3:
            return 1
        default:
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let id = cellIdentifierForIndexPath(indexPath)
        
        if(indexPath.section == (AuthManager.socialEnabled ? 3 : 2)) {
            return tableView.dequeueReusableCellWithIdentifier(id)!
        }else if indexPath.section == 2 && indexPath.row > 1 {
            let cell: ConnectionCell = tableView.dequeueReusableCellWithIdentifier(id) as! ConnectionCell
            cell.configure(habit!, index: indexPath.row - 2)
            
            if !canInteract {cell.userInteractionEnabled = false}
            else {cell.userInteractionEnabled = true}
            
            return cell
        }else{    
            let cell: HabitDetailCell = tableView.dequeueReusableCellWithIdentifier(id) as! HabitDetailCell
            cell.configure(habit!)
            
            let toReturn: UITableViewCell = cell as! UITableViewCell
            
            if !canInteract {toReturn.userInteractionEnabled = false}
            else {toReturn.userInteractionEnabled = true}
            
            return cell as! UITableViewCell
        }
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
            case 1: return dotwOn ? "days" : "times"
            default: return "times"}
        case 3: return "delete"
        default:
            if(!AuthManager.socialEnabled) {return "delete"}
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
            case 0: return 73
            case 1: return 393
            default: return 89}
        case 1:
            switch indexPath.row {
            case 0: return 80
            case 1: return dotwOn ? 83 : 102
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
        case 2: return AuthManager.socialEnabled ? "Accountability" : ""
        default: return ""
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        defer { tableView.deselectRowAtIndexPath(indexPath, animated: true) }
        switch indexPath.section {
        case 0: return
        case 1: return
        case 2: if !AuthManager.socialEnabled {deletePressed()}
        case 3: deletePressed()
        default: return
        }
    
    }
    
    // MARK: - View Controller methods
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        
        if habit?.createdAt == nil && parent == nil{
            habit?.deleteFromCoreData()
        }
    }
}
