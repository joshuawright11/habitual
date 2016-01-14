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

// -TODO: Needs refactoring/documentation

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, CVCalendarViewDelegate, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate {
    
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    
    var habits: [Habit] = [] {
        didSet {
            habitsOfDate = habits.filter({$0.availableOn(selectedDate)}).sort(
                { (firstHabit, secondHabit) -> Bool in
                    let first = firstHabit.canDoOn(selectedDate)
                    let second = secondHabit.canDoOn(selectedDate)
                    
                    if first && second {
                        return firstHabit.timeOfDay < secondHabit.timeOfDay
                    } else if first {
                        return true
                    } else if second {
                        return false
                    } else {
                        return firstHabit.timeOfDay < secondHabit.timeOfDay
                    }
            })
        }
    }
    
    var habitsOfDate: [Habit] = []
    
    var selectedDate: NSDate = NSDate() {
        didSet {
            habitsOfDate = habits.filter({$0.availableOn(selectedDate)}).sort(
                { (firstHabit, secondHabit) -> Bool in
                let first = firstHabit.canDoOn(selectedDate)
                let second = secondHabit.canDoOn(selectedDate)
                
                if first && second {
                    return firstHabit.timeOfDay < secondHabit.timeOfDay
                } else if first {
                    return true
                } else if second {
                    return false
                } else {
                    return firstHabit.timeOfDay < secondHabit.timeOfDay
                }
            })
        }
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var spacerView: UIView! {
        didSet {
            spacerView.backgroundColor = Colors.barBackground
            Styler.viewBottomShader(spacerView)
        }
    }
    
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Habits"
        
        Utilities.registerForNotification(self, selector: "refreshData", name: Notifications.habitDataChanged)
        
        Utilities.registerForNotification(self, selector: "moveCell:", name:
            Notifications.reloadPulse)
        
        self.calendarView.changeDaysOutShowingState(false)
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        
        refreshData()
        
        tableView.registerNib(UINib(nibName: "HabitHomeCell", bundle: nil), forCellReuseIdentifier: "habit")
        
        let dataButton = UIBarButtonItem(image: UIImage(named: "order")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: "order")
        navigationItem.leftBarButtonItem = dataButton
        
        let addButton = UIBarButtonItem(image: UIImage(named: "plus")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: "add")
        navigationItem.rightBarButtonItem = addButton
        
        doAppearance()
    }
    
    func order() {
        if self.tableView.editing {
            let temp = habits
            habits = temp
            self.calendarView.userInteractionEnabled = true
        } else {
            self.calendarView.userInteractionEnabled = false
            habitsOfDate = habits.sort({ (one, two) -> Bool in
                return one.timeOfDay < two.timeOfDay
            })
        }
        
        self.tableView.reloadData()
        self.tableView.setEditing(!self.tableView.editing, animated: true)
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let removed = habitsOfDate.removeAtIndex(sourceIndexPath.row)
        habitsOfDate.insert(removed, atIndex: destinationIndexPath.row)
        
        var count = 0
        for habit in habitsOfDate {
            habit.timeOfDay = count
            habit.coreDataObject?.timeOfDayInt = Int16(count)
            count += 1
            habit.saveOrder()
        }
        
        habitsOfDate = habits.sort({ (one, two) -> Bool in
            return one.timeOfDay < two.timeOfDay
        })
    }
    
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        return proposedDestinationIndexPath
    }
    
    func add() {
        let hdc = storyboard?.instantiateViewControllerWithIdentifier("HabitDetail")
        self.navigationController?.pushViewController(hdc!, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.clearColor().CGColor
    }
    
    func doAppearance(){
        
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        
        self.calendarView.backgroundColor = Colors.barBackground
        self.menuView.backgroundColor = Colors.barBackground
        self.view.backgroundColor = Colors.background
        self.tableView.backgroundColor = Colors.background
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
    
    func moveCell(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let data = userInfo["data"] as! String
            if data == "" {
            }else{
                let oldIndex = habitsOfDate.indexOf({$0.name == data})
                
                habitsOfDate.sortInPlace({ (firstHabit, secondHabit) -> Bool in
                    let first = firstHabit.canDoOn(selectedDate)
                    let second = secondHabit.canDoOn(selectedDate)
                    
                    if first && second {
                        return firstHabit.timeOfDay < secondHabit.timeOfDay
                    } else if first {
                        return true
                    } else if second {
                        return false
                    } else {
                        return firstHabit.timeOfDay < secondHabit.timeOfDay
                    }
                })
                
                let newIndex = habitsOfDate.indexOf({$0.name == data})
                
                self.tableView.moveRowAtIndexPath(NSIndexPath(forRow: oldIndex!, inSection: 0), toIndexPath: NSIndexPath(forRow: newIndex!, inSection: 0))
            }
        }
    }
    
    func refreshData(){
        
        if let currentUser = AuthManager.currentUser {
            habits = currentUser.habits
            self.tableView.reloadData()
        }
    }
    
    @IBAction func clearData(){
        CoreDataManager.clearHabitsOfCurrentUser()
        self.refreshData()
        Utilities.postNotification(Notifications.habitDataChanged)
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
        
        if tableView.editing {cell?.canSwipe = false}
        else {cell?.canSwipe = true}
        
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
        
        if selectedDate > NSDate().endOfDay {
            
        }
        
        var text = selectedDate > NSDate().endOfDay ? "You can't complete on this day yet" : "Swipe to complete"
        
        if tableView.editing {
            text = "Drag to rearrange order"
        }
        
        header.text = habitsOfDate.count > 0 ? text : ""
        header.font = Fonts.calendarSectionHeader
        header.textColor = Colors.textSecondary
        
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
        return Colors.background
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No Habits today!"
        
        let font = Fonts.navTitle
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
        return Colors.accent
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {

        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        
        let text = dateFormatter.stringFromDate(selectedDate)
        
        let font = Fonts.cellTitle
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
    
    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
        self.selectedDate = dayView.date.convertedDate()!
        self.navigationItem.title = Utilities.monthDayStringFromDate(selectedDate)
        self.tableView.reloadData()
        self.calendarView.commitCalendarViewUpdate()
    }

    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
    // MARK: - CVCalendarAppearanceDelegate methods
    func dayLabelWeekdayInTextColor() -> UIColor {
        return Colors.textMain
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return Colors.accentSecondary
    }
    
    func dayLabelWeekdayHighlightedTextColor() -> UIColor {
        return Colors.accent
    }
    
    func dayLabelPresentWeekdayFont() -> UIFont {
        return Fonts.calendar
    }
    
    func dayLabelWeekdayOutTextColor() -> UIColor {
        return Colors.textSecondary
    }
    
    func dayLabelWeekdayFont() -> UIFont {
        return Fonts.calendar
    }
    
    func dayLabelPresentWeekdayTextColor() -> UIColor {
        return Colors.textMain
    }
    
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor {
        return Colors.accentSecondary
    }
    
    func dayOfWeekTextColor() -> UIColor {
        return Colors.textMain
    }
    
    func dayLabelPresentWeekdaySelectedFont() -> UIFont {
        return Fonts.calendar
    }
    
    func dayLabelWeekdaySelectedFont() -> UIFont {
        return Fonts.calendar
    }
    
    func dayOfWeekFont() -> UIFont {
        return Fonts.secondary
    }
    
    func shouldAutoSelectDayOnWeekChange() -> Bool {
        return true
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if let date = dayView.date {
            
            if date.convertedDate() > NSDate() || AuthManager.currentUser?.habits.filter({$0.createdAt.beginningOfDay <= date.convertedDate()?.endOfDay}).count < 1 {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {

        var lightColor: UIColor, darkColor:UIColor
        
        lightColor = Colors.accent.calendarLighten()
        darkColor = Colors.accent
        
        let view = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
        let percent = AuthManager.currentUser?.statHabitCompletionPercentageForDate(dayView.date.convertedDate()!)
        if percent < 50.0 {
            view.fillColor = UIColor.clearColor()
            view.strokeColor = lightColor
        } else if percent < 100.0 {
            view.fillColor = lightColor
        } else {
            view.fillColor = darkColor
        }
        
        return view
    }
}
