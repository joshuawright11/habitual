//
//  MeTableViewController.swift
//  Habitual
//
//  Created by Josh Wright on 7/20/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit
import Charts
import DynamicColor
import CVCalendar
import DKChainableAnimationKit

// -TODO: Needs refactoring/documentation

class UserController: UIViewController, UITableViewDelegate, UITableViewDataSource, CVCalendarViewDelegate, CVCalendarViewAppearanceDelegate, CVCalendarMenuViewDelegate {

    var habits: [Habit]!

    var color:UIColor = Colors.accent
    
    var connection: Connection?
    
    var connectionService: ConnectionService!
    var accountService: AccountService!
    
    @IBOutlet weak var keyView: UIView! {
        didSet {
            keyView.backgroundColor = Colors.barBackground
        }
    }
    
    @IBOutlet weak var key1: UIView! {
        didSet {
            key1.layer.cornerRadius = 16
            key1.backgroundColor = Colors.barBackground
            key1.layer.borderWidth = 1
            key1.layer.borderColor = color.calendarLighten().CGColor
        }
    }
    
    @IBOutlet weak var key2: UIView! {
        didSet {
            key2.layer.cornerRadius = 16
            key2.backgroundColor = color.calendarLighten()
        }
    }
    
    @IBOutlet weak var key3: UIView! {
        didSet {
            key3.layer.cornerRadius = 16
            key3.backgroundColor = color
        }
    }
    
    @IBOutlet weak var keyHeight: NSLayoutConstraint!
    
    @IBOutlet weak var chartView: BarChartView! {
        didSet {
            chartView.hidden = true
            chartView.backgroundColor = Colors.barBackground
            chartView.drawGridBackgroundEnabled = false
            chartView.drawBordersEnabled = false

            chartView.pinchZoomEnabled = false

            chartView.legend.enabled = false

            let xaxis = chartView.xAxis
            xaxis.drawGridLinesEnabled = false
            xaxis.labelPosition = .Bottom

            chartView.rightAxis.enabled = false
            chartView.leftAxis.drawAxisLineEnabled = false
            chartView.leftAxis.enabled = false
            chartView.xAxis.labelFont = Fonts.sectionHeaderBold
            chartView.xAxis.labelTextColor = Colors.textMain
            chartView.descriptionText = ""
            chartView.drawValueAboveBarEnabled = true
            chartView.noDataText = "No habits created yet!"
        }
    }
    
    @IBOutlet weak var menuView: CVCalendarMenuView! {
        didSet {
            menuView.backgroundColor = Colors.barBackground
        }
    }
    
    @IBOutlet weak var calendarView: CVCalendarView! {
        didSet {
            calendarView.delegate = self
            calendarView.appearance.delegate = self
            calendarView.backgroundColor = Colors.barBackground
        }
    }
    @IBOutlet weak var spacerView: UIView!
    @IBOutlet var tableView: UITableView!

    private var calendar: Bool {
        get {
            return chartView.hidden
        }
    }
    
