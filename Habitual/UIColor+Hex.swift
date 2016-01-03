//
//  UIColor+Hex.swift
//  Ignite
//
//  Created by Josh Wright on 11/15/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

// -TODO: Needs refactoring/documentation

import DynamicColor

public extension UIColor
{
    var hexString:String {
        let colorRef = CGColorGetComponents(self.CGColor)
        
        let r:CGFloat = colorRef[0]
        let g:CGFloat = colorRef[1]
        let b:CGFloat = colorRef[2]
        
        return String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    }
    
    public func igniteDarken() -> UIColor {
        return self.darkenColor(Floats.darkenPercentage).desaturateColor(0.4)
    }
}
