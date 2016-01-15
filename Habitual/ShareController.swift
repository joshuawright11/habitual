//
//  ShareController.swift
//  Ignite
//
//  Created by Josh Wright on 12/29/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import SwiftAddressBook

class ShareController: UIViewController, UITableViewDataSource, UITableViewDelegate {

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
            Styler.viewShaderSmall(contactsView)
            contactsView.layer.shadowOpacity = 0
            setupListener(contactsView)
        }
    }
    
    @IBOutlet weak var inviteView: UIView! {
        didSet {
            inviteView.layer.cornerRadius = 7
            inviteView.backgroundColor = Colors.barBackground
            Styler.viewShaderSmall(inviteView)
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
        }
    }
    
    private var selectedView: UIView!
    
    private var fbFriends: [SocialMediaUser] = []
    private var contacts: [SocialMediaUser] = []
    
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
                self.fbFriends = []
                for friend in friends {
                    let su = SocialMediaUser(fbjson: friend as! NSDictionary)
                    self.fbFriends.append(su)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func getContactsUsers() {
        swiftAddressBook?.requestAccessWithCompletion({ (success, error) -> Void in
            if success {
                if let people = swiftAddressBook?.allPeople {
                    var emailList:[String] = []
                    for person in people {
                        let emails = person.emails?.map({$0.value})
                        if let emails = emails {
                            for email in emails {
                                emailList.append(email)
                            }
                        }
                    }
                    /// parse query email list
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
            return 3
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("social", forIndexPath: indexPath) as! SocialUserCell
        if selectedView == fbView {
            cell.user = fbFriends[indexPath.row]
        } else if selectedView == contactsView {
            cell.user = contacts[indexPath.row]
        } else {}
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 73
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if selectedView == fbView {
            return "Facebook friends on Ignite"
        } else if selectedView == contactsView {
            return "Address book contacts on Ignite"
        } else {
            return "Invite a friend to use Ignite!"
        }
    }

}
