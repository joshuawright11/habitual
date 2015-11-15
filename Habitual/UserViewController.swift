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

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var user:User?
    
    @IBOutlet weak var chartView: BarChartView!
    
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        doAppearance()
        
        tableView.registerNib(UINib(nibName: "HabitCell", bundle: nil), forCellReuseIdentifier: "habit")
        
        Utilities.registerForNotification(self, selector: "refreshData", name: kNotificationIdentifierHabitDataChanged)
        Utilities.registerForNotification(self, selector: "refreshData", name: kNotificationIdentifierHabitAddedOrDeleted)
        
        if user == nil{user = AuthManager.currentUser; self.navigationItem.title = "Me"}
        else {self.navigationItem.title = user?.username}
        
        chartView.data = getChartData()
        
        chartView.drawGridBackgroundEnabled = false
        chartView.drawBordersEnabled = false
        
        chartView.pinchZoomEnabled = false
        
        chartView.legend.form = .Circle
        
        let xaxis = chartView.xAxis
        xaxis.drawGridLinesEnabled = false
        xaxis.labelPosition = .Bottom
        
        chartView.rightAxis.enabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.leftAxis.enabled = false
        
        chartView.descriptionText = ""
        chartView.drawValueAboveBarEnabled = true
    
        chartView.notifyDataSetChanged()
        tableView.reloadData()
    }
    
    func doAppearance() {
        self.tableView.backgroundColor = kColorBackground
        
        self.chartView.backgroundColor = kColorBackground
        
        
    }

    func getChartData() -> BarChartData {
        
        struct ChartColors {
            static let colors = [kColorPurple, kColorOrange, kColorBlue, kColorRed,kColorYellow, kColorGreen]
        }
        
        var dataSets: [BarChartDataSet] = []
        
        var count = 0
        for habit: Habit in (user?.habits)! {
            
            let dataSet = BarChartDataSet(yVals: [BarChartDataEntry(value: habit.getCompletionPercentage(), xIndex: 0)], label: habit.name)
            dataSet.colors = [ChartColors.colors[count%6]]
            count++
            
            dataSets.append(dataSet)
        }
        
        return BarChartData(xVals: ["Habit Completion Percentage"], dataSets: dataSets)
        
    }
    
    func refreshData(){
        chartView.data = getChartData()
        chartView.notifyDataSetChanged()
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

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return user!.habits.count > 0 ? 2 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("habit", forIndexPath: indexPath) as! HabitCell
        
//            cell.configureForHabit(user!.habits[indexPath.row])
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("stat")! as UITableViewCell
            
            let statTuple = statForIndex(indexPath.row)
            
            cell.textLabel?.text = statTuple.0
            cell.detailTextLabel?.text = statTuple.1
            
            return cell
        }
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if(section == 0){
            return "Stats"
        }else{
            return "Habits"
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
