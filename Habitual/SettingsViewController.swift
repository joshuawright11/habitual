//
//  SettingsViewController.swift
//  Ignite
//
//  Created by Josh Wright on 11/17/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var appBadgeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doAppearance()
    }
    
    func doAppearance() {
        self.tableView.backgroundColor = kColorBackground
        notificationsLabel.font = kFontCellTitle
        appBadgeLabel.font = kFontCellTitle
        notificationsLabel.textColor = kColorTextMain
        appBadgeLabel.textColor = kColorTextMain
        
        let button = UIBarButtonItem(title: "Pulse", style: .Plain, target: self, action: "pulse")
        self.navigationItem.rightBarButtonItem = button
    }
    
    func pulse() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.textLabel!.font = kFontCellTitle
        cell.textLabel!.textColor = kColorTextMain
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0: shareTwitter()
            case 1: shareFacebook()
            default: shareText()
            }
        case 2:
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
        
    }
    
    func rateOnAppStore() {
        
    }
}
