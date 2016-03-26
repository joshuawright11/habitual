//
//  UserCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/9/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

// -TODO: Needs refactoring/documentation

class UserCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {

    static let height = CGFloat(159)
    
    @IBOutlet weak var borderView: UIView! {
        didSet {
            Styler.viewShader(borderView)
        }
    }
    @IBOutlet weak var profileiv: UIImageView! {
        didSet {
            profileiv.layer.cornerRadius = 25
            profileiv.clipsToBounds = true
            profileiv.contentMode = .ScaleAspectFill
        }
    }
    @IBOutlet weak var initialsLabel: UILabel! {
        didSet {
            Styler.viewShaderSmall(initialsLabel)
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var borderViewHeight: NSLayoutConstraint!
  
    @IBOutlet weak var timesLabel: UILabel! {
        didSet {
            timesLabel.font = Fonts.buttonSelected
            timesLabel.textColor = Colors.textSubtitle
        }
    }
    @IBOutlet weak var timesiv: UIImageView! {
        didSet {
            timesiv.image = UIImage(named: "checkmark_small")?.imageWithRenderingMode(.AlwaysTemplate)
            Styler.viewShaderSmall(timesiv)
        }
    }
    
    @IBOutlet weak var linksLabel: UILabel! {
        didSet {
            linksLabel.font = Fonts.buttonSelected
            linksLabel.textColor = Colors.textSubtitle
        }
    }
    @IBOutlet weak var linksiv: UIImageView! {
        didSet {
            linksiv.image = UIImage(named: "chain")?.imageWithRenderingMode(.AlwaysTemplate)
            Styler.viewShaderSmall(linksiv)
        }
    }
    
    @IBOutlet weak var finishedLabel: UILabel! {
        didSet {
            finishedLabel.font = Fonts.buttonSelected
            finishedLabel.textColor = Colors.textMain
        }
    }
    @IBOutlet weak var unfinishedLabel: UILabel! {
        didSet {
            unfinishedLabel.font = Fonts.buttonSelected
            unfinishedLabel.textColor = Colors.textMain
        }
    }

    @IBOutlet weak var habitsContainer: UIView! {
        didSet {
            habitsContainer.backgroundColor = Colors.background
            habitsContainer.layer.cornerRadius = Floats.cardCornerRadius
            Styler.viewShaderSmall(habitsContainer)
        }
    }
    
    @IBOutlet weak var finishedTableView: UITableView! {
        didSet {
            finishedTableView.layer.cornerRadius = Floats.cardCornerRadius
        }
    }
    
    @IBOutlet weak var unfinishedTableView: UITableView! {
        didSet {
            unfinishedTableView.layer.cornerRadius = Floats.cardCornerRadius
        }
    }
    
    private var finishedHabits: [Habit]!
    private var unfinishedHabits: [Habit]!
    
    var connection:Connection! {
        didSet {
            finishedHabits = connection.user.habits.filter({$0.completed()})
            unfinishedHabits = connection.user.habits.filter({!$0.completed()})
            linksLabel.text = "x\(connection.numAccountable)"
            timesLabel.text = "x\(connection.user.statHabitsCompleted())"
            
            let id = connection.user.parseObject!["fbId"]
            
            if let id = id as? String {
                profileiv.imageFromURL("https://graph.facebook.com/\(id)/picture?type=large")
                profileiv.hidden = false
            } else {
                profileiv.hidden = true
            }
            
            finishedTableView.reloadData()
            unfinishedTableView.reloadData()
            
            var numFinished = connection.user.habits.filter({$0.completed()}).count
            var numUnfinished = connection.user.habits.count - numFinished
            
            if !connection.approved {
                numFinished = 0
                numUnfinished = 0
                habitsContainer.hidden = true
            } else {
                habitsContainer.hidden = false
            }
            
            let height = UserCell.height + (CGFloat(max(numFinished, numUnfinished)) * HabitGlanceCell.height)
            
            borderViewHeight.constant = height-16
            
            borderView.setNeedsLayout()
            initialsLabel.setNeedsLayout()
            titleLabel.setNeedsLayout()
            habitsContainer.setNeedsLayout()
            
        }
    }
    var color: UIColor! {
        didSet {
            linksiv.tintColor = color
            timesiv.tintColor = color
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupTableViews()
    }
    
    func configure(connection: Connection) {
        self.connection = connection
        let user = connection.user
        
        let names = user.name.componentsSeparatedByString(" ")
        
        initialsLabel.text = (String(names[0].characters.first!) + String(names[1].characters.first!)).uppercaseString
        
        titleLabel.text = user.name
        
        doAppearance()
    }
    
    func setupTableViews() {
        
        finishedTableView.registerNib(UINib(nibName: "HabitGlanceCell", bundle: nil), forCellReuseIdentifier: HabitGlanceCell.reuseIdentifier)
        unfinishedTableView.registerNib(UINib(nibName: "HabitGlanceCell", bundle: nil), forCellReuseIdentifier: HabitGlanceCell.reuseIdentifier)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == finishedTableView {
            return finishedHabits.count
        } else {
            return unfinishedHabits.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(HabitGlanceCell.reuseIdentifier, forIndexPath: indexPath) as! HabitGlanceCell
        
        if tableView == finishedTableView {
            cell.finished = true
            cell.habit = finishedHabits[indexPath.row]
            cell.connectionColor = self.color
        } else {
            cell.finished = false
            cell.habit = unfinishedHabits[indexPath.row]
            cell.connectionColor = self.color
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return HabitGlanceCell.height
    }
    
    func doAppearance() {
        
        if connection.approved {
            subtitleLabel.text = connection.messages?.last?.text ?? "\(connection.user.statHabitsCompleted()) habits completed"
        }else{
            subtitleLabel.text = connection.sentByCurrentUser ? "Pending acceptance" : "Wants to connect"
        }
        
        color = connection.approved ? connection.color : UIColor(hexString: "999999")
        let textColor = connection.approved ? Colors.textMain : UIColor(hexString: "999999")
        let subtitleTextColor = connection.approved ? Colors.textSubtitle : UIColor(hexString: "999999")
        
        if connection.approved || connection.sentByCurrentUser {
            acceptButton.hidden = true
        } else {
            acceptButton.hidden = false
            acceptButton.backgroundColor = Colors.green.colorWithAlphaComponent(0.7)
            acceptButton.titleLabel?.font = Fonts.sectionHeader
            acceptButton.tintColor = Colors.textMain
            acceptButton.addTarget(self, action: Selector("approve"), forControlEvents: .TouchUpInside)
            acceptButton.layer.cornerRadius = Floats.cardCornerRadius
        }
        
        backgroundColor = Colors.background
        selectionStyle = UITableViewCellSelectionStyle.None
        
        titleLabel.textColor = textColor
        titleLabel.font = Fonts.cellTitle
        
        subtitleLabel.textColor = subtitleTextColor
        subtitleLabel.font = Fonts.cellSubtitle
        
        initialsLabel.font = Fonts.initials
        initialsLabel.textColor = color
        
        initialsLabel.layer.backgroundColor = Colors.background.CGColor
        
        initialsLabel.layer.cornerRadius = 25.0
        initialsLabel.layer.borderWidth = 2.0
        initialsLabel.layer.borderColor = color.CGColor
        
        borderView.backgroundColor = connection.approved ? color.darkenColor(Floats.darkenPercentage).desaturateColor(0.4) : UIColor.whiteColor().colorWithAlphaComponent(0.05)
        borderView.layer.cornerRadius = Floats.cardCornerRadius
    }
    
    func approve() {
        connection.approve()
        doAppearance()
    }
    
}
