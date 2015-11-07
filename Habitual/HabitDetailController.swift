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
    
    // UI Controls
    @IBOutlet var swltch: UISwitch!
    @IBOutlet var textField: UITextField!
    @IBOutlet var frequencyLabel: UILabel!
    @IBOutlet var connectionsToNotifyLabel: UILabel!
    @IBOutlet var eventLabel: UILabel!
    @IBOutlet var daysInARowLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    @IBOutlet weak var timesTitleLabel: UILabel!
    @IBOutlet weak var timesLabel: UILabel!
    
    @IBOutlet var dotwButtons: [UIButton]!
    
    var connectionsToNotify:[String] = []
    var daysOfTheWeek:[String] = ["Su","M","T","W","R","F","Sa","Su"]
    var notificationSetting: NotificationSetting = .None
    var frequency: Frequency = .Daily
    
    var editingState = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let habit = habit {
            swltch?.on = habit.notificationsEnabled
            
            self.navigationItem.title = habit.name
            
            self.textField?.text = habit.name
 
            self.stepper.value = Double(habit.timesToComplete)
            self.timesLabel.text = "\(habit.timesToComplete)"
            
            for button: UIButton in dotwButtons {
                let text:String = (button.titleLabel?.text!)!
                if habit.daysToComplete.contains(text) {
                    button.backgroundColor = UIColor.flatWhiteColorDark()
                }
            }
            
            self.frequencyLabel?.text = "\(habit.frequency)"
            frequency = habit.frequency
            
            self.swltch?.on = habit.notificationsEnabled
            self.connectionsToNotifyLabel?.text = habit.usernamesToNotify.joinWithSeparator(", ")
            self.eventLabel?.text = "\(habit.notificationSetting)"
            self.daysInARowLabel?.text = "\(habit.currentStreak())"

            self.swltch?.userInteractionEnabled = false
            self.textField?.userInteractionEnabled = false
            
            let button = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "edit:")
            self.navigationItem.rightBarButtonItem = button
            
            self.tableView.reloadData()
        }else{
            self.navigationItem.title = "New Habit"

            editingState = true
            
            let button = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "done:")
            self.navigationItem.rightBarButtonItem = button

        }
    }
    
    func done(sender: UIBarButtonItem){
        
        AuthManager.addHabitForCurrentUser(self.textField!.text!, frequency: frequency, notificationsEnabled: (swltch?.on)!, notificationSetting: notificationSetting, usernamesToNotify: connectionsToNotify, daysOfTheWeek: self.daysOfTheWeek, times: Int(stepper.value))

        Utilities.postNotification(kNotificationIdentifierHabitAddedOrDeleted)
        Utilities.postNotification(kNotificationIdentifierHabitDataChanged)
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func dotwButtonPressed(sender: UIButton) {

        let dotw:String = (sender.titleLabel?.text!)!
        
        if !daysOfTheWeek.contains(dotw){
            sender.backgroundColor = UIColor.flatWhiteColorDark()
            daysOfTheWeek.append(dotw)
        }else{
            sender.backgroundColor = UIColor.clearColor()
            daysOfTheWeek.removeAtIndex(daysOfTheWeek.indexOf(dotw)!)
        }
    }
    
    @IBAction func stepperChanged(sender: UIStepper) {
        self.timesLabel.text = "\(Int(sender.value))"
    }
    
    func edit(sender: UIBarButtonItem){
        
        editingState = !editingState
        
        if editingState {
            self.navigationItem.rightBarButtonItem?.title = "Save"
            
            self.swltch?.userInteractionEnabled = true
            self.textField?.userInteractionEnabled = true
            
        } else {
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            
            let originalHabitState = habit!.notificationsEnabled
            let originalHabitName = habit?.name
            
            self.swltch?.userInteractionEnabled = false
            self.textField?.userInteractionEnabled = false
            
            habit?.name = (self.textField?.text!)!
            habit?.frequency = frequency
            habit?.notificationsEnabled = (swltch?.on)!
            habit?.notificationSetting = notificationSetting
            habit?.usernamesToNotify = connectionsToNotify
            
            if originalHabitState && !swltch.on {
                ForeignNotificationManager.deleteHabitForCurrentUser(habit!)
                connectionsToNotifyLabel.text = ""
            }else if !originalHabitState && swltch.on {
                ForeignNotificationManager.uploadHabitForCurrentUser(habit!)
            }else if habit!.notificationsEnabled {
                ForeignNotificationManager.updateHabitForCurrentUser(habit!, originalName: originalHabitName!)
            }
            
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
    
    @IBAction func switchChanged() {
        swltch?.on = (swltch?.on)!
        
        self.tableView.reloadData()
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

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == 4 && habit == nil {
                return 0
            }else if indexPath.row == 2 && frequency != .Daily{
                return 0
            }else{
                return 44
            }
        case 1:
            if AuthManager.socialEnabled {
                if (swltch?.on)! {
                    return 44
                } else if indexPath.row == 0 {
                    return 44
                } else {
                    return 0
                }
            }else{
                return 0
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
        
        defer { tableView.deselectRowAtIndexPath(indexPath, animated: true) }
        
        if !editingState && indexPath.section != 2 { return }
        
        if indexPath.section == 0 && indexPath.row == 1{
            let currentFreq = Frequency.frequencyForName(frequencyLabel!.text!)
            let nextIndex = (Frequency.allValues.indexOf(currentFreq)!+1) % Frequency.allValues.count
            
            frequencyLabel?.text = "\(Frequency.allValues[nextIndex])"
            frequency = Frequency.allValues[nextIndex]
            
            tableView.reloadData()
            
        }else if indexPath.section == (AuthManager.socialEnabled ? 2 : 2) { // should be 2 : 1
            deletePressed()
        }else if AuthManager.socialEnabled && indexPath.section == 1 {
            if indexPath.row == 1 {
            }else if indexPath.row == 2{
                let currentSett = NotificationSetting.notificationSettingForName(eventLabel!.text!)
                let nextIndex = (NotificationSetting.allValues.indexOf(currentSett)!+1) % NotificationSetting.allValues.count
                
                eventLabel?.text = "\(NotificationSetting.allValues[nextIndex])"
                notificationSetting = NotificationSetting.allValues[nextIndex]
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! SelectConnectionsTableViewController
        
        vc.didFinish = {(usernames: [String]) in
            self.connectionsToNotify = usernames
            self.connectionsToNotifyLabel?.text = usernames.joinWithSeparator(", ")
        }
        
    }
}
