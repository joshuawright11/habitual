//
//  MeTableViewController.swift
//  Habitual
//
//  Created by Josh Wright on 7/20/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit

class MeTableViewController: UITableViewController {

    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "HabitCell", bundle: nil), forCellReuseIdentifier: "habit")
        registerForNotification(self, "refreshData", kNotificationIdentifierHabitDataChanged)
        
        user = AuthManager.currentUser
        tableView.reloadData()
    }

    func refreshData(){
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if let user = user {
            return user.habits.count
        }else{
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("habit", forIndexPath: indexPath) as! HabitCell
        
        cell.configureForHabit(user!.habits[indexPath.row])

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Habits"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
