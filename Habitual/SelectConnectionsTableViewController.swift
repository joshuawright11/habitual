//
//  SelectConnectionsTableViewController.swift
//  Habitual
//
//  Created by Josh Wright on 10/10/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class SelectConnectionsTableViewController: UITableViewController {

    static let reuseIdentifier = "ContactCell"
    
    var users:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AuthManager.currentUser!.following.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(SelectConnectionsTableViewController.reuseIdentifier, forIndexPath: indexPath)
        
        cell.textLabel?.text = AuthManager.currentUser!.following[indexPath.row].username

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        if(cell?.accessoryType == .Checkmark){
            cell?.accessoryType = .None
            users.removeAtIndex(users.indexOf((cell?.textLabel?.text)!)!)
        }else{
            cell?.accessoryType = .Checkmark
            users.append((cell?.textLabel?.text)!)
        }
    }

}
