//
//  MeTableViewController.swift
//  Habitual
//
//  Created by Josh Wright on 7/20/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit
import Charts

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var user:User?
    
    @IBOutlet weak var chartView: BarChartView!
    
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "HabitCell", bundle: nil), forCellReuseIdentifier: "habit")
        Utilities.registerForNotification(self, selector: "refreshData", name: kNotificationIdentifierHabitDataChanged)
        
        if user == nil{user = AuthManager.currentUser; self.navigationItem.title = "Me"}
        else {self.navigationItem.title = user?.username}
        
        let ds1 = BarChartDataSet(yVals: [BarChartDataEntry(value: 45, xIndex: 0)], label: "Go for a run")
        ds1.setColor(UIColor.blueColor())
        let ds2 = BarChartDataSet(yVals: [BarChartDataEntry(value: 56, xIndex: 0)], label: "Go for a run")
        ds2.setColor(UIColor.greenColor())
        let ds3 = BarChartDataSet(yVals: [BarChartDataEntry(value: 32, xIndex: 0)], label: "Go for a run")
        ds3.setColor(UIColor.purpleColor())
        let ds4 = BarChartDataSet(yVals: [BarChartDataEntry(value: 100, xIndex: 0)], label: "Go for a run")
        ds4.setColor(UIColor.yellowColor())
        let ds5 = BarChartDataSet(yVals: [BarChartDataEntry(value: 76, xIndex: 0)], label: "Go for a run")
        ds5.setColor(UIColor.redColor())
        let ds6 = BarChartDataSet(yVals: [BarChartDataEntry(value: 85, xIndex: 0)], label: "Go for a run")
        ds6.setColor(UIColor.orangeColor())
        
        chartView.data = BarChartData(xVals: ["Habit Completion Rate"], dataSets: [ds1,ds2,ds3,ds4,ds5,ds6])
        
        chartView.drawGridBackgroundEnabled = false
        chartView.drawBordersEnabled = false
        
        chartView.pinchZoomEnabled = false
        
        chartView.legend.form = .Circle
        
        let xaxis = chartView.xAxis
        xaxis.drawGridLinesEnabled = false
        xaxis.labelPosition = .Bottom
        
        chartView.rightAxis.enabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        
        chartView.descriptionText = ""
        chartView.drawValueAboveBarEnabled = false
    
        chartView.notifyDataSetChanged()
        tableView.reloadData()
    }

    func refreshData(){
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
        
            cell.configureForHabit(user!.habits[indexPath.row])
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
