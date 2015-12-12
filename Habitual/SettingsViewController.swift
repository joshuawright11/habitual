//
//  SettingsViewController.swift
//  Ignite
//
//  Created by Josh Wright on 11/17/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import MessageUI

// -TODO: Needs refactoring/documentation

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doAppearance()
    }
    
    func doAppearance() {
        self.tableView.backgroundColor = Colors.background
        notificationsLabel.font = Fonts.sectionHeader
        notificationsLabel.textColor = Colors.textMain
        
        notificationSwitch.on = !Utilities.readUserDefaults(Notifications.localNotificationsDisabled)
        
        Styler.navBarShader(self)
        
        let button = UIBarButtonItem(title: "Pulse", style: .Plain, target: self, action: "pulse")
        self.navigationItem.rightBarButtonItem = button
    }
    
    func pulse() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.textLabel!.font = Fonts.sectionHeader
        cell.textLabel!.textColor = Colors.textMain
        return cell
    }
    
    @IBAction func notificationSwitchToggled(sender: UISwitch) {
        Utilities.writeUserDefaults(Notifications.localNotificationsDisabled, bool: !sender.on)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 999:
            switch indexPath.row {
            case 0: shareTwitter()
            case 1: shareFacebook()
            default: shareText()
            }
        case 1:
            switch indexPath.row {
            case 0: submitFeedBack()
            default: rateOnAppStore()
            }
        default: return
        }
    }
    
    func shareTwitter() {
        
    }
    
    func shareFacebook() {
        
    }
    
    func shareText() {
        
    }
    
    func submitFeedBack() {
        if(MFMailComposeViewController.canSendMail()) {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("Ignite Feedback")
            mail.setToRecipients(["joshuawright11@gmail.com"])
            self.presentViewController(mail, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func rateOnAppStore() {
        
    }
}
