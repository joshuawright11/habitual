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
import CVCalendar

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, CVCalendarViewDelegate, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate {
    
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    
    var habits: [Habit] = []
    
    var habitsOfDate: [Habit] {
        get{
            return habits.filter({$0.availableOn(selectedDate)})
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
        
        self.navigationItem.title = "Habits"
        
        habits = AuthManager.currentUser!.habits
        
        Utilities.registerForNotification(self, selector: "refreshData", name: kNotificationIdentifierHabitAddedOrDeleted)
        
        self.monthLabel.text = Utilities.monthDayStringFromDate(selectedDate)
        self.calendarView.changeDaysOutShowingState(false)
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.reloadData()
        
        tableView.registerNib(UINib(nibName: "HabitHomeCell", bundle: nil), forCellReuseIdentifier: "habit")
        
        doAppearance()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.clearColor().CGColor
    }
    
    func doAppearance(){
        
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        
        Styler.viewBottomShader(calendarView)
        
        self.calendarView.backgroundColor = kColorBarBackground
        self.monthLabel.backgroundColor = kColorBarBackground
        self.menuView.backgroundColor = kColorBarBackground
        self.view.backgroundColor = kColorBackground
        self.tableView.backgroundColor = kColorBackground
        Styler.styleTitleLabel(self.monthLabel)
        monthLabel.textColor = kColorTextMain
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
    
    func refreshData(){
        habits = AuthManager.currentUser!.habits
        self.tableView.reloadData()
    }
    
    @IBAction func clearData(){
        CoreDataManager.clearHabitsOfCurrentUser()
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
        let habit = habitsOfDate[indexPath.row]
        
        var cell:HabitHomeCell? = tableView.dequeueReusableCellWithIdentifier("habit") as? HabitHomeCell
        
        if (cell == nil) {
            cell = HabitHomeCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "habit", habit: habit, date: self.selectedDate)
        
            if cell!.respondsToSelector("setSeparatorInset:") {
                cell?.separatorInset = UIEdgeInsetsZero
            }
        }else{ cell?.data = (habit, self.selectedDate) }
        
        cell?.configure()
        
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 89.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 20))
        header.textAlignment = .Center
        
        header.text = habitsOfDate.count > 0 ? "Swipe to complete" : ""
        header.font = kFontSectionHeaderBold
        header.textColor = kColorTextSecondary
        
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
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
        return kColorBackground
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No Habits today!"
        
        let font = kFontNavTitle
        let attrString = NSAttributedString(
            string: text,
            attributes: NSDictionary(
                object: font,
                forKey: NSFontAttributeName) as? [String : AnyObject])
        
        return attrString
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "habits_empty")
    }
    
    func imageTintColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return kColorAccent
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {

        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        
        let text = dateFormatter.stringFromDate(selectedDate)
        
        let font = kFontCellTitle
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
        return .WeekView
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
    }
    
    func didSelectDayView(dayView: DayView) {
        self.selectedDate = dayView.date.convertedDate()!
        self.monthLabel.text = Utilities.monthDayStringFromDate(selectedDate)
        self.tableView.reloadData()
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
    // MARK: - CVCalendarAppearanceDelegate methods
    func dayLabelWeekdayInTextColor() -> UIColor {
        return kColorAccent
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return kColorAccentSecondary
    }
    
    func dayLabelWeekdayHighlightedTextColor() -> UIColor {
        return kColorAccent
    }
    
    func dayLabelPresentWeekdayFont() -> UIFont {
        return kFontSecondary
    }
    
    func dayLabelWeekdayOutTextColor() -> UIColor {
        return kColorTextSecondary
    }
    
    func dayLabelWeekdayFont() -> UIFont {
        return kFontCalendar
    }
    
    func dayLabelPresentWeekdayTextColor() -> UIColor {
        return kColorAccentSecondary
    }
    
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor {
        return kColorAccentSecondary
    }
    
    func dayOfWeekTextColor() -> UIColor {
        return kColorTextMain
    }
    
    func dayOfWeekFont() -> UIFont {
        return kFontSecondary
    }
    
}
