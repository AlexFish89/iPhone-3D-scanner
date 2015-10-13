//
//  UIView+buttons.h
//  PointCloudSample
//
//  Created by admin on 11/12/12.
//  Copyright (c) 2012 13th Lab AB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum UIViewButtonLocation {
    TopLeft,
    TopRight,
    BottomLeft,
    BottomRight
} UIViewButtonLocation;

@interface UIView (buttons) <UIGestureRecognizerDelegate>

- (void) addExitButton:(UIViewButtonLocation) location withSize:(NSUInteger)buttonSize;

@end
