//
//  UIImage+AsyncDownload.swift
//  Ignite
//
//  Created by Josh Wright on 1/14/16.
//  Copyright © 2016 Josh Wright. All rights reserved.
//

import Foundation

public extension UIImageView {
    public func imageFromURL(url: String) {
        if let url = NSURL(string: url) {
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
                if let imageData = data as NSData? {
                    self.image = UIImage(data: imageData)
                }
            })
        }
    }
}
