//
//  ConnectionChatViewFlowLayout.swift
//  Ignite
//
//  Created by Josh Wright on 12/6/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class ConnectionChatViewFlowLayout: JSQMessagesCollectionViewFlowLayout {
   
    let connection: Connection?
    
    init(connection: Connection) {
        self.connection = connection
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        connection = nil
        super.init(coder: aDecoder)
    }
    
    override func messageBubbleSizeForItemAtIndexPath(indexPath: NSIndexPath!) -> CGSize {
        var size = super.messageBubbleSizeForItemAtIndexPath(indexPath)
        if(connection?.messages![indexPath.row].habit != nil){ size.height = 1 }
        return size
    }
}
