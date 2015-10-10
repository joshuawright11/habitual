//
//  HomeTableViewController.swift
//  Habitual
//
//  Created by Josh Wright on 7/10/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit
import Timepiece
import DZNEmptyDataSet

class HabitTableViewController: UITableViewController, UIGestureRecognizerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var habits:[Habit] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        habits = AuthManager.currentUser!.habits
     
        Utilities.registerForNotification(self, selector: "refreshData", name: kNotificationIdentifierHabitAddedOrDeleted)
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 1.0
        lpgr.delegate = self

        self.tableView.addGestureRecognizer(lpgr)

        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.reloadData()
    }
    
    func refreshData(){
        habits = AuthManager.reloadHabits()!
        self.tableView.reloadData()
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer){

        if gestureRecognizer.state == UIGestureRecognizerState.Began{

            let point = gestureRecognizer.locationInView(self.tableView)
            if let ip = self.tableView.indexPathForRowAtPoint(point){

                if !habits[ip.row].canDo() {return}
                habits[ip.row].datesCompleted.append(NSDate())
                self.tableView.cellForRowAtIndexPath(ip)?.accessoryType = UITableViewCellAccessoryType.Checkmark
                
                Utilities.postNotification(kNotificationIdentifierHabitDataChanged)
            }
        }
    }
    
    @IBAction func clearData(){
        AuthManager.clearHabitsOfCurrentUser()
        self.refreshData()
        Utilities.postNotification(kNotificationIdentifierHabitDataChanged)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("habit", forIndexPath: indexPath) 
        
        let habit = habits[indexPath.row]
        
        cell.textLabel?.text = habit.name
        
        cell.accessoryType = !habit.canDo() ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let hdvc:HabitDetailController = storyboard?.instantiateViewControllerWithIdentifier("HabitDetail") as! HabitDetailController
        hdvc.habit = habits[indexPath.row]
        self.navigationController?.pushViewController(hdvc, animated: true)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return habits.count > 0 ? "Press and Hold to Complete a Habit" : ""
    }
    
    // MARK: - View Controller methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is HabitDetailController {
            let vc = segue.destinationViewController as! HabitDetailController
            if let indexPath = tableView.indexPathForSelectedRow{
                vc.habit = habits[indexPath.row]
            }
        }
    }
    
    // MARK: - Empty data set data source
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.groupTableViewBackgroundColor()
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Press to add a Habit!"
        
        let font = UIFont.boldSystemFontOfSize(22.0)
        let attrString = NSAttributedString(
            string: text,
            attributes: NSDictionary(
                object: font,
                forKey: NSFontAttributeName) as? [String : AnyObject])
        
        return attrString
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "You have no habits!"
        
        let font = UIFont.systemFontOfSize(18.0)
        let attrString = NSAttributedString(
            string: text,
            attributes: NSDictionary(
                object: font,
                forKey: NSFontAttributeName) as? [String : AnyObject])
        
        return attrString
    }
    
    // MARK: - Empty data set delegate
    
    func emptyDataSetDidTapView(scrollView: UIScrollView!) {
        // TODO: add a habit
    }
}
