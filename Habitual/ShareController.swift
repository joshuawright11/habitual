//
//  ShareController.swift
//  Ignite
//
//  Created by Josh Wright on 12/29/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import SwiftAddressBook
import MessageUI
import Social

class ShareController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {

    let url = "https://itunes.apple.com/us/app/ignite-habit-tracker-accountability/id1049840265?ls=1&mt=8"
    
    @IBOutlet weak var fbiv: UIImageView! {
        didSet {
            fbiv.image = UIImage(named: "facebook_outline")?.imageWithRenderingMode(.AlwaysTemplate)
            fbiv.tintColor = Colors.barBackground
        }
    }
    
    @IBOutlet weak var contactsiv: UIImageView! {
        didSet {
            contactsiv.image = UIImage(named: "email_contacts_outline")?.imageWithRenderingMode(.AlwaysTemplate)
            contactsiv.tintColor = Colors.orange
        }
    }
    
    @IBOutlet weak var inviteiv: UIImageView! {
        didSet {
            inviteiv.image = UIImage(named: "user_plus")?.imageWithRenderingMode(.AlwaysTemplate)
            inviteiv.tintColor = Colors.accentSecondary
        }
    }
    
    @IBOutlet weak var fbView: UIView! {
        didSet {
            fbView.layer.cornerRadius = 7
            fbView.backgroundColor = Colors.blue
            Styler.viewShader(fbView)
            setupListener(fbView)
            selectedView = fbView
        }
    }
    
    @IBOutlet weak var contactsView: UIView! {
        didSet {
            contactsView.layer.cornerRadius = 7
            contactsView.backgroundColor = Colors.barBackground
            Styler.viewShader(contactsView)
            contactsView.layer.shadowOpacity = 0
            setupListener(contactsView)
        }
    }
    
    @IBOutlet weak var inviteView: UIView! {
        didSet {
            inviteView.layer.cornerRadius = 7
            inviteView.backgroundColor = Colors.barBackground
            Styler.viewShader(inviteView)
            inviteView.layer.shadowOpacity = 0
            setupListener(inviteView)
        }
    }
    
    @IBOutlet weak var headerView: UIView! {
        didSet {
            headerView.backgroundColor = Colors.barBackground
            Styler.viewBottomShader(headerView)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.backgroundColor = Colors.background
            tableView.registerNib(UINib(nibName: "SettingsCell", bundle: nil), forCellReuseIdentifier: SettingsCell.reuseIdentifier)
        }
    }
    
    private var selectedView: UIView!
    
    private var fbFriends: [User] = []
    private var contacts: [User] = []
    
    func setupListener(view: UIView) {
        let gr = UITapGestureRecognizer(target: self, action: "tapped:")
        view.addGestureRecognizer(gr)
    }
    
    func tapped(sender: UITapGestureRecognizer) {
        if sender.view == fbView && selectedView != fbView {
            clearSelectedView()
            fbView.layer.shadowOpacity = 0.4
            fbiv.tintColor = Colors.barBackground
            fbView.backgroundColor = Colors.blue
            selectedView = fbView
            tableView.reloadData()
        } else if sender.view == contactsView && selectedView != contactsView {
            clearSelectedView()
            contactsView.layer.shadowOpacity = 0.4
            contactsiv.tintColor = Colors.barBackground
            contactsView.backgroundColor = Colors.orange
            selectedView = contactsView
            tableView.reloadData()
        } else if sender.view == inviteView && selectedView != inviteView {
            clearSelectedView()
            inviteView.layer.shadowOpacity = 0.4
            inviteView.backgroundColor = Colors.accentSecondary
            inviteiv.tintColor = Colors.barBackground
            selectedView = inviteView
            tableView.reloadData()
        }
    }
    
