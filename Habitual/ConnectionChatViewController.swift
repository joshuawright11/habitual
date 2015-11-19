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
    
    var user:User!
    
    var outgoingBubbleImageData:JSQMessageBubbleImageDataSource!
    var incomingBubbleImageData:JSQMessageBubbleImageDataSource!
    
    var incomingAvatar:JSQMessagesAvatarImage!
    var outgoingAvatar:JSQMessagesAvatarImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        senderId = "josh"
        senderDisplayName = "Josh"
        
        self.navigationItem.title = user.username
        
        self.collectionView!.backgroundColor = kColorBackground.lightenByPercentage(0.02)
        
        let bif = JSQMessagesBubbleImageFactory()
        
        outgoingBubbleImageData = bif.outgoingMessagesBubbleImageWithColor(kColorRed)
        incomingBubbleImageData = bif.outgoingMessagesBubbleImageWithColor(kColorAccentSecondary)
        
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pulse", style: .Plain, target: self, action: Selector("pulse"))
        
        self.inputToolbar!.contentView!.textView!.keyboardAppearance = .Dark;

        self.inputToolbar?.tintColor = kColorBackground

        self.inputToolbar?.contentView!.backgroundColor = kColorBackground
        self.inputToolbar?.contentView?.textView?.backgroundColor = kColorBackground.lightenByPercentage(0.03)
        
        let bt = self.inputToolbar?.contentView?.rightBarButtonItem!
        bt?.setTitleColor(kColorAccent, forState: .Normal)
        bt?.titleLabel?.font = kFontSectionHeader
        
        let tf = self.inputToolbar!.contentView!.textView!
        
        tf.textColor = kColorTextMain
        tf.tintColor = kColorTextMain
        tf.font = kFontSectionHeader
        
    }
    
    func pulse() {
        let uvc = storyboard?.instantiateViewControllerWithIdentifier("User") as! UserViewController
        uvc.user = user
        
        let nav = UINavigationController(rootViewController: uvc)
        nav.modalTransitionStyle = .FlipHorizontal
        
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return JSQMessage(senderId: senderId, displayName: "Josh", text: "Hello")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        return incomingBubbleImageData
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return  nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
}
