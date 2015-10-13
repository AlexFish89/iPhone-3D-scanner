/**
 * Copyright (C) 2012 13th Lab AB
 *
 * See the LICENSE file that came with this example code.
 */

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;
@synthesize cameraViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {        
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

	self.cameraViewController = [[HardwareController alloc] initWithNibName:nil bundle:nil];
	[window addSubview:[self.cameraViewController view]];
    	
    [window makeKeyAndVisible];
    

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[cameraViewController stopGraphics];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[cameraViewController startGraphics];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
}

- (void)dealloc {
	[cameraViewController release];
    [window release];
    [super dealloc];
}


@end
