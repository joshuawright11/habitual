//
//  MeTableViewController.swift
//  Habitual
//
//  Created by Josh Wright on 7/20/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit
import Charts
import ChameleonFramework

// -TODO: Needs refactoring/documentation

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var user:User?
    
    @IBOutlet weak var chartView: BarChartView!
    
    @IBOutlet weak var spacerView: UIView!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        doAppearance()
        
        tableView.registerNib(UINib(nibName: "HabitCell", bundle: nil), forCellReuseIdentifier: "habit")
        
        tableView.contentInset = UIEdgeInsets(top: -15, left: 0, bottom: 0, right: 0)
        
        Utilities.registerForNotification(self, selector: "refreshData", name: Notifications.habitDataChanged)
        Utilities.registerForNotification(self, selector: "refreshData", name:
            Notifications.reloadPulse)
        
        // this is gross because you can follow yourself when I wrote this
        if user == nil || user?.username == AuthManager.currentUser?.username && self.tabBarController?.selectedIndex == 2 {
            user = AuthManager.currentUser;
            self.navigationItem.title = "Me"
            
            let button = UIBarButtonItem(image: UIImage(named: "settings")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: "settings")
            
            self.navigationItem.rightBarButtonItem = button
        }
        else {
            self.navigationItem.title = user?.name.componentsSeparatedByString(" ")[0]
            
            let button = UIBarButtonItem(title: "Chat", style: .Plain, target: self, action: "chat")
            self.navigationItem.rightBarButtonItem = button
        }
        
        chartView.data = getChartData()
        
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
        chartView.notifyDataSetChanged()
        chartView.animate(yAxisDuration: 0.8, easingOption: .EaseOutSine)
        
        tableView.reloadData()
    }
    
    func settings() {
        let svc = storyboard?.instantiateViewControllerWithIdentifier("Settings") as! SettingsViewController
        let nvc = UINavigationController(rootViewController: svc)
        nvc.modalTransitionStyle = .FlipHorizontal
        presentViewController(nvc, animated: true, completion: nil)
    }
    
    func chat() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doAppearance() {
        self.tableView.backgroundColor = Colors.background
        self.chartView.backgroundColor = Colors.barBackground
        self.view.backgroundColor = Colors.background
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        
        spacerView.backgroundColor = Colors.barBackground
        
        spacerView.layer.shadowColor = Colors.shadow.CGColor
        spacerView.layer.shadowOffset = CGSize(width: 0, height: 2.75)
        spacerView.layer.shadowRadius = 1.75
        spacerView.layer.shadowOpacity = 0.4
    }

    func getChartData() -> BarChartData {
        
        var dataSets: [BarChartDataSet] = []
        
        var count = 0
        for habit: Habit in (user?.habits)! {
            
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
}
