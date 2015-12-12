//
//  StatCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/16/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

/// A custom cell for displaying statistics about a `Habit` or `User`.
class StatCell: UITableViewCell {

    /// This should display the title of the statistic.
    @IBOutlet weak var titleLabel: UILabel! {
        didSet{
            titleLabel.font = kFontSectionHeader
            titleLabel.textColor = kColorTextMain
            selectionStyle = .None
        }
    }
    
    /// This should display the data of the statistic.
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet{
            descriptionLabel.font = kFontSectionHeader
            descriptionLabel.textColor = kColorAccentSecondary
        }
    }
    
    /// Takes a tuple and sets the first value to the statistic title label, and
    /// the second to the statistic data label.
    ///
    /// - parameter stat: A tuple consisting of two `String`s, the first of
    ///                   which should be the statistic title, the second of 
    ///                   which should be the statistic data. e.g. ("Most 
    ///                   completed Habit" : "Go for a run")
    func configure(stat: (String, String)) {
        titleLabel.text = stat.0
        descriptionLabel.text = stat.1
    }
}
