//
//  HabitDetailController.swift
//  Habitual
//
//  Created by Josh Wright on 7/13/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit

// -TODO: Needs refactoring/documentation

class HabitDetailController: UITableViewController {
    
    lazy var habit:Habit = Habit()
    
    var habitService: HabitService!
    var connectionService: ConnectionService!
    
    var canInteract = true // user can interact with elements
    var editng = false // user has pressed edit button
    
    var dotwOn = true
    var accountabilityOn = false
    
    var originalHabitName:String?
    var originalHabitState:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doAppearance()
        
        Utilities.registerForNotification(self, selector: #selector(HabitDetailController.toggleDOTW), name: Notifications.dotwToggled)
        Utilities.registerForNotification(self, selector: #selector(HabitDetailController.toggleAccountability), name: Notifications.accountabilityToggled)
        
        if habitService.isTracking(habit) {
            
            self.navigationItem.title = habit.name

            canInteract = false
            accountabilityOn = habit.notificationsEnabled
            self.tableView.reloadData()
            
            let button = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(HabitDetailController.edit(_:)))
            self.navigationItem.rightBarButtonItem = button
            
            self.tableView.reloadData()
            if(habit.frequency != .Daily) {toggleDOTW()}
        }else{
            self.navigationItem.title = "New Habit"
            
            let button = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(HabitDetailController.create(_:)))
            self.navigationItem.rightBarButtonItem = button
            
            habit = Habit()
        }
        
        tableView.registerNib(UINib(nibName: "InviteCell", bundle: nil), forCellReuseIdentifier: InviteCell.reuseID)
    }
    
    func doAppearance() {
        self.tableView.backgroundColor = Colors.background
        
        Styler.navBarShader(self)
    }
    
    func create(sender: UIBarButtonItem) {

        if !checkData() { return }
        
        habitService.createHabit(habit)
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func checkData() -> Bool {
        if habit.name == "" {
            Utilities.alertWarning("Your habit needs a name", vc: self.navigationController!)
            return false
        } else if habit.frequency == .Daily && habit.daysToComplete.isEmpty {
            Utilities.alertWarning("Your habit needs to be done on at least 1 weekday", vc: self.navigationController!)
            return false
        }
        return true
    }
    
    func edit(sender: UIBarButtonItem){
        
        if !checkData() && editng { return }
        
        editng = !editng
        
        self.tableView.beginUpdates()
        if editng {
            
            self.tableView.insertSections(NSIndexSet(index: 4), withRowAnimation: .Automatic)
            
            self.navigationItem.rightBarButtonItem?.title = "Save"
            canInteract = true
            
            originalHabitName = habit.name
            originalHabitState = habit.notificationsEnabled
            
            for cell in tableView.visibleCells {cell.userInteractionEnabled = true}
            
        } else {
            
            habitService.createHabit(habit)
            
            self.tableView.deleteSections(NSIndexSet(index: 4), withRowAnimation: .Automatic)
            
            canInteract = false
            for cell in tableView.visibleCells {cell.userInteractionEnabled = false}
            
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            
            Utilities.postNotification(Notifications.habitDataChanged)
            
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
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 3)], withRowAnimation: .Automatic)
            
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: connectionService.connections.count + 2, inSection: 3)], withRowAnimation: .Automatic)
            
            for i in 0 ..< connectionService.connections.count {
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 2+i, inSection: 3)], withRowAnimation: .Automatic)
            }
        }else{
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 3)], withRowAnimation: .Automatic)
            
            for i in 0 ..< connectionService.connections.count {
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 2+i, inSection: 3)], withRowAnimation: .Automatic)
            }
            
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: connectionService.connections.count + 2, inSection: 3)], withRowAnimation: .Automatic)
        }
        self.tableView.endUpdates()
    }
    
    func detailForIndex(index: Int) -> String{
        switch index {
        case 0:
            return habitService.isTracking(habit) ? "Enter name here" : habit.name
        case 1:
            return habitService.isTracking(habit) ? "Daily" : habit.frequency.toString()
        default:
            return "\(habit.datesCompleted.count)"
        }
    }
    
    func deletePressed(){
        let alert = UIAlertController(title: "Danger Zone", message: "You sure you want to delete? Can't be undone.", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            // do nothing
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action) in
            self.habitService.deleteHabit(self.habit)
            self.navigationController?.popToRootViewControllerAnimated(true)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if editng {return 5}
        else {return 4}
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3
        case 1: return dotwOn ? 3 : 2
        case 2: return 1
        case 3: return accountabilityOn ? 3 + connectionService.connections.count : 1
        case 4: return 1
        default: return 3
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let id = cellIdentifierForIndexPath(indexPath)
        
        if(indexPath.section == 4) {
            return tableView.dequeueReusableCellWithIdentifier(id)!
        }else if indexPath.section == 3 && indexPath.row == connectionService.connections.count + 2 {
            let cell: InviteCell = tableView.dequeueReusableCellWithIdentifier(InviteCell.reuseID) as! InviteCell
            return cell
        }else if indexPath.section == 3 && indexPath.row > 1 && indexPath.row != connectionService.connections.count + 2 {
            let cell: ConnectionCell = tableView.dequeueReusableCellWithIdentifier(id) as! ConnectionCell
            let connection = connectionService.connections[indexPath.row - 2]
            cell.configure(habit, user: connectionService.otherUser(connection), color: connection.color)
            
            if !canInteract {cell.userInteractionEnabled = false}
            else {cell.userInteractionEnabled = true}
            
            return cell
        }else if indexPath.section == 2 {
            let cell: AccountabilityCell = tableView.dequeueReusableCellWithIdentifier(id) as! AccountabilityCell
            cell.privat = true
            cell.habit = habit
            
            if !canInteract {cell.userInteractionEnabled = false}
            else {cell.userInteractionEnabled = true}
            
            return cell
        }else{
            let cell: HabitDetailCell = tableView.dequeueReusableCellWithIdentifier(id) as! HabitDetailCell
            cell.habit = habit

            if indexPath.section == 3 && indexPath.row == 0 {
                let cell = cell as! AccountabilityCell
                cell.privat = false
            }
            
            if !canInteract {cell.userInteractionEnabled = false}
            else {cell.userInteractionEnabled = true}
            
            return cell
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
        case 2: return "accountability"
        case 4: return "delete"
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
            case 0: return 73
            case 1: return 393
            default: return 89}
        case 1:
            switch indexPath.row {
            case 0: return 80
            case 1: return dotwOn ? 83 : 102
            default: return 102}
        case 2: return 72
        default:
            switch indexPath.row {
            case 0: return 72
            case 1: return 44
            case connectionService.connections.count + 2: return InviteCell.height
            default: return 58}
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Basic Info"
        case 1: return "Scheduling"
        case 2: return "Privacy"
        case 3: return "Accountability"
        default: return ""
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        defer { tableView.deselectRowAtIndexPath(indexPath, animated: true) }
        switch indexPath.section {
        case 0: return
        case 1: return
        case 2: return
        case 3:
            if indexPath.row == connectionService.connections.count + 2 {
                let sc = ShareController(nibName: "ShareController", bundle: nil)
                sc.connectionService = connectionService
                let nav = UINavigationController(rootViewController: sc)
                self.presentViewController(nav, animated: true, completion: nil)
            } else {
                return
            }
        case 4: deletePressed()
        default: return
        }
    
    }
}
