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

// -TODO: Needs refactoring/documentation

class ConnectionChatController: JSQMessagesViewController, ServiceObserver {
    
    var connection:Connection!
    var accountService: AccountService!
    var connectionService: ConnectionService!
    
    var outgoingBubbleImageData:JSQMessageBubbleImageDataSource!
    var incomingBubbleImageData:JSQMessageBubbleImageDataSource!
    var emptyBubbleImageData:JSQMessageBubbleImageDataSource!
    var incomingAvatar:JSQMessagesAvatarImage!
    var outgoingAvatar:JSQMessagesAvatarImage!
    
    var layout:ConnectionChatViewFlowLayout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = accountService.currentUser else {
            fatalError("Yeaahhhhh... YA NEED A USER!")
        }
        
        connectionService.addConnectionServiceObserver(self)
        
        layout = ConnectionChatViewFlowLayout(connection: self.connection)
        
        self.collectionView!.collectionViewLayout = layout
        
        senderId = user.email
        senderDisplayName = user.name

        self.navigationItem.title = connectionService.otherUser(connection).name.componentsSeparatedByString(" ")[0]
        
        let bif = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageData = bif.outgoingMessagesBubbleImageWithColor(Colors.blue.colorWithAlphaComponent(0.7))
        incomingBubbleImageData = bif.incomingMessagesBubbleImageWithColor(Colors.purple.colorWithAlphaComponent(0.7))
        emptyBubbleImageData = JSQMessagesBubbleImage(messageBubbleImage: UIImage(), highlightedImage: UIImage())
        
        doAppearance()
    }
    
    func serviceDidUpdate() {
        self.collectionView.reloadData()
    }
    
    func doAppearance() {
        self.collectionView!.backgroundColor = Colors.background.lightenColor(0.02)
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
        self.collectionView?.collectionViewLayout.messageBubbleFont = Fonts.message
        
        scrollToBottomAnimated(false)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "tab_pulse")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: #selector(ConnectionChatController.pulse))
        
        self.inputToolbar!.contentView!.textView!.keyboardAppearance = .Dark;
        self.inputToolbar?.tintColor = Colors.background
        self.inputToolbar?.contentView!.backgroundColor = Colors.barBackground
        self.inputToolbar?.contentView?.textView?.backgroundColor = Colors.background
        
        let bt = self.inputToolbar?.contentView?.rightBarButtonItem!
        bt?.setTitleColor(Colors.accent, forState: .Normal)
        bt?.titleLabel?.font = Fonts.message
        
        self.inputToolbar?.contentView?.leftBarButtonItem = nil
        
        let tf = self.inputToolbar!.contentView!.textView!
        tf.textColor = Colors.textMain
        tf.tintColor = Colors.textMain
        tf.font = Fonts.message
    }
    
    func pulse() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        let message = connection.messages[indexPath.row]
        if(message.habit == nil){
            return JSQMessage(senderId: message.sender.email, displayName: message.sender.email, text: message.text)
        }else{
            return JSQMessage(senderId: message.sender.email, displayName: message.sender.email, text: "")
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {

        let message = connection.messages[indexPath.row]
        if(message.habit == nil){
            return message.sender.email == accountService.currentUser?.email ? outgoingBubbleImageData : incomingBubbleImageData
        }else{
            return emptyBubbleImageData
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return  nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return connection.messages.count
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        connectionService.message(connection, text: text!) { (success) in
            if !success {
                Utilities.alertError("There was an error sending the message :(", vc: self)
            }
        }
        finishSendingMessage()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        cell.cellTopLabel?.numberOfLines = 0
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = connection.messages[indexPath.row]
        return message.habit != nil ? attributedStringForHeaderWithMessage(message) : NSAttributedString(string: "0xdeadbeef")
    }
    
    func attributedStringForHeaderWithMessage(message: Message) -> NSMutableAttributedString {
        
        var firstName = message.sender.name.componentsSeparatedByString(" ")[0]
        if message.sender.email == accountService.currentUser?.email {firstName = "You"}

        let habitName = message.habit!.name
        let due = Utilities.monthDayStringFromDate(message.timeStamp - 1.day)
        let goal = message.habit!.frequency.toString()
//        let timesMissed = message.hab
//, Times Missed: \(timesMissed)
        
        let string = NSMutableAttributedString(string: "\(firstName) missed \(habitName)\nDue: \(due), Goal: \(goal)", attributes: [NSFontAttributeName : Fonts.secondaryLight])
        
        var location = firstName.characters.count + 8
        string.addAttribute(NSFontAttributeName, value: Fonts.secondaryBold, range: NSMakeRange(location,habitName.characters.count))
        location += (5 + habitName.characters.count)
        string.addAttribute(NSFontAttributeName, value: Fonts.secondaryBold, range: NSMakeRange(location,due.characters.count+1))
        location += 8 + due.characters.count
        string.addAttribute(NSFontAttributeName, value: Fonts.secondaryBold, range: NSMakeRange(location,goal.characters.count+1))
//        location += 16 + goal.characters.count
//        string.addAttribute(NSFontAttributeName, value: Fonts.Secondary, range: NSMakeRange(location,timesMissed.characters.count+1))
        
        return string
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let habit = connection.messages[indexPath.row].habit
        return habit != nil ? 40.0 : 0.0
    }
}
