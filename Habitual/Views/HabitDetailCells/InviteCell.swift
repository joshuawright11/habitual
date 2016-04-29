//
//  InviteCell.swift
//  Ignite
//
//  Created by Josh Wright on 1/1/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import UIKit

class InviteCell: UITableViewCell {
    
    static let height = CGFloat(102)
    static let reuseID = "Invite"
    
    @IBOutlet weak var fbView: UIView!  {
        didSet {
            fbView.layer.cornerRadius = 7
            fbView.backgroundColor = Colors.blue
            Styler.viewShader(fbView)
        }
    }
    @IBOutlet weak var twitterView: UIView! {
        didSet {
            twitterView.layer.cornerRadius = 7
            twitterView.backgroundColor = Colors.accentSecondary
            Styler.viewShader(twitterView)
        }
    }
    @IBOutlet weak var emailView: UIView! {
        didSet {
            emailView.layer.cornerRadius = 7
            emailView.backgroundColor = Colors.orange
            Styler.viewShader(emailView)
        }
    }
    @IBOutlet weak var textView: UIView! {
        didSet {
            textView.layer.cornerRadius = 7
            textView.backgroundColor = Colors.green
            Styler.viewShader(textView)
        }
    }

    @IBOutlet weak var fbiv: UIImageView! {
        didSet {
            fbiv.image = UIImage(named: "facebook")?.imageWithRenderingMode(.AlwaysTemplate)
            fbiv.tintColor = Colors.barBackground
        }
    }
    @IBOutlet weak var twitteriv: UIImageView! {
        didSet {
            twitteriv.image = UIImage(named: "twitter")?.imageWithRenderingMode(.AlwaysTemplate)
            twitteriv.tintColor = Colors.barBackground
        }
    }
    @IBOutlet weak var emailiv: UIImageView! {
        didSet {
            emailiv.image = UIImage(named: "email_circle")?.imageWithRenderingMode(.AlwaysTemplate)
            emailiv.tintColor = Colors.barBackground
        }
    }
    @IBOutlet weak var textiv: UIImageView! {
        didSet {
            textiv.image = UIImage(named: "chats")?.imageWithRenderingMode(.AlwaysTemplate)
            textiv.tintColor = Colors.barBackground
        }
    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = Colors.textMain
            titleLabel.font = Fonts.sectionHeader
            titleLabel.text = "find or invite someone new via"
            selectionStyle = .None
        }
    }

}
