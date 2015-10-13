/**
 * Copyright (C) 2012 13th Lab AB
 *
 * See the LICENSE file that came with this example code.
 */ 

#import <UIKit/UIKit.h>
#import "HardwareController.h"

@class HardwareController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	HardwareController *cameraViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) HardwareController *cameraViewController;

@end

