//
//  HomeTableViewController.swift
//  Habitual
//
//  Created by Josh Wright on 7/10/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var habits:[Habit] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        habits = AuthManager.currentUser!.habits
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshData", name: kNotificationIdentifierRefreshHome, object: nil)
     
        var lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 1.0
        lpgr.delegate = self

        self.tableView.addGestureRecognizer(lpgr)
        self.tableView.reloadData()
    }
    
    func refreshData(){
        habits = AuthManager.currentUser!.habits
        self.tableView.reloadData()
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer){

        if gestureRecognizer.state == UIGestureRecognizerState.Began{

            let point = gestureRecognizer.locationInView(self.tableView)
            if let ip = self.tableView.indexPathForRowAtPoint(point){
                moreInfo(habits[ip.row])
            }
        }
    }
    
    func moreInfo(habit: Habit){
        habit.datesCompleted.append(NSDate())
    }
    
    @IBAction func clearData(){
        AuthManager.clearHabitsOfCurrentUser()
        self.refreshData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("habit", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = habits[indexPath.row].name

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var hdvc:HabitDetailController = storyboard?.instantiateViewControllerWithIdentifier("HabitDetail") as! HabitDetailController
        hdvc.habit = habits[indexPath.row]
        self.navigationController?.pushViewController(hdvc, animated: true)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Press and hold to complete!"
    }
    
    // MARK: - View Controller methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is HabitDetailController {
            let vc = segue.destinationViewController as! HabitDetailController
            if let indexPath = tableView.indexPathForSelectedRow(){
                vc.habit = habits[indexPath.row]
            }
        }
    }
}
