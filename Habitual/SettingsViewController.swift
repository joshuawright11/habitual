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

    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationsLabel: UILabel!
    
    @IBOutlet weak var appleiv: UIImageView!
    @IBOutlet weak var textiv: UIImageView!
    @IBOutlet weak var fbiv: UIImageView!
    @IBOutlet weak var twitteriv: UIImageView!
    @IBOutlet weak var mailiv: UIImageView!
    
    let url = "https://itunes.apple.com/us/app/ignite-habit-tracker-accountability/id1049840265?ls=1&mt=8"
    
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
        
        appleiv.image = appleiv.image?.imageWithRenderingMode(.AlwaysTemplate)
        textiv.image = textiv.image?.imageWithRenderingMode(.AlwaysTemplate)
        fbiv.image = fbiv.image?.imageWithRenderingMode(.AlwaysTemplate)
        twitteriv.image = twitteriv.image?.imageWithRenderingMode(.AlwaysTemplate)
        mailiv.image = mailiv.image?.imageWithRenderingMode(.AlwaysTemplate)
        
        appleiv.tintColor = Colors.gray
        textiv.tintColor = Colors.green
        fbiv.tintColor = Colors.blue
        twitteriv.tintColor = Colors.accentSecondary
        mailiv.tintColor = Colors.orange
    }
    
    func pulse() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.textLabel!.font = Fonts.cellTitle
        cell.textLabel!.textColor = Colors.textMain
        return cell
    }
    
    @IBAction func notificationSwitchToggled(sender: UISwitch) {
        Utilities.writeUserDefaults(Notifications.localNotificationsDisabled, bool: !sender.on)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 1: submitFeedBack()
        case 2: switch indexPath.row {
            case 0: rateOnAppStore()
            case 1: shareFacebook()
            case 2: shareTwitter()
            case 3: shareEmail()
            case 4: shareText()
            default: shareText()
            }
        default: break
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
