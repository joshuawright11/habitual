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

// -TODO: Needs refactoring/documentation

class NetworkController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, ServiceObserver {

    var connectionService: ConnectionService! {
        didSet {
            connectionService.addConnectionServiceObserver(self)
        }
    }
    
    var accountService: AccountService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = Colors.background
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        self.tableView.registerNib(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "user")
        self.tableView.reloadData()
        
        let button = UIBarButtonItem(image: UIImage(named: "plus"), style: .Plain, target: self, action: #selector(NetworkController.addConnection))
        self.navigationItem.rightBarButtonItem = button
        self.navigationItem.title = "Connections"
        Styler.navBarShader(self)
    }
    
    @IBAction func addConnection() {
        let alert = SCLAlertView()
        alert.buttonCornerRadius = 5
        alert.contentViewCornerRadius = 10
        alert.fieldCornerRadius = 5
        
        let txt = alert.addTextField("Email")

        txt.autocapitalizationType = .None
        txt.autocorrectionType = .No
        txt.backgroundColor = Colors.barBackground
        txt.textColor = Colors.textMain
        txt.attributedPlaceholder =
            NSAttributedString(string: "email", attributes: [NSForegroundColorAttributeName : Colors.textSubtitle])
        
        alert.showCloseButton = true
        alert.addButton("Request Connection") {
            let text = txt.text!
            do {
                try self.connectionService.connectWith(text) { (success) in
                    if success {
                        Utilities.alertSuccess("Connection request sent", vc: self.navigationController!)
                    }else{
                        Utilities.alertError("User not found", vc: self.navigationController!)
                    }
                }
            } catch ConnectionServiceError.AlreadyConnected {
                Utilities.alertError("You're already connected to that user!", vc: self.navigationController!)
            } catch {
                Utilities.alertError("You can't connect to yourself!", vc: self.navigationController!)
            }
        }
        
        alert.addButton("Find Friends") { () -> Void in
            let sc = ShareController(nibName: "ShareController", bundle: nil)
            sc.connectionService = self.connectionService
            let nav = UINavigationController(rootViewController: sc)
            self.presentViewController(nav, animated: true, completion: nil)
        }
        
        alert.showEdit("Add Connection", subTitle: "Request a connection with someone with their email.", closeButtonTitle: "Close", colorStyle: 0xC644FC, colorTextButton: 0xffffff)
    }
    
    
}

// MARK: - Table view data sources
extension NetworkController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectionService.connections.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("user") as! UserCell

        let connection = connectionService.connections[indexPath.row]
        cell.configure(connectionService, connection: connection)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let user = connectionService.otherUser(connectionService.connections[indexPath.row])
        var numFinished = user.habits.filter({$0.completed()}).count
        var numUnfinished = user.habits.count - numFinished
        
        if !connectionService.connections[indexPath.row].approved {
            numFinished = 0
            numUnfinished = 0
        }
        
        let height = UserCell.height + (CGFloat(max(numFinished, numUnfinished)) * HabitGlanceCell.height)
        
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if connectionService.connections[indexPath.row].approved {
            let uvc = storyboard?.instantiateViewControllerWithIdentifier("User") as! UserController
            let connection = connectionService.connections[indexPath.row]
            uvc.habits = connectionService.otherUser(connection).habits
            uvc.color = connection.color
            uvc.connection = connection
            uvc.accountService = accountService
            uvc.connectionService = connectionService
            
            self.navigationController?.pushViewController(uvc, animated: true)
        }
    }
}

// MARK: - Empty data set data source
extension NetworkController{
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
    
    func serviceDidUpdate() {
        self.tableView.reloadData()
    }
}

// MARK: - Empty data set delegate
extension NetworkController {
    func emptyDataSetDidTapView(scrollView: UIScrollView!) {
        addConnection()
    }
}
