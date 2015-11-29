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
    
    private var date: NSDate!
    private var habit: Habit!
    
    private var color: UIColor!
    private var bgColor: UIColor!
    
    internal var data: (Habit, NSDate)!{
        get{
            return (habit, date)
        }
        set(new){
            habit = new.0
            date = new.1
            
            color = UIColor(hexString: habit.color)
            bgColor = color.colorWithAlphaComponent(Floats.colorAlpha)
            
            doAppearance()
        }
    }
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Styler.viewShader(borderView)
    }
    
    func configure() {
        
        setupHandlers()
        
        selectionStyle = UITableViewCellSelectionStyle.None
        
        self.titleLabel.text = habit.name
        refreshLabels()
        
        if(date.beginningOfDay < NSDate()) { setupHandlers() }
        
        if habit.countDoneInDate(date) == habit.timesToComplete {
            instantComplete()
        }else{
            instantUncomplete()
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
                
                let bgColor = percent > 0 ? color.hexString : "FFFFFF"
                borderView.backgroundColor = UIColor(hexString: bgColor, withAlpha: Floats.colorAlpha + abs(percent*(1-Floats.colorAlpha)))
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
        habit.saveToCoreData()
        detailTextLabel?.text = subtitleText()

        if habit.countCompletedIn(date, freq: habit.frequency) == habit.timesToComplete {
            animateComplete()
        }else{
            animateReturn()
        }
        
        Utilities.postNotification(kNotificationIdentifierHabitDataChanged)
        if habit.notificationsEnabled && habit.dateInCurrentFrequency(date) {
            habit.uploadToServer(nil)
        }
    }
    
    func instantComplete() {
        let moveTo = UIScreen.mainScreen().bounds.width - 70
        
        borderView.backgroundColor = color
        borderView.frame.origin.x = moveTo
        self.borderConstraint.constant = moveTo
        self.refreshLabels()
        
        checkmark.alpha = 1.0
        
        iv.tintColor = kColorTextSecondary
        
        self.titleLabel.textColor = kColorTextSecondary
        self.subtitleLabel.textColor = kColorTextSecondary
    }
    func animateComplete() {
        let moveTo = UIScreen.mainScreen().bounds.width - 70
        
        borderView.animation.makeX(moveTo).easeOut.makeBackground(color).animateWithCompletion(kAnimationLength) {
            self.borderConstraint.constant = moveTo
            self.refreshLabels()
            
        }
        
        checkmark.animation.makeAlpha(1.0).animate(kAnimationLength)
        
        iv.tintColor = kColorTextSecondary
        
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
            habit.uploadToServer(nil)
        }
    }
    
    func instantUncomplete() {
        borderView.backgroundColor = bgColor
        borderView.frame.origin.x = 14
        self.borderConstraint.constant = 14
        self.refreshLabels()
        
        checkmark.alpha = 0.0
        
        iv.tintColor = color
        
        self.titleLabel.textColor = kColorTextMain
        self.subtitleLabel.textColor = kColorTextMain
    }
    
    func animateUncomplete() {
        borderView.animation.makeX(14).easeInOut.makeBackground(bgColor).animateWithCompletion(kAnimationLength) {
            self.borderConstraint.constant = 14
            self.refreshLabels()
        }
        
        checkmark.animation.makeAlpha(0.0).animate(kAnimationLength)
        
        iv.tintColor = color
        
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
        
        var text = "\(habit.timesToComplete - habit.countDoneInDate(date)) more times \(unit)"
        if((habit.timesToComplete - habit.countDoneInDate(date)) == 0) {text = "Complete!"}
        
        return text
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let velocity = pgr?.velocityInView(self)
        return fabs(velocity!.y) < fabs(velocity!.x)
    }
    
    func doAppearance() {
        
        titleLabel.textColor = kColorTextMain
        titleLabel.font = kFontCellTitle
        subtitleLabel.textColor = kColorTextMain
        subtitleLabel.font = kFontCellSubtitle
        
        let image = UIImage(named: habit.icon)
        iv.backgroundColor = UIColor.clearColor()
        iv.contentMode = .ScaleAspectFit
        iv.tintColor = color
        iv.image = image?.imageWithRenderingMode(.AlwaysTemplate)
        
        backgroundColor = kColorBackground
        
        self.borderView.backgroundColor = color
        
        checkmark.image = UIImage(named: "checkmark_large")?.imageWithRenderingMode(.AlwaysTemplate)
        checkmark.tintColor = kColorBackground
        checkmark.alpha = 0.0
        
        borderView.layer.cornerRadius = 14.0
//        borderView.layer.borderWidth = 0.5
//        borderView.layer.borderColor = color.CGColor
    }
}
