//
//  UIView+buttons.m
//  PointCloudSample
//
//  Created by admin on 11/12/12.
//  Copyright (c) 2012 13th Lab AB. All rights reserved.
//

#import "UIView+buttons.h"

@implementation UIView (buttons)

- (void)exitButtonPushed {
    [self removeFromSuperview];
}

- (void) addExitButton:(UIViewButtonLocation)location withSize:(NSUInteger)buttonSize {
    // create button
    UIButton* exitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    switch (location) {
        case TopLeft:
            exitButton.frame =
                CGRectMake(self.bounds.origin.x, self.bounds.origin.y, buttonSize, buttonSize);
            break;
        case TopRight:
            exitButton.frame =
                CGRectMake(self.bounds.origin.x + self.bounds.size.width - buttonSize, self.bounds.origin.y, buttonSize, buttonSize);
            break;
        case BottomLeft:
            exitButton.frame =
                CGRectMake(self.bounds.origin.x, self.bounds.origin.y + self.bounds.size.height - buttonSize, buttonSize, buttonSize);
            break;
        case BottomRight:
            exitButton.frame =
                CGRectMake(self.bounds.origin.x + self.bounds.size.width - buttonSize, self.bounds.origin.y + self.bounds.size.height - buttonSize, buttonSize, buttonSize);
            break;
        default:
            break;
    }
    [exitButton addTarget:self action:@selector(exitButtonPushed) forControlEvents:UIControlEventTouchUpInside];
    [exitButton setTitle:@"X" forState:UIControlStateNormal];
    [exitButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self addSubview:exitButton];
}


@end