    private var selectedDate = NSDate() {
        didSet {
            navigationItem.title = Utilities.monthDayStringFromDate(selectedDate)
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
    
    var habitsOfDate: [Habit] = [] {
        didSet {
            if calendar {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doAppearance()
        
        tableView.registerNib(UINib(nibName: "HabitCell", bundle: nil), forCellReuseIdentifier: "habit")
        
        tableView.contentInset = UIEdgeInsets(top: -15, left: 0, bottom: 0, right: 0)
        
        Utilities.registerForNotification(self, selector: #selector(UserController.refreshData), name: Notifications.habitDataChanged)
        Utilities.registerForNotification(self, selector: #selector(UserController.refreshData), name:
            Notifications.reloadPulse)
        
        let dataButton = UIBarButtonItem(image: UIImage(named: "line_graph")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: #selector(UserController.data))
        

        
        // this is gross because you can follow yourself when I wrote this
        if self.connection == nil {
            self.navigationItem.title = "Me"
            
            let settingsButton = UIBarButtonItem(image: UIImage(named: "cog")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: #selector(UserController.settings))
            
            self.navigationItem.leftBarButtonItem = settingsButton
            navigationItem.rightBarButtonItem = dataButton
        }
        else {
            self.navigationItem.title = "FIXME"
        
            let button = UIBarButtonItem(image: UIImage(named: "chats")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: #selector(UserController.chat))
            self.navigationItem.rightBarButtonItems = [dataButton, button]
        }
        
        chartView.data = getChartData()
        chartView.notifyDataSetChanged()
        chartView.animate(yAxisDuration: 0.8, easingOption: .EaseOutSine)
        selectedDate = NSDate()
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
    
    func settings() {
        let svc = storyboard?.instantiateViewControllerWithIdentifier("Settings") as! SettingsController
        let nvc = UINavigationController(rootViewController: svc)
        nvc.modalTransitionStyle = .FlipHorizontal
        presentViewController(nvc, animated: true, completion: nil)
    }
    
    func data() {
        chartView.hidden = !chartView.hidden
        chartView.notifyDataSetChanged()
        chartView.animate(yAxisDuration: 0.8, easingOption: .EaseOutSine)
        tableView.reloadData()
        
        if !chartView.hidden {
            keyHeight.constant = 0
        } else {
            keyHeight.constant = 32
        }
        
        UIView.animateWithDuration(0.2) {
            self.keyView.layoutIfNeeded()
        }
        
        if chartView.hidden {
            self.navigationItem.title = Utilities.monthDayStringFromDate(selectedDate)
        } else {
            if self.tabBarController?.selectedIndex == 2 {
                navigationItem.title = "Me"
            } else {
                navigationItem.title = "FIXME"
            }
        }
    }
    
    func chat() {
        let ccvc = storyboard?.instantiateViewControllerWithIdentifier("Chat") as! ConnectionChatController
        ccvc.connection = connection
        ccvc.accountService = accountService
        ccvc.connectionService = connectionService
        
        let nav = UINavigationController(rootViewController: ccvc)
        nav.modalTransitionStyle = .FlipHorizontal
        
        presentViewController(nav, animated: true, completion: nil)
    }
    
    func doAppearance() {
        self.tableView.backgroundColor = Colors.background
        self.view.backgroundColor = Colors.barBackground
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        
        Styler.viewBottomShader(spacerView)
        spacerView.backgroundColor = Colors.barBackground
    }

    func getChartData() -> BarChartData {
        
        var dataSets: [BarChartDataSet] = []
        
        var count = 0
        for habit: Habit in habits {
            
            let dataSet = BarChartDataSet(yVals: [BarChartDataEntry(value: habit.getCompletionPercentage(), xIndex: 0)], label: habit.name)
            dataSet.colors = [UIColor(hexString: habit.color)]
            count += 1
            
            dataSets.append(dataSet)
        }
        
        var xvals: [String] = []
        
        if count != 0 {
            xvals = ["Habit Completion Percentage"]
        }
        
        let data = BarChartData(xVals: xvals, dataSets: dataSets)
        data.setValueFont(Fonts.body)
        data.setValueTextColor(Colors.textMain)
        
        let nf = NSNumberFormatter()
        nf.numberStyle = .PercentStyle
        nf.maximumFractionDigits = 0
        nf.multiplier = 1
        data.setValueFormatter(nf)
        
        return data
        
    }
    
    func refreshData(){
        chartView.data = getChartData()
        chartView.notifyDataSetChanged()
        calendarView.refresh()
        tableView.reloadData()
    }
    
    func statForIndex(index: Int) -> (String, String){
        if(index == 0){
            return ("Habits completed:","\(habits.statHabitsCompleted())")
        }else {
            return ("Most completed habit:",habits.statMostCompletedHabit())
        }
//        else{
//            return ("Longest streak:","\(user.statLongestStreak())")
//        }
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return calendar ? 1 : 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return calendar ?  habitsOfDate.count : habits.count
        }else{
            return 2
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("habit", forIndexPath: indexPath) as! HabitCell
            if calendar {
                cell.configureForHabit(habits[indexPath.row], date: selectedDate)
            } else {
                cell.configureForHabit(habits[indexPath.row])
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("stat") as! StatCell
            let statTuple = statForIndex(indexPath.row)
            cell.configure(statTuple)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 56
        default: return 44
        }
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if(section == 0){
            return calendar ? "Habits of \(Utilities.monthDayStringFromDate(selectedDate))" : "All Habits"
        }else{
            return "Stats"
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
    }
    
    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
        self.selectedDate = dayView.date.convertedDate()!
        self.tableView.reloadData()
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return true
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
    
    func dayLabelPresentWeekdaySelectedFont() -> UIFont {
        return Fonts.calendar
    }
    
    func dayLabelWeekdaySelectedFont() -> UIFont {
        return Fonts.calendar
    }
    
    func dayOfWeekTextColor() -> UIColor {
        return Colors.textMain
    }
    
    func dayOfWeekFont() -> UIFont {
        return Fonts.secondary
    }
    
    func shouldAutoSelectDayOnWeekChange() -> Bool {
        return false
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if let date = dayView.date {
            
            if date.convertedDate() > NSDate() || habits.filter({$0.createdAt.beginningOfDay <= date.convertedDate()?.endOfDay}).count < 1 {
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
        if !dayView.isOut {
            lightColor = color.calendarLighten()
            darkColor = color
        } else {
            lightColor = Colors.gray.calendarLighten().colorWithAlphaComponent(0.10)
            darkColor = Colors.gray.igniteDarken().colorWithAlphaComponent(0.05)
        }
        
        let view = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
        let percent = habits.statHabitCompletionPercentageForDate(dayView.date.convertedDate()!)
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
