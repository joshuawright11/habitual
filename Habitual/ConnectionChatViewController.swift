//
//  ConnectionChatViewController.swift
//  Ignite
//
//  Created by Josh Wright on 11/18/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Parse

class ConnectionChatViewController: JSQMessagesViewController {
    
    var connection:Connection!
    
    var outgoingBubbleImageData:JSQMessageBubbleImageDataSource!
    var incomingBubbleImageData:JSQMessageBubbleImageDataSource!
    var emptyBubbleImageData:JSQMessageBubbleImageDataSource!
    
    var incomingAvatar:JSQMessagesAvatarImage!
    var outgoingAvatar:JSQMessagesAvatarImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        senderId = AuthManager.currentUser?.username
        senderDisplayName = AuthManager.currentUser?.username

        self.navigationItem.title = connection.user.name.componentsSeparatedByString(" ")[0]
        
        let bif = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageData = bif.outgoingMessagesBubbleImageWithColor(kColorAccentSecondary)
        incomingBubbleImageData = bif.incomingMessagesBubbleImageWithColor(kColorGreen)
        emptyBubbleImageData = JSQMessagesBubbleImage(messageBubbleImage: UIImage(), highlightedImage: UIImage())
        
        doAppearance()
    }
    
    func doAppearance() {
        self.collectionView!.backgroundColor = kColorBackground.lightenByPercentage(0.02)
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
        self.collectionView?.collectionViewLayout.messageBubbleFont = kFontMessage
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pulse", style: .Plain, target: self, action: Selector("pulse"))
        
        self.inputToolbar!.contentView!.textView!.keyboardAppearance = .Dark;
        self.inputToolbar?.tintColor = kColorBackground
        self.inputToolbar?.contentView!.backgroundColor = kColorBackground
        self.inputToolbar?.contentView?.textView?.backgroundColor = kColorBackground.lightenByPercentage(0.03)
        
        let bt = self.inputToolbar?.contentView?.rightBarButtonItem!
        bt?.setTitleColor(kColorAccent, forState: .Normal)
        bt?.titleLabel?.font = kFontSectionHeader
        
        self.inputToolbar?.contentView?.leftBarButtonItem = nil
        
        let tf = self.inputToolbar!.contentView!.textView!
        tf.textColor = kColorTextMain
        tf.tintColor = kColorTextMain
        tf.font = kFontMessage
    }
    
    func pulse() {
        let uvc = storyboard?.instantiateViewControllerWithIdentifier("User") as! UserViewController
        uvc.user = connection.user
        
        let nav = UINavigationController(rootViewController: uvc)
        nav.modalTransitionStyle = .FlipHorizontal
        
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        let message = connection.messages![indexPath.row]
        if(message.habit == nil){
            return JSQMessage(senderId: message.sender.username, displayName: message.sender.username, text: message.text)
        }else{
            return JSQMessage(senderId: message.sender.username, displayName: message.sender.username, text: "")
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {

        let message = connection.messages![indexPath.row]
        if(message.habit == nil){
            return message.sentByCurrentUser() ? outgoingBubbleImageData : incomingBubbleImageData
        }else{
            return emptyBubbleImageData
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return  nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return connection.messages!.count
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        connection.sendMessage(text)
        finishSendingMessage()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        cell.cellTopLabel?.numberOfLines = 0
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = connection.messages![indexPath.row]
        return message.habit != nil ? attributedStringForHeaderWithMessage(message) : NSAttributedString(string: "jkkkfkds")
    }
    
    func attributedStringForHeaderWithMessage(message: Message) -> NSMutableAttributedString {

        let firstName = message.sender.name.componentsSeparatedByString(" ")[0]
        let habitName = message.habit!["name"] as! String
        let due = Utilities.monthDayStringFromDate(message.habit!["due"] as! NSDate)
        let goal = message.habit!["frequency"] as! String
        let timesMissed = "123"
        
        
        let string = NSMutableAttributedString(string: "\(firstName) missed \(habitName)\nDue: \(due), Goal: \(goal), Times Missed: \(timesMissed)", attributes: [NSFontAttributeName : kFontSecondaryLight])
        
        var location = firstName.characters.count + 8
        string.addAttribute(NSFontAttributeName, value: kFontSecondary, range: NSMakeRange(location,habitName.characters.count))
        location += (5 + habitName.characters.count)
        string.addAttribute(NSFontAttributeName, value: kFontSecondary, range: NSMakeRange(location,due.characters.count+1))
        location += 8 + due.characters.count
        string.addAttribute(NSFontAttributeName, value: kFontSecondary, range: NSMakeRange(location,goal.characters.count+1))
        location += 16 + goal.characters.count
        string.addAttribute(NSFontAttributeName, value: kFontSecondary, range: NSMakeRange(location,timesMissed.characters.count+1))
        
        return string
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let habit = connection.messages![indexPath.row].habit
        return habit != nil ? 40.0 : 0.0
    }
}
