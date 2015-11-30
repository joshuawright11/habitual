//
//  IconCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class IconCell: UITableViewCell, HabitDetailCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet var iconivs: [UIImageView]!
    var habit:Habit?
    
    var dict: [UIImageView: UITapGestureRecognizer] = [UIImageView: UITapGestureRecognizer]()
    
    var selectediv: UIImageView?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func doAppearance() {
        selectionStyle = UITableViewCellSelectionStyle.None
        titleLabel.font = kFontSectionHeader
        titleLabel.textColor = kColorTextMain
        
        var count = 0
        for iv in iconivs {
            iv.backgroundColor = UIColor.clearColor()
            iv.contentMode = .ScaleAspectFit
            iv.layer.cornerRadius = 5.0
            
            
            if let gr = dict[iv] {
                iv.removeGestureRecognizer(gr)
            }
            
            let tgr = UITapGestureRecognizer(target: self, action: Selector("tapped:"))
            iv.userInteractionEnabled = true
            iv.addGestureRecognizer(tgr)
            dict[iv] = tgr
            
            let path = iIconList[count%iIconList.count]
            let image = UIImage(named: path)
            
            count++
            
            iv.image = image?.imageWithRenderingMode(.AlwaysTemplate)
            iv.tintColor = kColorArray[count%6]
            
            iv.accessibilityIdentifier = path
        }
        
    }
    
    func tapped(tgr: UITapGestureRecognizer) {
        let iv = tgr.view as! UIImageView
        habit?.icon = iv.accessibilityIdentifier!
        
        if let selectediv = selectediv {
            selectediv.backgroundColor = kColorBackground
        }
        
        iv.backgroundColor = UIColor(hexString: kColorAccentSecondary.hexString, withAlpha: 0.4)
        
        selectediv = iv
    }
    
    func configure(habit: Habit) {
        self.habit = habit
        doAppearance()
        
        for iv in iconivs {
            if iv.accessibilityIdentifier == habit.icon{
                selectediv = iv
                iv.backgroundColor = UIColor(hexString: kColorAccentSecondary.hexString, withAlpha: 0.4)
            }
        }
    }
}
