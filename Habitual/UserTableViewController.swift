//
//  MeTableViewController.swift
//  Habitual
//
//  Created by Josh Wright on 7/20/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController {

    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "HabitCell", bundle: nil), forCellReuseIdentifier: "habit")
        Utilities.registerForNotification(self, selector: "refreshData", name: kNotificationIdentifierHabitDataChanged)
        
        if user == nil{user = AuthManager.currentUser; self.navigationItem.title = "Me"}
        else {self.navigationItem.title = user?.username}
        tableView.reloadData()
    }

    func refreshData(){
        tableView.reloadData()
    }
    
    func statForIndex(index: Int) -> (String, String){
        if(index == 0){
            return ("Habits completed","\(user!.statHabitsCompleted())")
        }else if(index == 1){
            return ("Longest streak","\(user!.statLongestStreak())")
        }else{
            return ("Most completed habit",user!.statMostCompletedHabit())
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return user!.habits.count > 0 ? 2 : 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if let user = user {
                return user.habits.count
            }else{
                return 0
            }
        }else{
            return 3
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("habit", forIndexPath: indexPath) as! HabitCell
        
            cell.configureForHabit(user!.habits[indexPath.row])
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("stat")! as UITableViewCell
            
            let statTuple = statForIndex(indexPath.row)
            
            cell.textLabel?.text = statTuple.0
            cell.detailTextLabel?.text = statTuple.1
            
            return cell
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if(section == 0){
            return "Stats"
        }else{
            return "Habits"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
