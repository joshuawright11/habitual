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

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, CVCalendarViewDelegate, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate {
    
    var habits: [Habit] = []
    
    var habitsOfDate: [Habit] {
        get{
            return habits.filter({$0.createdAt < selectedDate.endOfDay})
        }
        set{
            self.habitsOfDate = newValue
        }
    }
    
    var selectedDate: NSDate = NSDate()
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        habits = AuthManager.currentUser!.habits
     
        Utilities.registerForNotification(self, selector: "refreshData", name: kNotificationIdentifierHabitAddedOrDeleted)
        
        let months = ["January","February","March","April",
            "May","June","July","August","September","October",
            "November","December"]
        self.monthLabel.text = months[selectedDate.month-1]
        
        self.calendarView.changeDaysOutShowingState(false)
        
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
        return habitsOfDate.count
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
        
        let habit = habitsOfDate[indexPath.row]
        
        cell?.textLabel?.text = habit.name
        
        cell!.accessoryType = habit.completedOn(selectedDate) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        
        if(selectedDate.beginningOfDay > NSDate()) {
            return cell!
        }
        
        cell?.setSwipeGestureWithView(UIView(), color: UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0), mode: MCSwipeTableViewCellMode.Switch, state: MCSwipeTableViewCellState.State1, completionBlock:
        { (cell : MCSwipeTableViewCell!, state: MCSwipeTableViewCellState, mode: MCSwipeTableViewCellMode) in
            
            let ip = self.tableView.indexPathForCell(cell)!
            
            let habit: Habit = self.habitsOfDate[ip.row]
            
            if habit.completedOn(self.selectedDate) {return}
            habit.datesCompleted.append(self.selectedDate)
            self.tableView.cellForRowAtIndexPath(ip)?.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            if habit.notificationsEnabled && habit.dateInCurrentFrequency(self.selectedDate) {
                ForeignNotificationManager.completeHabitForCurrentUser(habit)
            }
            
            Utilities.postNotification(kNotificationIdentifierHabitDataChanged)
            
        })
        
        cell?.setSwipeGestureWithView(UIView(), color: UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0), mode: MCSwipeTableViewCellMode.Switch, state: MCSwipeTableViewCellState.State3, completionBlock:
            { (cell : MCSwipeTableViewCell!, state: MCSwipeTableViewCellState, mode: MCSwipeTableViewCellMode) in
                
                let ip = self.tableView.indexPathForCell(cell)!
                
                let habit: Habit = self.habitsOfDate[ip.row]
                
                if !habit.completedOn(self.selectedDate) {return}
                habit.uncompleteOn(self.selectedDate)
                self.tableView.cellForRowAtIndexPath(ip)?.accessoryType = UITableViewCellAccessoryType.None
                
                if habit.notificationsEnabled && habit.canDo() {
                    ForeignNotificationManager.uncompleteHabitForCurrentUser(habit)
                }
                
                Utilities.postNotification(kNotificationIdentifierHabitDataChanged)
                
        })
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let hdvc:HabitDetailController = storyboard?.instantiateViewControllerWithIdentifier("HabitDetail") as! HabitDetailController
        hdvc.habit = habitsOfDate[indexPath.row]
        self.navigationController?.pushViewController(hdvc, animated: true)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        
        return habitsOfDate.count > 0 ? dateFormatter.stringFromDate(selectedDate) : ""
    }
    
    // MARK: - View Controller methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is HabitDetailController {
            let vc = segue.destinationViewController as! HabitDetailController
            if let indexPath = tableView.indexPathForSelectedRow{
                vc.habit = habitsOfDate[indexPath.row]
            }
        }
    }
    
    // MARK: - Empty data set data source
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.groupTableViewBackgroundColor()
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No Habits today!"
        
        let font = UIFont.boldSystemFontOfSize(22.0)
        let attrString = NSAttributedString(
            string: text,
            attributes: NSDictionary(
                object: font,
                forKey: NSFontAttributeName) as? [String : AnyObject])
        
        return attrString
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Press to add a habit."
        
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
    
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    
    func presentedDateUpdated(date: Date) {
        struct Months {
            static let months = ["January","February","March","April",
                "May","June","July","August","September","October",
                "November","December"]
        }
        
        self.monthLabel.text = Months.months[(date.convertedDate()?.month)!-1]
    }
    
    func didSelectDayView(dayView: DayView) {
        self.selectedDate = dayView.date.convertedDate()!
        self.tableView.reloadData()
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
    
}
