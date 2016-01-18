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
            subtitleLabel.text = "Member since \(Utilities.monthYearStringFromDate(user.parseObject!.createdAt!))"
            let id = user.parseObject!["fbId"]
            if oldValue == nil || oldValue.username != user.username {
                iv.image = UIImage()
                if let id = id as? String {
                    iv.imageFromURL("https://graph.facebook.com/\(id)/picture?type=large")
                }
                if AuthManager.currentUser!.connections.map({$0.user.username})
                    .contains(user.username) {
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
        didSet {
            borderView.backgroundColor = color.igniteDarken().lightenColor(0.07)
        }
    }
    
    @IBAction func connectPressed() {
        AuthManager.currentUser?.addConnection(self.user.username, callback: { (success) -> () in
            if success {
                self.button.setTitle("Sent", forState: .Normal)
                self.button.enabled = false
            }
        })
    }
}
