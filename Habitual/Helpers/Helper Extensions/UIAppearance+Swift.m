//
//  UIAppearance+Swift.m
//  Ignite
//
//  Created by Josh Wright on 11/14/15.
//  Copyright © 2015 Josh Wright. All rights reserved.
//

#import "UIAppearance+Swift.h"

// UIAppearance+Swift.m
@implementation UIView (UIViewAppearance_Swift)
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}
@end