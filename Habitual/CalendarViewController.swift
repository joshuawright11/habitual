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
import Parse
import MCSwipeTableViewCell
import CVCalendar

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    var habits:[Habit] = []
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        habits = AuthManager.currentUser!.habits
     
        Utilities.registerForNotification(self, selector: "refreshData", name: kNotificationIdentifierHabitAddedOrDeleted)
        
//        let lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
//        lpgr.minimumPressDuration = 1.0
//        lpgr.delegate = self
//        self.tableView.addGestureRecognizer(lpgr)

        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
    
    func refreshData(){
        habits = AuthManager.reloadHabits()!
        self.tableView.reloadData()
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer){

        if gestureRecognizer.state == UIGestureRecognizerState.Began{

            let point = gestureRecognizer.locationInView(self.tableView)
            if let ip = self.tableView.indexPathForRowAtPoint(point){

                let habit: Habit = habits[ip.row]
                
                if !habit.canDo() {return}
                habit.datesCompleted.append(NSDate())
                self.tableView.cellForRowAtIndexPath(ip)?.accessoryType = UITableViewCellAccessoryType.Checkmark
                
                if habit.notificationsEnabled {
                    ForeignNotificationManager.completeHabitForCurrentUser(habit)
                }
                
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:MCSwipeTableViewCell? = tableView.dequeueReusableCellWithIdentifier("habit") as? MCSwipeTableViewCell
        
        if (cell == nil) {
            cell = MCSwipeTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "habit")
        
            if cell!.respondsToSelector("setSeparatorInset:") {
                cell?.separatorInset = UIEdgeInsetsZero
            }
            
        }
        
        cell?.defaultColor = UIColor.groupTableViewBackgroundColor()
        
        cell?.setSwipeGestureWithView(UIView(), color: UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0), mode: MCSwipeTableViewCellMode.Switch, state: MCSwipeTableViewCellState.State1, completionBlock:
        { (cell : MCSwipeTableViewCell!, state: MCSwipeTableViewCellState, mode: MCSwipeTableViewCellMode) in
            
            let ip = self.tableView.indexPathForCell(cell)!
            
            let habit: Habit = self.habits[ip.row]
            
            if !habit.canDo() {return}
            habit.datesCompleted.append(NSDate())
            self.tableView.cellForRowAtIndexPath(ip)?.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            if habit.notificationsEnabled {
                ForeignNotificationManager.completeHabitForCurrentUser(habit)
            }
            
            Utilities.postNotification(kNotificationIdentifierHabitDataChanged)
            
        })
        
        cell?.setSwipeGestureWithView(UIView(), color: UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0), mode: MCSwipeTableViewCellMode.Switch, state: MCSwipeTableViewCellState.State3, completionBlock:
            { (cell : MCSwipeTableViewCell!, state: MCSwipeTableViewCellState, mode: MCSwipeTableViewCellMode) in print("NOT COMPLETED");
        })
        
        let habit = habits[indexPath.row]
        
        cell?.textLabel?.text = habit.name
        
        cell!.accessoryType = !habit.canDo() ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let hdvc:HabitDetailController = storyboard?.instantiateViewControllerWithIdentifier("HabitDetail") as! HabitDetailController
        hdvc.habit = habits[indexPath.row]
        self.navigationController?.pushViewController(hdvc, animated: true)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return habits.count > 0 ? "Swipe to Complete a Habit" : ""
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
    
    // MARK: - CVCalendarViewDelegate methods
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    func firstWeekday() -> Weekday {
        return .Sunday
    }
}
