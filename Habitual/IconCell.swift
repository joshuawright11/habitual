//
//  IconCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

/// A cell representing the icon of the `Habit`.
class IconCell: HabitDetailCell {
    
    /// The `UIImageViews` representing the possible icons a `Habit` could have.
    ///
    /// - Note: Each `UIImageView` has their image path in their 
    ///         `accessibilityIdentifier` property.
    @IBOutlet var iconivs: [UIImageView]! {
        didSet {
            var count = 0
            for iv in iconivs {
                iv.backgroundColor = UIColor.clearColor()
                iv.contentMode = .ScaleAspectFit
                iv.layer.cornerRadius = 5.0
                iv.userInteractionEnabled = true
                
                let path = iIconList[count%iIconList.count]
                let image = UIImage(named: path)
                iv.image = image?.imageWithRenderingMode(.AlwaysTemplate)
                iv.tintColor = kColorArray[count%6]
                iv.accessibilityIdentifier = path
                
                if let gr = dict[iv] { iv.removeGestureRecognizer(gr) }
                let tgr = UITapGestureRecognizer(target: self, action: Selector("tapped:"))
                iv.addGestureRecognizer(tgr)
                dict[iv] = tgr
                
                count += 1
            }
        }
    }
    
    /// A dictionary linking each of the `UIImageView`s with their corresponding
    /// `UITapGestureRecognizer`. Used for making sure that multiple gesture 
    /// recognizers aren't added to the same image view.
    var dict: [UIImageView: UITapGestureRecognizer] = [UIImageView: UITapGestureRecognizer]()
    
    /// The `UIImageView` representing the current icon of the `Habit`.
    var selectediv: UIImageView? {
        willSet {
            if let selectediv = selectediv {
                selectediv.backgroundColor = kColorBackground
            }
        }
        
        didSet {
            selectediv?.backgroundColor = UIColor(hexString: kColorAccentSecondary.hexString, withAlpha: 0.4)
        }
    }
    
    // ********************************
    // MARK: - HabitDetailCell Override
    // ********************************
    
    override func configure() {
        for iv in iconivs {
            if iv.accessibilityIdentifier == habit.icon {
                selectediv = iv
                iv.backgroundColor = UIColor(hexString: kColorAccentSecondary.hexString, withAlpha: 0.4)
            }
        }
    }

    // ***************
    // MARK: - Targets
    // ***************
    
    /// When a `UIImageView` is tapped, set the icon of the `Habit`.
    func tapped(tgr: UITapGestureRecognizer) {
        selectediv = tgr.view as? UIImageView
        habit?.icon = selectediv!.accessibilityIdentifier!
    }
}
