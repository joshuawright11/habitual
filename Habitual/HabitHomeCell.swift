//
//  HabitHomeCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/9/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import DKChainableAnimationKit

class HabitHomeCell: UITableViewCell {

    let kAnimationLength = 0.3
    
    @IBOutlet weak var iv: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var checkmark: UIImageView!
    
    
    @IBOutlet weak var borderConstraint: NSLayoutConstraint!
    
    var pgr:UIPanGestureRecognizer? = nil
    
    internal var data: (Habit, NSDate)!{
        get{
            return (habit, date)
        }
        set(new){
            habit = new.0
            date = new.1
            
            doAppearance()
        }
    }
    
    private var date: NSDate!
    private var habit: Habit!
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, habit: Habit, date: NSDate) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        data = (habit, date)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func configure() {
        
        setupHandlers()
        
        selectionStyle = UITableViewCellSelectionStyle.None
        
        self.titleLabel.text = habit.name
        refreshLabels()
        
        if(date.beginningOfDay < NSDate()) { setupHandlers() }
        
        if habit.countDoneInDate(date) == habit.timesToComplete {
            animateComplete()
        }else{
            animateUncomplete()
        }
    }
    
    func refreshLabels() {
        self.subtitleLabel.text = subtitleText()
    }
    
    func setupHandlers() {
        
        if(pgr == nil){
            pgr = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
            pgr!.delegate = self
            addGestureRecognizer(pgr!)
        }
        
        if(date.beginningOfDay > NSDate().endOfDay) {
            pgr?.enabled = false
        }else{
            pgr?.enabled = true
        }
        
        
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        
        let distance = (UIScreen.mainScreen().bounds.width-70)/3
        let percent = borderView.frame.origin.x/(distance*3)
        
        if(recognizer.state == .Ended) {
            if(percent > 0.3 && percent < 0.5){
                complete()
            }else if(percent < 0.7 && percent > 0.5){
                uncomplete()
            }else if(percent < -0.3 && percent > -0.5){
                uncomplete()
            }else{
                animateReturn()
            }
        }else{
            
            let translation = recognizer.translationInView(self)
            
            if percent > 0.3 && percent < 0.5 && translation.x > 0{
                
            }else if percent < 0.7 && percent > 0.5 && translation.x < 0{
                
            }else if percent < -0.3 && percent > -0.5{
                
            }else if borderView.frame.origin.x > (UIScreen.mainScreen().bounds.width - 70) && translation.x > 0{
                
            }else {
                
                borderView.frame.origin.x += translation.x
                
                let color = percent > 0 ? "C644FC" : "FFFFFF"
                borderView.backgroundColor = UIColor(hexString: color, withAlpha: abs(percent))
                recognizer.setTranslation(CGPointZero, inView: self)
            }
        }
    }
    
    func animateReturn() {
        
        if habit.countDoneInDate(date) == habit.timesToComplete {
            animateComplete()
        }else{
            animateUncomplete()
        }
    }
    
    func complete(){
        
        if habit.countCompletedIn(date, freq: habit.frequency) >= habit.timesToComplete {return}

        habit.datesCompleted.append(date)
        detailTextLabel?.text = subtitleText()

        if habit.countCompletedIn(date, freq: habit.frequency) == habit.timesToComplete {
            animateComplete()
        }else{
            animateReturn()
        }
        
        Utilities.postNotification(kNotificationIdentifierHabitDataChanged)
        if habit.notificationsEnabled && habit.dateInCurrentFrequency(date) {
            ForeignNotificationManager.completeHabitForCurrentUser(habit)
        }
    }
    
    func animateComplete() {
        let moveTo = UIScreen.mainScreen().bounds.width - 70
        
        borderView.animation.makeX(moveTo).easeOut.makeBackground(kColorPurple).animateWithCompletion(kAnimationLength) {
            self.borderConstraint.constant = moveTo
            self.refreshLabels()
            
        }
        iv.animation.makeBackground(kColorTextSecondary).animate(kAnimationLength)
        
        self.titleLabel.textColor = kColorTextSecondary
        self.subtitleLabel.textColor = kColorTextSecondary
        
    }
    
    func uncomplete() {
        
        if !(habit.countCompletedIn(date, freq: habit.frequency) > 0) {
            animateReturn()
            return
        }
        
        habit.uncompleteOn(date)
        
        detailTextLabel?.text = subtitleText()
        animateUncomplete()
        
        Utilities.postNotification(kNotificationIdentifierHabitDataChanged)
        if habit.notificationsEnabled && habit.canDo() {
            ForeignNotificationManager.uncompleteHabitForCurrentUser(habit)
        }
    }
    
    func animateUncomplete() {
        borderView.animation.makeX(14).easeInOut.makeBackground(kColorBackground).animateWithCompletion(kAnimationLength) {
            self.borderConstraint.constant = 14
            self.refreshLabels()
        }
        iv.animation.makeBackground(kColorPurple).animate(kAnimationLength)
        
        self.titleLabel.textColor = kColorTextMain
        self.subtitleLabel.textColor = kColorTextMain
    }
    
    func subtitleText() -> String {
        let unit:String
        switch habit.frequency {
        case .Daily:
            unit = "today"
        case .Weekly:
            unit = "this week"
        case .Monthly:
            unit = "this month"
        }
        
        let text = "\(habit.timesToComplete - habit.countDoneInDate(date)) more times \(unit)"
        return text
    }
    
    func doAppearance() {
        titleLabel.textColor = kColorTextMain
        titleLabel.font = kFontCellTitle
        subtitleLabel.textColor = kColorTextMain
        subtitleLabel.font = kFontCellSubtitle
        
        iv.backgroundColor = kColorPurple
        
        backgroundColor = kColorBackground
        
        self.borderView.backgroundColor = kColorBackground
        
        checkmark.image = UIImage(named: "checkmark")
        checkmark.tintColor = kColorBackground
        
        borderView.layer.cornerRadius = 30.0
        borderView.layer.borderWidth = 2.0
        borderView.layer.borderColor = kColorPurple.CGColor
    }
}
