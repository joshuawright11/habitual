//
//  HabitDetailController.swift
//  Habitual
//
//  Created by Josh Wright on 7/13/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit

class HabitDetailController: UITableViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var daysInARowLabel: UILabel!
    @IBOutlet weak var daysInARowTitle: UILabel!
    
    var habit:Habit?
    
    let repeats = ["Daily", "Weekly", "Monthly"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let habit = habit {
            nameTextField.text = habit.name
            daysInARowLabel.text = String(habit.datesCompleted.count ?? 0)
            self.navigationItem.title = habit.name
            self.repeatLabel.text = habit.repeat.name()
        }else{
            self.navigationItem.title = "New Habit"
            self.daysInARowLabel.hidden = true
            self.daysInARowTitle.hidden = true

            let button = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "done:")

            self.navigationItem.rightBarButtonItem = button

        }
    }
    
    func done(sender: UIBarButtonItem){
        
        let index = Int16(find(repeats, repeatLabel.text!)!)
        
        AuthManager.addHabitForCurrentUser(self.nameTextField.text, repeat: Repeat(rawValue: index)!)

        Utilities.postNotification(kNotificationIdentifierRefreshHome)
        Utilities.postNotification(kNotificationIdentifierHabitDataChanged)
        
        navigationController?.popToRootViewControllerAnimated(true)
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 1 {
            let index = ((find(repeats, repeatLabel.text!)!) + 1) % 3
            self.repeatLabel.text = repeats[Int(index)]
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
}
