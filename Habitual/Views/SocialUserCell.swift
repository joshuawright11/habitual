//
//  SocialUserCell.swift
//  Ignite
//
//  Created by Josh Wright on 12/30/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import Parse

class SocialUserCell: UITableViewCell {

    @IBOutlet weak var iv: UIImageView! {
        didSet {
            iv.layer.cornerRadius = 25
            iv.backgroundColor = Colors.gray
            iv.clipsToBounds = true
            iv.contentMode = .ScaleAspectFill
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
            button.titleLabel?.font = Fonts.cellSubtitleBold
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
    
    var user: User! {
        didSet {
            titleLabel.text = user.name
            subtitleLabel.text = "Member since \(Utilities.monthYearStringFromDate(user.joined))"
            let url = user.profileImageURL
            if oldValue == nil || oldValue.email != user.email {
                iv.image = UIImage()
                if let url = url {
                    iv.imageFromURL(url)
                }
                
                if connectClosure == nil {
                    button.setTitle("Sent", forState: .Normal)
                    button.enabled = false
                } else {
                    button.setTitle("Connect", forState: .Normal)
                    button.enabled = true
                }
            }
        }
    }
    
    var color: UIColor! {
        didSet {borderView.backgroundColor = color.igniteDarken().lightenColor(0.07)}
    }
    
    var connectClosure: ((user: User) -> ())?

    func configureForUser(user: User, color: UIColor, connectClosure: ((user: User)->())?) {
        self.user = user
        self.color = color
        self.connectClosure = connectClosure
    }
    
    @IBAction func connectPressed() {
        connectClosure?(user: user)
        button.setTitle("Sent", forState: .Normal)
        button.enabled = false
    }
}
