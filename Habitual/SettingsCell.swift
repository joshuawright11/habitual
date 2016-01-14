//
//  SettingsCell.swift
//  Ignite
//
//  Created by Josh Wright on 1/1/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {

    static let reuseIdentifier = "settings"
    
    @IBOutlet weak var borderView: UIView! {
        didSet {
            borderView.layer.cornerRadius = 7
            borderView.backgroundColor = Colors.purple.igniteDarken()
            Styler.viewShaderSmall(borderView)
        }
    }
    
    @IBOutlet weak var iv: UIImageView! {
        didSet {
            iv.image = UIImage(named: "facebook")?.imageWithRenderingMode(.AlwaysTemplate)
            iv.tintColor = Colors.purple
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = Colors.textMain
            titleLabel.font = Fonts.cellTitle
        }
    }
}
