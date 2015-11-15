//
//  UIAppearance+Swift.h
//  Ignite
//
//  Created by Josh Wright on 11/14/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

#import <UIKit/UIKit.h>

// UIAppearance+Swift.h
@interface UIView (UIViewAppearance_Swift)
// appearanceWhenContainedIn: is not available in Swift. This fixes that.
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end
