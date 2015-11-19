//
//  StatCell.swift
//  Ignite
//
//  Created by Josh Wright on 11/16/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class StatCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configure(stat: (String, String)) {
        
        titleLabel.text = "DUCKS"
        descriptionLabel.text = "DUCKS"
        selectionStyle = .None
        
        doAppearance()
    }
    
    func doAppearance() {
        titleLabel.font = kFontSectionHeader
        titleLabel.textColor = kColorTextMain
        
        descriptionLabel.font = kFontSectionHeader
        descriptionLabel.textColor = kColorAccentSecondary
    }
}
