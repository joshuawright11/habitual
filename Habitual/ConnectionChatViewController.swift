//
//  ConnectionChatViewController.swift
//  Ignite
//
//  Created by Josh Wright on 11/18/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ConnectionChatViewController: JSQMessagesViewController {
    
    var connection:Connection!
    
    var outgoingBubbleImageData:JSQMessageBubbleImageDataSource!
    var incomingBubbleImageData:JSQMessageBubbleImageDataSource!
    
    var incomingAvatar:JSQMessagesAvatarImage!
    var outgoingAvatar:JSQMessagesAvatarImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        senderId = AuthManager.currentUser?.username
        senderDisplayName = AuthManager.currentUser?.username

        self.navigationItem.title = connection.user.name.componentsSeparatedByString(" ")[0]
        
        let bif = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageData = bif.outgoingMessagesBubbleImageWithColor(kColorRed)
        incomingBubbleImageData = bif.outgoingMessagesBubbleImageWithColor(kColorAccentSecondary)
    
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
        return JSQMessage(senderId: message.sender.username, displayName: message.sender.username, text: message.text)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {

        let message = connection.messages![indexPath.row]
        return message.sentByCurrentUser() ? incomingBubbleImageData : outgoingBubbleImageData
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
}
