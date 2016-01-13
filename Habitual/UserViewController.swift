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

// -TODO: Needs refactoring/documentation

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CVCalendarViewDelegate, CVCalendarViewAppearanceDelegate, CVCalendarMenuViewDelegate {

    var user:User?
    var color:UIColor = Colors.accent
    
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doAppearance()
        
        tableView.registerNib(UINib(nibName: "HabitCell", bundle: nil), forCellReuseIdentifier: "habit")
        
        tableView.contentInset = UIEdgeInsets(top: -15, left: 0, bottom: 0, right: 0)
        
        Utilities.registerForNotification(self, selector: "refreshData", name: Notifications.habitDataChanged)
        Utilities.registerForNotification(self, selector: "refreshData", name:
            Notifications.reloadPulse)
        
        let dataButton = UIBarButtonItem(image: UIImage(named: "line_graph")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: "data")
        
        navigationItem.leftBarButtonItem = dataButton
        
        // this is gross because you can follow yourself when I wrote this
        if user == nil || user?.username == AuthManager.currentUser?.username && self.tabBarController?.selectedIndex == 2 {
            user = AuthManager.currentUser;
            self.navigationItem.title = "Me"
            
            let settingsButton = UIBarButtonItem(image: UIImage(named: "cog")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: "settings")
            
            self.navigationItem.rightBarButtonItem = settingsButton
        }
        else {
            self.navigationItem.title = user?.name.componentsSeparatedByString(" ")[0]
            
            let button = UIBarButtonItem(title: "Chat", style: .Plain, target: self, action: "chat")
            self.navigationItem.rightBarButtonItem = button
        }
        
        chartView.data = getChartData()
        chartView.notifyDataSetChanged()
        chartView.animate(yAxisDuration: 0.8, easingOption: .EaseOutSine)
        
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
    
    func settings() {
        let svc = storyboard?.instantiateViewControllerWithIdentifier("Settings") as! SettingsViewController
        let nvc = UINavigationController(rootViewController: svc)
        nvc.modalTransitionStyle = .FlipHorizontal
        presentViewController(nvc, animated: true, completion: nil)
    }
    
    func data() {
        chartView.hidden = !chartView.hidden
        chartView.notifyDataSetChanged()
        chartView.animate(yAxisDuration: 0.8, easingOption: .EaseOutSine)
    }
    
    func chat() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
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
        for habit: Habit in user!.habits {
            
            let dataSet = BarChartDataSet(yVals: [BarChartDataEntry(value: habit.getCompletionPercentage(), xIndex: 0)], label: habit.name)
            dataSet.colors = [UIColor(hexString: habit.color)]
            count++
            
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
        tableView.reloadData()
    }
    
    func statForIndex(index: Int) -> (String, String){
        if(index == 0){
            return ("Habits completed:","\(user!.statHabitsCompleted())")
        }else {
            return ("Most completed habit:",user!.statMostCompletedHabit())
        }
//        else{
//            return ("Longest streak:","\(user!.statLongestStreak())")
//        }
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return user!.habits.count > 0 ? 2 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let user = user {
                return user.habits.count
            }else{
                return 0
            }
        }else{
            return 2
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("habit", forIndexPath: indexPath) as! HabitCell
            cell.configureForHabit(user!.habits[indexPath.row])
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
            return "Habits"
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
            
            if date.convertedDate() > NSDate() || user?.habits.filter({$0.createdAt.beginningOfDay <= date.convertedDate()?.endOfDay}).count < 1 {
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
        let percent = user!.statHabitCompletionPercentageForDate(dayView.date.convertedDate()!)
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
