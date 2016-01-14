//
//  SettingsViewController.swift
//  Ignite
//
//  Created by Josh Wright on 11/17/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import MessageUI
import Social

// -TODO: Needs refactoring/documentation

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    let url = "https://itunes.apple.com/us/app/ignite-habit-tracker-accountability/id1049840265?ls=1&mt=8"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doAppearance()
    }
    
    func doAppearance() {
        self.tableView.backgroundColor = Colors.background
        
        Styler.navBarShader(self)
        
        let button = UIBarButtonItem(image: UIImage(named: "tab_pulse")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: "pulse")
        self.navigationItem.rightBarButtonItem = button
        
        tableView.registerNib(UINib(nibName: "SettingsCell", bundle: nil), forCellReuseIdentifier: SettingsCell.reuseIdentifier)
    }
    
    func pulse() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func notificationSwitchToggled(sender: UISwitch) {
        Utilities.writeUserDefaults(Notifications.localNotificationsDisabled, bool: !sender.on)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        default: return 6
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:SettingsCell = tableView.dequeueReusableCellWithIdentifier("settings") as! SettingsCell
        cell.titleLabel.text = "Share on Facebook"
        doCell(cell, indexPath: indexPath)
        return cell
    }
    
    func doCell(cell: SettingsCell, indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            switch(indexPath.row) {
            case 0:
                cell.iv?.image = UIImage(named: "alarm")?.imageWithRenderingMode(.AlwaysTemplate)
                cell.iv?.tintColor = Colors.yellow
                cell.borderView.backgroundColor = Colors.yellow.igniteDarken()
                cell.titleLabel.text = "Daily Reminders @ 7pm"
            default: break
            }
        case 1:
            switch(indexPath.row) {
            case 0:
                cell.iv?.image = UIImage(named: "question_mark")?.imageWithRenderingMode(.AlwaysTemplate)
                cell.iv?.tintColor = Colors.red
                cell.borderView.backgroundColor = Colors.red.igniteDarken()
                cell.titleLabel.text = "Get Support"
            default: break
            }
        case 2:
            switch(indexPath.row) {
            case 0:
                cell.iv?.image = UIImage(named: "email_plane")?.imageWithRenderingMode(.AlwaysTemplate)
                cell.iv?.tintColor = Colors.green
                cell.borderView.backgroundColor = Colors.green.igniteDarken().lightenColor(0.07)
                cell.titleLabel.text = "Send Feedback or Ideas"
            case 1:
                cell.iv?.image = UIImage(named: "apple")?.imageWithRenderingMode(.AlwaysTemplate)
                cell.iv?.tintColor = UIColor.whiteColor()
                cell.borderView.backgroundColor = Colors.silver
                cell.titleLabel.text = "Rate on App Store"
            case 2:
                cell.iv?.image = UIImage(named: "facebook")?.imageWithRenderingMode(.AlwaysTemplate)
                cell.iv?.tintColor = Colors.blue
                cell.borderView.backgroundColor = Colors.blue.igniteDarken().lightenColor(0.07)
                cell.titleLabel.text = "Share on Facebook"
            case 3:
                cell.iv?.image = UIImage(named: "twitter")?.imageWithRenderingMode(.AlwaysTemplate)
                cell.iv?.tintColor = Colors.accentSecondary
                cell.borderView.backgroundColor = Colors.accentSecondary.igniteDarken().lightenColor(0.07)
                cell.titleLabel.text = "Share on Twitter"
            case 4:
                cell.iv?.image = UIImage(named: "email_contacts_outline")?.imageWithRenderingMode(.AlwaysTemplate)
                cell.iv?.tintColor = Colors.orange
                cell.borderView.backgroundColor = Colors.orange.igniteDarken().lightenColor(0.07)
                cell.titleLabel.text = "Invite a Friend via Email"
            case 5:
                cell.iv?.image = UIImage(named: "chats")?.imageWithRenderingMode(.AlwaysTemplate)
                cell.iv?.tintColor = Colors.purple
                cell.borderView.backgroundColor = Colors.purple.igniteDarken().lightenColor(0.07)
                cell.titleLabel.text = "Invite a Friend via Text"
            default: break
            }
        default: break
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 52
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 1: submitFeedBack()
        case 2: switch indexPath.row {
            case 0: submitFeedBack()
            case 1: rateOnAppStore()
            case 2: shareFacebook()
            case 3: shareTwitter()
            case 4: shareEmail()
            case 5: shareText()
            default: submitFeedBack()
            }
        default: break
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Options"
        case 1: return "Support"
        case 2: return "Help Ignite Grow :)"
        default: return ""
        }
    }
    
    func rateOnAppStore() {
        UIApplication.sharedApplication().openURL(NSURL(string: "\(url)")!)
    }
    
    func shareText() {
        if MFMessageComposeViewController.canSendText() {
            let text = MFMessageComposeViewController()
            text.messageComposeDelegate = self
            text.body = "Hey! Check out this cool app \(url)"
            self.presentViewController(text, animated: true, completion: nil)
        } else {
            Utilities.alertError("No can do!", vc: self.navigationController!)
        }
    }
    
    func shareFacebook() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let fb = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            fb.setInitialText("Check out this cool app \(url)")
            self.presentViewController(fb, animated: true, completion: nil)
        } else {
            Utilities.alertError("Facebook isn't enabled!", vc: self.navigationController!)
        }
    }
    
    func shareTwitter() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let twitter = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitter.setInitialText("Check out this cool app \(url)")
            self.presentViewController(twitter, animated: true, completion: nil)
        } else {
            Utilities.alertError("Twitter isn't enabled!", vc: self.navigationController!)
        }
    }
    
    func shareEmail() {
        if(MFMailComposeViewController.canSendMail()) {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("Cool app")
            self.presentViewController(mail, animated: true, completion: nil)
        }
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
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
