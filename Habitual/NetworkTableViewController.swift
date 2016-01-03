//
//  NetworkTableViewController.swift
//  Habitual
//
//  Created by Josh Wright on 7/20/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SCLAlertView
import Parse

// -TODO: Needs refactoring/documentation

class NetworkTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{

    var connections:[Connection]?{
        didSet{tableView.reloadData()}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doAppearance()
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.registerNib(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "user")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        
        self.navigationItem.title = "Connections"
        
        let button = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addConnection")
        self.navigationItem.rightBarButtonItem = button
        
        self.connections = AuthManager.currentUser!.connections
        self.tableView.reloadData()
        
        if (PFUser.currentUser()!["paymentDue"] as! NSDate) < NSDate() {
            button.enabled = false
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refreshData", forControlEvents: .ValueChanged)
        
        Utilities.registerForNotification(self, selector: "refreshData", name: Notifications.reloadNetworkOnline)
        
        Utilities.registerForNotification(self, selector: "refreshDataOffline", name: Notifications.reloadNetworkOffline)
        
        Utilities.registerForNotification(self, selector: "refreshData", name: Notifications.reloadChat)
    }
    
    func doAppearance() {
        self.tableView.backgroundColor = Colors.background
        
        Styler.navBarShader(self)
    }
    
    func refreshData(){
        self.navigationItem.rightBarButtonItem?.enabled = true
        AuthManager.currentUser?.getConnections() { (success) -> () in
            if success {
                self.connections = AuthManager.currentUser?.connections
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    func refreshDataOffline() {
        self.tableView.reloadData()
    }
    
    @IBAction func addConnection() {
        
        let sc = ShareController(nibName: "ShareController", bundle: nil)
        let nav = UINavigationController(rootViewController: sc)
        presentViewController(nav, animated: true, completion: nil)
        return
        
        let alert = SCLAlertView()
        let txt = alert.addTextField("username")

        txt.autocapitalizationType = .None
        txt.autocorrectionType = .No
        
        alert.showCloseButton = false
        alert.addButton("Request Connection") {
            
            let text = txt.text!
            
            if(self.alreadyConnected(text)){
                return
            }else{
                AuthManager.currentUser?.addConnection(txt.text!, callback: { (success) -> () in
                    if success {
                        self.connections = AuthManager.currentUser?.connections
                        Utilities.alertSuccess("Connection request sent", vc: self.navigationController!)
                    }else{
                        Utilities.alertError("User not found", vc: self.navigationController!)
                    }
                })
            }
        }
        alert.addButton("Cancel") { () -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.showEdit("Add Connection", subTitle: "Request a connection with a username. Yours is '\(PFUser.currentUser()!.username!)'.")
    }
    
    func alreadyConnected(string: String) -> Bool {
        
        let usernames = connections?.map({$0.user.username})
        
        if(usernames!.contains(string)) {
            Utilities.alertError("You are already connected with that user!", vc: self.navigationController!)
            return true
        }else if(AuthManager.currentUser?.username == string){
            Utilities.alertError("You can't connect with yourself!", vc: self.navigationController!)
            return true
        }else{
            return false
        }
    }
    
    // MARK: - Empty data set delegate
    
    func emptyDataSetDidTapView(scrollView: UIScrollView!) {
        
        if (PFUser.currentUser()!["paymentDue"] as! NSDate) < NSDate() {
            return
        }
        
        addConnection()
    }
    
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let connections = connections {
            
            if (PFUser.currentUser()!["paymentDue"] as! NSDate) < NSDate() {
                return 0
            }else{
                return connections.count
            }
        }else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("user") as! UserCell

        let connection = connections![indexPath.row]
        cell.configure(connection)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let user = connections![indexPath.row].user
        let numFinished = user.habits.filter({$0.completed()}).count
        let numUnfinished = user.habits.count - numFinished
        
        let height = UserCell.height + (CGFloat(max(numFinished, numUnfinished)) * HabitGlanceCell.height)
        
        return height
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
        return Colors.background
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage(named: "connections_empty")?.imageWithRenderingMode(.AlwaysTemplate)
        return image
    }
    
    func imageTintColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return Colors.accent
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text = "You aren't connected yet!"
        
        if(PFUser.currentUser()!["paymentDue"] as! NSDate) < NSDate(){
            text = "Your subscription is out, please renew at www.ignitehabits.io"
        }
        
        let font = Fonts.navTitle
        let attrString = NSAttributedString(
            string: text,
            attributes: NSDictionary(
                object: font,
                forKey: NSFontAttributeName) as? [String : AnyObject])
        
        return attrString
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Press to add a connection"
        
        let font = Fonts.cellTitle
        let attrString = NSAttributedString(
            string: text,
            attributes: NSDictionary(
                object: font,
                forKey: NSFontAttributeName) as? [String : AnyObject])
        
        return attrString
    }

}
