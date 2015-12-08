//
//  ConnectionChatViewController.swift
//  Ignite
//
//  Created by Josh Wright on 11/18/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Timepiece

class ConnectionChatViewController: JSQMessagesViewController {
    
    var connection:Connection!
    
    var outgoingBubbleImageData:JSQMessageBubbleImageDataSource!
    var incomingBubbleImageData:JSQMessageBubbleImageDataSource!
    var emptyBubbleImageData:JSQMessageBubbleImageDataSource!
    
    var incomingAvatar:JSQMessagesAvatarImage!
    var outgoingAvatar:JSQMessagesAvatarImage!
    
    var layout:ConnectionChatViewFlowLayout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout = ConnectionChatViewFlowLayout(connection: self.connection)
        
        self.collectionView!.collectionViewLayout = layout
        
        Utilities.registerForNotification(self, selector: "chatReceived", name: kNotificationChatReceived)
        
        senderId = AuthManager.currentUser?.username
        senderDisplayName = AuthManager.currentUser?.username

        self.navigationItem.title = connection.user.name.componentsSeparatedByString(" ")[0]
        
        let bif = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageData = bif.outgoingMessagesBubbleImageWithColor(kColorBlue.colorWithAlphaComponent(0.7))
        incomingBubbleImageData = bif.incomingMessagesBubbleImageWithColor(kColorPurple.colorWithAlphaComponent(0.7))
        emptyBubbleImageData = JSQMessagesBubbleImage(messageBubbleImage: UIImage(), highlightedImage: UIImage())
        
        doAppearance()
    }
    
    func chatReceived() {
        self.connection.loadMessages { (success) -> () in
            if success {
                self.collectionView?.reloadData()
                Utilities.postNotification(kNotificationIdentifierReloadConnectionsOffline)
                JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                self.scrollToBottomAnimated(true)
            }else{
                print("error :(")
            }
        }
    }
    
    func doAppearance() {
        self.collectionView!.backgroundColor = kColorBackground.lightenByPercentage(0.02)
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
        self.collectionView?.collectionViewLayout.messageBubbleFont = kFontMessage
        
        scrollToBottomAnimated(false)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pulse", style: .Plain, target: self, action: Selector("pulse"))
        
        self.inputToolbar!.contentView!.textView!.keyboardAppearance = .Dark;
        self.inputToolbar?.tintColor = kColorBackground
        self.inputToolbar?.contentView!.backgroundColor = kColorBackground
        self.inputToolbar?.contentView?.textView?.backgroundColor = kColorBackground.lightenByPercentage(0.03)
        
        let bt = self.inputToolbar?.contentView?.rightBarButtonItem!
        bt?.setTitleColor(kColorAccent, forState: .Normal)
        bt?.titleLabel?.font = kFontMessage
        
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
            return message.sentByCurrentUser ? outgoingBubbleImageData : incomingBubbleImageData
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
        Utilities.postNotification(kNotificationIdentifierReloadConnectionsOffline)
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
        return message.habit != nil ? attributedStringForHeaderWithMessage(message) : NSAttributedString(string: "0xdeadbeef")
    }
    
    func attributedStringForHeaderWithMessage(message: Message) -> NSMutableAttributedString {
        
        var firstName = message.sender.name.componentsSeparatedByString(" ")[0]
        if message.sender.username == AuthManager.currentUser?.username {firstName = "You"}

        let habitName = message.habit!["name"] as! String
        let due = Utilities.monthDayStringFromDate(message.timeStamp - 1.day)
        let goal = message.habit!["frequency"] as! String
//        let timesMissed = message.hab
//, Times Missed: \(timesMissed)
        
        let string = NSMutableAttributedString(string: "\(firstName) missed \(habitName)\nDue: \(due), Goal: \(goal)", attributes: [NSFontAttributeName : kFontSecondaryLight])
        
        var location = firstName.characters.count + 8
        string.addAttribute(NSFontAttributeName, value: kFontSecondaryBold, range: NSMakeRange(location,habitName.characters.count))
        location += (5 + habitName.characters.count)
        string.addAttribute(NSFontAttributeName, value: kFontSecondaryBold, range: NSMakeRange(location,due.characters.count+1))
        location += 8 + due.characters.count
        string.addAttribute(NSFontAttributeName, value: kFontSecondaryBold, range: NSMakeRange(location,goal.characters.count+1))
//        location += 16 + goal.characters.count
//        string.addAttribute(NSFontAttributeName, value: kFontSecondary, range: NSMakeRange(location,timesMissed.characters.count+1))
        
        return string
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let habit = connection.messages![indexPath.row].habit
        return habit != nil ? 40.0 : 0.0
    }
}