    func clearSelectedView() {
        selectedView.layer.shadowOpacity = 0
        selectedView.backgroundColor = Colors.barBackground
        if selectedView == fbView {
            fbiv.tintColor = Colors.blue
        } else if selectedView == contactsView {
            contactsiv.tintColor = Colors.orange
        } else if selectedView == inviteView {
            inviteiv.tintColor = Colors.accentSecondary
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Find Friends"
        let button = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel")
        self.navigationItem.leftBarButtonItem = button
        
        self.tableView.registerNib(UINib(nibName: "SocialUserCell", bundle: nil), forCellReuseIdentifier: "social")
        
        getFacebookUsers()
        getContactsUsers()
    }
    
    func getFacebookUsers() {
        let req = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields":"id, email, first_name, last_name, picture"])
        req.startWithCompletionHandler { (connection, result, error) -> Void in
            if error != nil {
                print("\(error.localizedDescription)")
            } else if result != nil {
                
                let friends = result["data"] as! NSArray
                var ids: [String] = []
                for friend in friends {
                    if let id = friend["id"] as? String {
                        ids.append(id)
                    }
                }
                
                WebServices.getFBFriends(ids, callback: { (success, users) -> () in
                    if success {
                        self.fbFriends = users
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    func getContactsUsers() {
        SwiftAddressBook.requestAccessWithCompletion({ (success, error) -> Void in
            if success {
                if let people = swiftAddressBook?.allPeople {
                    var emailList:[String] = []
                    for person in people {
                        let emails = person.emails?.map({$0.value})
                        if let emails = emails {
                            for email in emails {
                                if email != AuthManager.currentUser!.parseObject!["email"] as! String {
                                    emailList.append(email)
                                }
                            }
                        }
                    }
                    
                    WebServices.getContacts(emailList, callback: { (success, users) -> () in
                        if success {
                            self.contacts = users
                        }
                    })
                }
                
            } else {
                print("boo :(")
            }
        })
    }

    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedView === fbView {
            return fbFriends.count
        } else if selectedView === contactsView {
            return contacts.count
        } else if selectedView === inviteView {
            return 4
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if selectedView == fbView {
            let cell = tableView.dequeueReusableCellWithIdentifier("social", forIndexPath: indexPath) as! SocialUserCell
            cell.user = fbFriends[indexPath.row]
            cell.color = Colors.rainbow[indexPath.row%Colors.rainbow.count]
            return cell
        } else if selectedView == contactsView {
            let cell = tableView.dequeueReusableCellWithIdentifier("social", forIndexPath: indexPath) as! SocialUserCell
            cell.user = contacts[indexPath.row]
            cell.color = Colors.rainbow[indexPath.row%Colors.rainbow.count]
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(SettingsCell.reuseIdentifier, forIndexPath: indexPath) as! SettingsCell
            configureSettingsCell(cell, row: indexPath.row)
            return cell
        }
    }
    
    func configureSettingsCell(cell: SettingsCell, row: Int) {
        switch row {
        case 0:
            cell.iv?.image = UIImage(named: "facebook")?.imageWithRenderingMode(.AlwaysTemplate)
            cell.iv?.tintColor = Colors.blue
            cell.borderView.backgroundColor = Colors.blue.igniteDarken().lightenColor(0.07)
            cell.titleLabel.text = "Share on Facebook"
        case 1:
            cell.iv?.image = UIImage(named: "twitter")?.imageWithRenderingMode(.AlwaysTemplate)
            cell.iv?.tintColor = Colors.accentSecondary
            cell.borderView.backgroundColor = Colors.accentSecondary.igniteDarken().lightenColor(0.07)
            cell.titleLabel.text = "Share on Twitter"
        case 2:
            cell.iv?.image = UIImage(named: "email_contacts_outline")?.imageWithRenderingMode(.AlwaysTemplate)
            cell.iv?.tintColor = Colors.orange
            cell.borderView.backgroundColor = Colors.orange.igniteDarken().lightenColor(0.07)
            cell.titleLabel.text = "Invite a Friend via Email"
        case 3:
            cell.iv?.image = UIImage(named: "chats")?.imageWithRenderingMode(.AlwaysTemplate)
            cell.iv?.tintColor = Colors.purple
            cell.borderView.backgroundColor = Colors.purple.igniteDarken().lightenColor(0.07)
            cell.titleLabel.text = "Invite a Friend via Text"
        default: return
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if selectedView == inviteView {
            return 52
        } else {
            return 73
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if selectedView == fbView {
            return "Facebook friends on Ignite"
        } else if selectedView == contactsView {
            return "Address book contacts on Ignite"
        } else {
            return "Invite friends to use Ignite!"
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedView == inviteView {
            switch indexPath.row {
            case 0: shareFacebook()
            case 1: shareTwitter()
            case 2: shareEmail()
            case 3: shareText()
            default: return
            }
        }
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
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
