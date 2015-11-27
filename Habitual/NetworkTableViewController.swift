//
//  NetworkTableViewController.swift
//  Habitual
//
//  Created by Josh Wright on 7/20/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import Parse

class NetworkTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{

    var connections:[Connection]?{
        didSet{tableView.reloadData()}
    }
    
    var loggedIn:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doAppearance()
        
        Utilities.registerForNotification(self, selector: "refreshData", name: kNotificationIdentifierReloadConnections)
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.registerNib(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "user")
        
        self.navigationItem.title = "Connections"
        
        if (PFUser.currentUser() != nil){
            
            let button = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Plain, target: self, action:"addConnection")
            self.navigationItem.rightBarButtonItem = button
            
            loggedIn = true
            self.connections = AuthManager.currentUser?.connections
            self.tableView.reloadData()
        }
        
        Utilities.registerForNotification(self, selector: "refreshData", name: kNotificationIdentifierReloadConnections)
    }
    
    func doAppearance() {
        self.tableView.backgroundColor = kColorBackground
    }
    
    func refreshData(){
        loggedIn = true
        
        let button = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Plain, target: self, action:"addConnection")
        self.navigationItem.rightBarButtonItem = button
        
        AuthManager.currentUser?.getConnections() { (success) -> () in
            if success {
                self.connections = AuthManager.currentUser?.connections
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func addConnection() {
        let alert = UIAlertController(title: "Follow a user", message: "enter their username", preferredStyle: UIAlertControllerStyle.Alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Follow", style: UIAlertActionStyle.Default) { (_) in
            let usernameTextField = alert.textFields! [0] 
                AuthManager.currentUser?.addConnection(usernameTextField.text!, callback: { (success) -> () in
                    if success {
                        self.connections = AuthManager.currentUser?.connections
                        Utilities.alert("User followed", vc: self)
                    }else{
                        Utilities.alert("User not found", vc: self)
                    }
                })
            })
        
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "username"
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Empty data set delegate
    
    func emptyDataSetDidTapView(scrollView: UIScrollView!) {
        
        if loggedIn {
            addConnection()
        }else{
            let svc:UINavigationController = storyboard!.instantiateViewControllerWithIdentifier("signup") as! UINavigationController
            
            presentViewController(svc, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let connections = connections {
            return connections.count
        }else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("user") as! UserCell
        cell.configure(connections![indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 99
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let connection = connections![indexPath.row]
        
        if(!connection.approved) {return}
        
        let ccvc = storyboard?.instantiateViewControllerWithIdentifier("Chat") as! ConnectionChatViewController
        ccvc.connection = connections![indexPath.row]
        navigationController?.pushViewController(ccvc, animated: true)
    }

    // MARK: - Empty data set data source
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return kColorBackground
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = loggedIn ? "Press to add a connection!" : "Press to sign up or log in"
        
        let font = UIFont.boldSystemFontOfSize(22.0)
        let attrString = NSAttributedString(
            string: text,
            attributes: NSDictionary(
                object: font,
                forKey: NSFontAttributeName) as? [String : AnyObject])
        
        return attrString
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = loggedIn ? "You have no friends :'(" : "It takes 10-30 seconds depending on how fast you type. Josh can do it in 7."
        
        let font = UIFont.systemFontOfSize(18.0)
        let attrString = NSAttributedString(
            string: text,
            attributes: NSDictionary(
                object: font,
                forKey: NSFontAttributeName) as? [String : AnyObject])
        
        return attrString
    }

}
