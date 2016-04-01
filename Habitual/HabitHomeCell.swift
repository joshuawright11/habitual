//
//  HabitHomeCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/9/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import DKChainableAnimationKit
import LTMorphingLabel

// -TODO: Needs refactoring/documentation

class HabitHomeCell: UITableViewCell, LTMorphingLabelDelegate {

    /// The length in seconds that the animation should run
    let kAnimationLength = 0.3
    
    @IBOutlet weak var iv: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: LTMorphingLabel!
    @IBOutlet weak var bottomLabel: LTMorphingLabel!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var checkmark: UIImageView!
    @IBOutlet weak var borderConstraint: NSLayoutConstraint!
    
    var pgr:UIPanGestureRecognizer? = nil
    
    var canSwipe = true
    
    var habitService: HabitService!
    
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
            bgColor = color.igniteDarken()
            
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
        Styler.viewShaderSmall(borderView)
    }
    
    func configure() {
        
        setupHandlers()
        
        selectionStyle = UITableViewCellSelectionStyle.None
        
        self.titleLabel.text = habit.name
        refreshLabels()
        
        self.subtitleLabel.delegate = self
        
        if(date.beginningOfDay < NSDate()) { setupHandlers() }
        
        if habit.numCompletedIn(date) == habit.timesToComplete {
            instantComplete()
        }else{
            instantUncomplete()
        }
    }
    
    func refreshLabels() {
        self.bottomLabel.text = frequencyText()

        let unit:String
        switch habit.frequency {
        case .Daily:
            unit = "days"
        case .Weekly:
            unit = "weeks"
        case .Monthly:
            unit = "months"
        }
        
        let count = habit.currentStreak()
        var string = "\(count == 0 ? "No streak... yet!" : "\(count) \(unit) in a row!")"
        
        if count == 1 {string = "Solid start."}
        subtitleLabel.text = string
        
        let emoji:String
        switch(count) {
        case 0...1:
            emoji = ""
        case 2...5:
            emoji = "🔥"
        case 6...9:
            emoji = "⚡️"
        case 10...19:
            emoji = "✨"
        case 20...99:
            emoji = "🌟"
        default:
            emoji = "💯"
        }
        emojiLabel.text = emoji
    }
    
    func setupHandlers() {
        
        if(pgr == nil){
            pgr = UIPanGestureRecognizer(target: self, action: #selector(HabitHomeCell.handlePan(_:)))
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
        
        if !canSwipe {return}
        
        let distance = (UIScreen.mainScreen().bounds.width-70)/3
        let percent = borderView.frame.origin.x/(distance*3)
        
        if(recognizer.state == .Ended) {
            
            let wasComplete = habit.numCompletedIn(date) >= habit.timesToComplete
            
            if(percent > 0.3 && !wasComplete){ //
                complete()
            }else if(percent < 0.7 && wasComplete){
                uncomplete()
            }else if(percent < -0.3){
                uncomplete()
            }else{
                animateReturn()
            }
        }else{
            let translation = recognizer.translationInView(self)
            
            let wasComplete = habit.numCompletedIn(date) >= habit.timesToComplete
    
            if  wasComplete && percent < 0.3 && translation.x < 0 {
            }else if !wasComplete && percent > 0.7 && translation.x > 0 {
            }else if percent < -0.3 && translation.x < 0 {
            }else if borderView.frame.origin.x > (UIScreen.mainScreen().bounds.width - 70) && translation.x > 0{
            }else {
                borderView.frame.origin.x += translation.x
                
                let bgColor = color.hexString
                borderView.backgroundColor = UIColor(hexString: bgColor).darkenColor(Floats.darkenPercentage - Floats.darkenPercentage * Double(percent)).saturateColor(0.4 - 0.4 * Double(percent))
                recognizer.setTranslation(CGPointZero, inView: self)
            }
        }
    }
    
    func animateReturn() {
        
        if habit.numCompletedIn(date) == habit.timesToComplete {
            animateComplete()
        }else{
            animateUncomplete()
        }
    }
    
    func complete(){
        
        if !habitService.completeHabit(habit, on: date) {
            return
        }

        if habit.numCompletedIn(date) == habit.timesToComplete {
            animateComplete()
            Utilities.delay(0.7) {
                Utilities.postNotification(Notifications.reloadPulse,
                    data: self.habit.name, secondaryData: true)
            }
        }else{
            animateReturn()
            Utilities.postNotification(Notifications.reloadPulse)
        }
    }
    
    func instantComplete() {
        let moveTo = UIScreen.mainScreen().bounds.width - 70
        
        borderView.backgroundColor = color
        borderView.frame.origin.x = moveTo
        self.borderConstraint.constant = moveTo
        self.refreshLabels()
        
        checkmark.alpha = 1.0
        
        iv.tintColor = Colors.textSecondary
        
        self.titleLabel.textColor = Colors.textSecondary
        self.subtitleLabel.textColor = Colors.textSecondary
        self.bottomLabel.textColor = Colors.textSecondary
    }
    func animateComplete() {
        let moveTo = UIScreen.mainScreen().bounds.width - 70
        
        borderView.animation.makeX(moveTo).easeOut.makeBackground(color).animateWithCompletion(kAnimationLength) {
            self.borderConstraint.constant = moveTo
            self.refreshLabels()
        }
        
        checkmark.animation.makeAlpha(1.0).animate(kAnimationLength)
        
        iv.tintColor = Colors.textSecondary
        
        self.titleLabel.textColor = Colors.textSecondary
        self.subtitleLabel.textColor = Colors.textSecondary
        self.bottomLabel.textColor = Colors.textSecondary
    }
    
    func uncomplete() {
        
        if !habitService.incompleteHabit(habit, on: date) {
            animateReturn()
            return
        }
        
        if habit.numCompletedIn(date) + 1 == habit.timesToComplete {
            Utilities.delay(0.7) {
                Utilities.postNotification(Notifications.reloadPulse,
                    data: self.habit.name, secondaryData: false)
            }
        } else {
            Utilities.postNotification(Notifications.reloadPulse)
        }
        
        animateUncomplete()
    }
    
    func instantUncomplete() {
        borderView.backgroundColor = bgColor
        borderView.frame.origin.x = 14
        self.borderConstraint.constant = 14
        self.refreshLabels()
        
        checkmark.alpha = 0.0
        
        iv.tintColor = color
        
        self.titleLabel.textColor = Colors.textMain
        self.subtitleLabel.textColor = Colors.textSubtitle
        self.bottomLabel.textColor = Colors.textSubtitle
    }
    
    func animateUncomplete() {
        borderView.animation.makeX(14).easeInOut.makeBackground(bgColor).animateWithCompletion(kAnimationLength) {
            self.borderConstraint.constant = 14
            self.refreshLabels()
        }
        
        checkmark.animation.makeAlpha(0.0).animate(kAnimationLength)
        
        iv.tintColor = color
        
        self.titleLabel.textColor = Colors.textMain
        self.subtitleLabel.textColor = Colors.textSubtitle
        self.bottomLabel.textColor = Colors.textSubtitle
    }
    
    func frequencyText() -> String {
        let unit:String
        switch habit.frequency {
        case .Daily:
            unit = "today"
        case .Weekly:
            unit = "this week"
        case .Monthly:
            unit = "this month"
        }
        
        let number = habit.timesToComplete - habit.numCompletedIn(date)
        var text = "\(number > 1 ? "\(number) more times " : "Once more ")\(unit)"
        if(number == 0) {text = "Complete!"}
        
        return text
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let velocity = pgr?.velocityInView(self)
        return fabs(velocity!.y) < fabs(velocity!.x)
    }
    
    func doAppearance() {
        
        titleLabel.textColor = Colors.textMain
        titleLabel.font = Fonts.cellTitle
        subtitleLabel.textColor = Colors.textSubtitle
        subtitleLabel.font = Fonts.cellSubtitleBold
        
        bottomLabel.font = Fonts.cellSubtitle
        bottomLabel.textColor = Colors.textSubtitle
        
        let image = UIImage(named: habit.icon)
        iv.backgroundColor = UIColor.clearColor()
        iv.contentMode = .ScaleAspectFit
        iv.tintColor = color
        iv.image = image?.imageWithRenderingMode(.AlwaysTemplate)
        
        backgroundColor = UIColor.clearColor()
        
        self.borderView.backgroundColor = color
        
        checkmark.image = UIImage(named: "checkmark_large")?.imageWithRenderingMode(.AlwaysTemplate)
        checkmark.tintColor = Colors.background
        checkmark.alpha = 0.0
        
        borderView.layer.cornerRadius = Floats.cardCornerRadius
    }
}
