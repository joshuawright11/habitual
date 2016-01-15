//
//  SocialUserCell.swift
//  Ignite
//
//  Created by Josh Wright on 12/30/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit

class SocialUserCell: UITableViewCell {

    @IBOutlet weak var iv: UIImageView! {
        didSet {
            iv.layer.cornerRadius = 25
            iv.backgroundColor = Colors.gray
            iv.clipsToBounds = true
            Styler.viewShaderSmall(iv)
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = Fonts.cellTitle
            titleLabel.textColor = Colors.textMain
        }
    }
    
    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = Fonts.cellSubtitle
            subtitleLabel.textColor = Colors.textMain
        }
    }
    
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.backgroundColor = Colors.accentSecondary
            button.titleLabel?.font = Fonts.cellSubtitle
            button.tintColor = Colors.textMain
            button.layer.cornerRadius = 7
            Styler.viewShaderSmall(button)
        }
    }
    
    @IBOutlet weak var borderView: UIView! {
        didSet {
            borderView.layer.cornerRadius = 7
            borderView.backgroundColor = Colors.purple.igniteDarken()
            Styler.viewShaderSmall(borderView)
        }
    }
    
    var user: SocialMediaUser! {
        didSet {
            titleLabel.text = user.name
            subtitleLabel.text = user.id
            iv.imageFromURL(user.imageURL)
        }
    }
}
