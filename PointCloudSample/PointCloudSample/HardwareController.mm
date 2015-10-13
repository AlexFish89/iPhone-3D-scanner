/**
 * Copyright (C) 2012 13th Lab AB
 *
 * See the LICENSE file that came with this example code.
 */

#import "HardwareController.h"
#include "TestApp.h"

#import <AVFoundation/AVCaptureOutput.h>
#import <CoreVideo/CVPixelBuffer.h>
#import "UIImage+conversions.h"

@implementation HardwareController

@synthesize captureSession;
@synthesize glView;
@synthesize pixelBuffer;
@synthesize motionManager;
@synthesize g_scale;
@synthesize restartingCamera;
@synthesize accelerometer_available;
@synthesize device_motion_available;
@synthesize pointcloudApplication;
@synthesize meshView;
@synthesize demoView;

- (void)startCamera {
    [self.captureSession startRunning];
	restartingCamera = NO;
}

- (void) restartCamera {
	if (self.restartingCamera)
		return;
	
	restartingCamera = YES;
	
	if ([self.captureSession isRunning])
		[self.captureSession stopRunning];
	
	[self startCamera];
}

-(void)eventHandler:(id)data {
    if ([[data name] isEqualToString:@"AVCaptureSessionRuntimeErrorNotification"]) {
		[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(restartCamera) userInfo:nil repeats:NO];
    } else if ([[data name] isEqualToString:@"AVCaptureSessionInterruptionEndedNotification"]) {
        [self.captureSession startRunning];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {		
		[self.view setFrame:[[UIScreen mainScreen] bounds]];
    }
	
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.restartingCamera = NO;
	self.accelerometer_available = NO;
	self.device_motion_available = NO;
	
	[UIApplication sharedApplication].statusBarHidden = NO;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack; 
		
	CGRect rect = [[UIScreen mainScreen] bounds];
	
	self.glView = [[GLView alloc] initWithFrame:rect];
	
	[self.glView.window setFrame:rect];
	
	[self.glView setFrame:[[UIScreen mainScreen] applicationFrame]];
    
    // Double the resolution on iPhone 4 and 4s etc.
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        self.g_scale = [UIScreen mainScreen].scale;
    } else {
        self.g_scale = 1.0f;
    }
    
    if ([self.glView respondsToSelector:@selector(setContentScaleFactor:)])
    {
        [self.glView setContentScaleFactor: g_scale];
    }
	
	[glView setDelegate:self];
    glView.multipleTouchEnabled = YES;
	[self setView:glView];
	
	[self initCapture];
	
	self.motionManager = [[CMMotionManager alloc] init];
	
	if (self.motionManager.accelerometerAvailable) {
		accelerometer_available = true;
		[self.motionManager startAccelerometerUpdates];
	}
	
	if (self.motionManager.deviceMotionAvailable) {
		device_motion_available = true;
		[self.motionManager startDeviceMotionUpdates];
	}
    
    // Find the path to the documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *picturesDirectory = [documentsDirectory stringByAppendingPathComponent:@"Snapshots"];
    NSString *matricesDirectory = [documentsDirectory stringByAppendingPathComponent:@"Matrices"];
    
    // Create directories
    if ([[NSFileManager defaultManager] fileExistsAtPath:picturesDirectory]) {
        [[NSFileManager defaultManager] removeItemAtPath:picturesDirectory error:nil];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:matricesDirectory]) {
        [[NSFileManager defaultManager] removeItemAtPath:matricesDirectory error:nil];
    }
    
    [[NSFileManager defaultManager] createDirectoryAtPath:picturesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:matricesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
}

- (MeshView *)meshView {
    if (meshView == nil) {
        meshView = [[MeshView alloc] init];
    }
    meshView.bBox = pointcloudApplication->getCube();
    return meshView;
}

- (MeshView *)demoView {
    if (demoView == nil) {
        demoView = [[MeshView alloc] init];
    }
    [demoView makeDemo];
    return demoView;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint pt = [[touches anyObject] locationInView:self.glView];
	if (pointcloudApplication) {
		pointcloudApplication->on_touch_moved(pt.x, pt.y);
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint pt = [[touches anyObject] locationInView:self.glView];
	if (pointcloudApplication) {
		pointcloudApplication->on_touch_ended(pt.x, pt.y);
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIActionSheet *sheet;
	CGPoint pt = [[touches anyObject] locationInView:self.glView];
	if (pointcloudApplication) {
		pointcloudApplication->on_touch_started(pt.x, pt.y);
        // Go to MeshView
        if (pointcloudApplication->get_mesh_flag()) {
            pointcloudApplication->unset_mesh_flag();
            sheet = [[UIActionSheet alloc] initWithTitle:@"Show Mesh?"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"Lets go!",nil];
            sheet.tag = 10;
            [sheet showInView:self.view];
            [sheet release];
        } //Go to demoView
        else if (pointcloudApplication->get_demo_flag()) {
            pointcloudApplication->unset_demo_flag();
            sheet = [[UIActionSheet alloc] initWithTitle:@"Create dinosaur from?"
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:@"Silhouettes", @"Original images",nil];
            sheet.tag = 20;
            [sheet showInView:self.view];
            [sheet release];
        }
	}
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint pt = [[touches anyObject] locationInView:self.glView];
	if (pointcloudApplication) {
		pointcloudApplication->on_touch_cancelled(pt.x, pt.y);
	}	
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case 10:
            if (buttonIndex == 0) {
                [self presentViewController:self.meshView animated:YES completion:nil];
            }
            break;
        case 20:
            if (buttonIndex == 2) {
                break;
            }
            self.demoView.silhouettes = !buttonIndex;
            [self presentViewController:self.demoView animated:YES completion:nil];
            break;
        default:
            break;
    }
}


#import <sys/utsname.h>

struct utsname systemInfo;

const char*
machineName()
{
    uname(&systemInfo);
	
    return systemInfo.machine;
}

- (void)startGraphics {
	if (pointcloudApplication)
		pointcloudApplication->on_resume();
}

- (void)stopGraphics {
	if (pointcloudApplication)
		pointcloudApplication->on_pause();
}

- (void)drawView:(GLView*)view {
	CVReturn lockResult = CVPixelBufferLockBaseAddress (self.pixelBuffer, 0);
	if(lockResult == kCVReturnSuccess) {
		if (accelerometer_available) {
			if (!motionManager.accelerometerActive)
				[motionManager startAccelerometerUpdates];
			
			CMAccelerometerData *accelerometerData = motionManager.accelerometerData;
			if (accelerometerData) {
				CMAcceleration acceleration = accelerometerData.acceleration;
				
				pointcloudApplication->on_accelerometer_update(acceleration.y, acceleration.x, acceleration.z);
			}
		}
		if (device_motion_available) {
			if (!motionManager.deviceMotionActive)
				[motionManager startDeviceMotionUpdates];
			
			CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
			if (deviceMotion) {
				CMAcceleration device_acceleration = deviceMotion.userAcceleration;
				CMRotationRate device_rotation_rate = deviceMotion.rotationRate;
				
				pointcloudApplication->on_device_motion_update(device_acceleration.y, 
															   device_acceleration.x,
															   device_acceleration.z,
															   device_rotation_rate.y, 
															   device_rotation_rate.x, 
															   device_rotation_rate.z);
			}
		}
		
		char* ba = (char*)CVPixelBufferGetBaseAddress(self.pixelBuffer);
        //toggle gesture recognizer
        pointcloud_state state = pointcloud_get_state();
        if (state == POINTCLOUD_TRACKING_SLAM_MAP || state == POINTCLOUD_TRACKING_IMAGES) {
            for (UIGestureRecognizer *recognizer in [self.view gestureRecognizers]) {
                recognizer.enabled = YES;
            }
        } else {
            for (UIGestureRecognizer *recognizer in [self.view gestureRecognizers]) {
                recognizer.enabled = NO;
            }
        }
        //
		pointcloudApplication->render_frame(ba, CVPixelBufferGetDataSize(self.pixelBuffer));
		
		CVPixelBufferUnlockBaseAddress (self.pixelBuffer, 0);
		return;
	}
}

//Gesture functions
- (void) updateGLViewR:(UIGestureRecognizer *)recognizer {
    [self drawView:(GLView *)(recognizer.delegate)];
}

- (void) addGestureRecognizers:(UIView *)targetView {
    /*
     Create and configure the recognizers. Add each to the view as a gesture recognizer.
     */
    UIGestureRecognizer *recognizer;
    //Pan
    recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [recognizer addTarget:self action:@selector(updateGLViewR:)];
    [(UIPanGestureRecognizer*)recognizer setMaximumNumberOfTouches:2];
    [(UIPanGestureRecognizer*)recognizer setDelegate:(id<UIGestureRecognizerDelegate>)targetView];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
    //Pinch
    recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
    [recognizer addTarget:self action:@selector(updateGLViewR:)];
    [recognizer setDelegate:(id<UIGestureRecognizerDelegate>)targetView];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
}

-(void)handlePinchFrom:(UIPinchGestureRecognizer *)pinchRecognizer  {
    if ([pinchRecognizer state] == UIGestureRecognizerStateBegan) {
        //locationInView:view returns the center point of the touches
        GestureData.startTouchPositionTwoFingers = [pinchRecognizer locationInView:self.view];
        [pinchRecognizer setScale:1];
        return;
    } else if ([pinchRecognizer state] == UIGestureRecognizerStateEnded) {
        return;
    }
    GestureData.startTouchPositionTwoFingers = [pinchRecognizer locationInView:self.view];
    pointcloudApplication->resizeCube([pinchRecognizer scale]);
    [pinchRecognizer setScale:1];
}

-(void)handlePanFrom:(UIPanGestureRecognizer *)panRecognizer  {
    if ([panRecognizer numberOfTouches] == 1) {
        if ([panRecognizer state] == UIGestureRecognizerStateBegan) {
            GestureData.startTouchPositionOneFinger = [panRecognizer locationInView:self.view];
            return;
        } else if ([panRecognizer state] == UIGestureRecognizerStateEnded) {
            return;
        }
        CGPoint point = [panRecognizer locationInView:self.view];
        float vecX = (point.x - GestureData.startTouchPositionOneFinger.x) / self.view.frame.size.width;
        float vecY = (point.y - GestureData.startTouchPositionOneFinger.y) / self.view.frame.size.height;
        pointcloudApplication->moveCubeCorner(vecY, vecX, 0.0f);
        GestureData.startTouchPositionOneFinger = point;
     }
    else if ([panRecognizer numberOfTouches] == 2) {
        if ([panRecognizer state] == UIGestureRecognizerStateBegan) {
            GestureData.startTouchPositionTwoFingers = [panRecognizer locationInView:self.view];
            return;
        } else if ([panRecognizer state] == UIGestureRecognizerStateEnded) {
            return;
        }
        CGPoint point = [panRecognizer locationInView:self.view];

        float vecY = (point.y - GestureData.startTouchPositionTwoFingers.y) / self.view.frame.size.height;
        pointcloudApplication->moveCubeCorner(0.0f, 0.0f, vecY);
        GestureData.startTouchPositionTwoFingers = point;
    }
}


-(void)setupView:(GLView*)view {
    [self addGestureRecognizers:view];
}

- (void)initCapture {
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		
	self.captureSession = [[AVCaptureSession alloc] init];
		
	NSArray *arr = [AVCaptureDevice devices];
	
	AVCaptureDevice *device = nil;
	NSError *outError = nil;

    for(int i=0; i<[arr count] && device == nil; i++) {
        AVCaptureDevice *d = [arr objectAtIndex:i];
		if (d.position == AVCaptureDevicePositionBack && [d hasMediaType: AVMediaTypeVideo]) {
			device = d;
		}
    }
	
	if (device == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No camera found" 
														message:@"You need a device with a back-facing camera to run this app." 
													   delegate:self 
											  cancelButtonTitle:@"Quit"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
    	
	AVCaptureFocusMode wantedFocusMode = AVCaptureFocusModeContinuousAutoFocus;
    
	if ([device isFocusModeSupported: wantedFocusMode]) {
		if ([device lockForConfiguration: &outError]) {
			[device setFocusMode: wantedFocusMode];
			[device unlockForConfiguration];
		} else {
			NSLog(@"lockForConfiguration ERROR: %@", outError);
		}
	}
	
    AVCaptureDeviceInput *devInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&outError];
    
    if (!devInput) {
        NSLog(@"ERROR: %@",outError);
        return;
    }
        	
	if (device == nil) {
		NSLog(@"Device is nil");
	}
	
	AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    output.alwaysDiscardsLateVideoFrames = YES;
    
    NSMutableDictionary *videoSettings = [[NSMutableDictionary alloc] init];
    
    NSNumber *number = [[NSNumber alloc] initWithUnsignedInt:kCVPixelFormatType_32BGRA];
    
    [videoSettings setValue:number forKey:(NSString*) kCVPixelBufferPixelFormatTypeKey];

	[output setVideoSettings:videoSettings];
    
    [output setSampleBufferDelegate:self queue:dispatch_get_current_queue()];
	    
    [self.captureSession addInput:devInput];
        
    [self.captureSession addOutput:output];
    
    double max_fps = 30;
    NSString *deviceName = [NSString stringWithUTF8String:machineName()];
    if ([deviceName isEqualToString:@"iPhone2,1"] || [deviceName isEqualToString:@"iPhone3,1"]) {
        max_fps = 15;//Lower frame rate on iPhone 3GS and iPhone 4 for increased image detection performance
    }
    
    NSLog(@"FPS %f", max_fps);
    
    for(int i = 0; i < [[output connections] count]; i++) {
        AVCaptureConnection *conn = [[output connections] objectAtIndex:i];
        if (conn.supportsVideoMinFrameDuration) {
            conn.videoMinFrameDuration = CMTimeMake(1, max_fps);
        }
        if (conn.supportsVideoMaxFrameDuration) {
            conn.videoMaxFrameDuration = CMTimeMake(1, max_fps);
        }
    }

    [self.captureSession setSessionPreset: AVCaptureSessionPresetMedium];
    
    NSArray *events = [NSArray arrayWithObjects: 
                       AVCaptureSessionRuntimeErrorNotification, 
                       AVCaptureSessionErrorKey, 
                       AVCaptureSessionDidStartRunningNotification, 
                       AVCaptureSessionDidStopRunningNotification, 
                       AVCaptureSessionWasInterruptedNotification, 
                       AVCaptureSessionInterruptionEndedNotification, 
                       nil];
        
    for (id e in events) {
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(eventHandler:)
         name:e
         object:nil];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(startCamera) userInfo:nil repeats:NO];
}

- (void) takeSnapshot: (CVImageBufferRef) imgBuff {
    // Get camera matrix to string.
    pointcloud_matrix_4x4 current_matrix = pointcloud_get_camera_matrix();
    NSMutableString *matrixString = [NSMutableString stringWithString:@""];
    for (int i = 0 ; i < 16 ; i++) {
        [matrixString appendString:[NSString stringWithFormat:@"%f;", current_matrix.data[i]]];
    }
    
    //Get the current image to NSData.
    UIImage *image = [[UIImage alloc] initWithCVImageBufferRef:imgBuff orientation:UIImageOrientationRight];
    NSData *imageData = UIImagePNGRepresentation(image);
    
    // Create a file name for the image and matrix
    int current_snapshot_number = pointcloudApplication->get_and_increase_current_snapshot_number();
    NSString *imageName = [NSString stringWithFormat:@"%d.bmp", current_snapshot_number];
    NSString *matrixName = [NSString stringWithFormat:@"%d.txt", current_snapshot_number];
    
    // Find the path to the documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *picturesDirectory = [documentsDirectory stringByAppendingPathComponent:@"Snapshots"];
    NSString *matricesDirectory = [documentsDirectory stringByAppendingPathComponent:@"Matrices"];
    
    // Now we get the full path for the files
    NSString *picturePath = [picturesDirectory stringByAppendingPathComponent:imageName];
    NSString *matrixPath = [matricesDirectory stringByAppendingPathComponent:matrixName];
    
    // Write out the data.
    [imageData writeToFile:picturePath atomically:YES];
    [matrixString writeToFile:matrixPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}



- (void) realCaptureOutput:(id) pixData {
    NSData * data = (NSData *) pixData;
    
    CMSampleBufferRef sampleBuffer = (CMSampleBufferRef) [data bytes];
    
    CVImageBufferRef imgBuff = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFRetain(imgBuff);
    CVPixelBufferRef pixBuff = imgBuff;
    
    /*Lock the image buffer*/
    CVPixelBufferLockBaseAddress(imgBuff,0);
    /*Get information about the image*/
    int w = CVPixelBufferGetWidth(imgBuff);
    int h = CVPixelBufferGetHeight(imgBuff);
    
    /*We unlock the  image buffer*/
    CVPixelBufferUnlockBaseAddress(imgBuff,0);
    
    if (w == 0 && !restartingCamera) {
        NSLog(@"Bad image data, restarting session...?!");
        [self.captureSession stopRunning];
        restartingCamera = true;
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startCamera) userInfo:nil repeats:NO];
        return;
    }
	
	// Create the application once we get the first camera frame
	if (!pointcloudApplication) {
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString* documentsDirectory = [paths objectAtIndex:0]; // User-accesible file system path 
		NSString *resourcePath = [NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]];

		pointcloudApplication = new TestApp(self.glView.bounds.size.width,
											self.glView.bounds.size.height, 
											w,
											h,
											POINTCLOUD_BGRA_8888,
											[resourcePath cStringUsingEncoding:[NSString defaultCStringEncoding]], 
											[documentsDirectory cStringUsingEncoding:[NSString defaultCStringEncoding]],
											machineName(),
											g_scale);
	}

    // Capture a picture
    pointcloud_state state = pointcloud_get_state();
    if (pointcloudApplication->get_current_picture_flag()) {
        if (state == POINTCLOUD_TRACKING_SLAM_MAP || state == POINTCLOUD_TRACKING_IMAGES) {
            [self takeSnapshot:imgBuff];
        }
        pointcloudApplication->unset_current_picture_flag();
    }
    
	self.pixelBuffer = pixBuff;
	
    [glView drawView];
	
    self.pixelBuffer = nil;
	
    CFRelease(imgBuff);
}

// Capture delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    if (sampleBuffer == nil) {
        NSLog(@"Received nil sampleBuffer from %@ with connection %@",captureOutput,connection);
        return; 
    }
	
    CFRetain(sampleBuffer);
        
    NSData *data = [[NSData alloc] initWithBytesNoCopy:sampleBuffer length:4 freeWhenDone:NO];

	// Make sure that we handle the camera data in the main thread
	if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(realCaptureOutput:) withObject:data waitUntilDone:true];
    } else {
        [self realCaptureOutput: data];
    }

    [data release];
	
    CFRelease(sampleBuffer);    
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	NSLog(@"Memory warning received");
}

- (void)viewDidUnload {
}


- (void)dealloc {
    [super dealloc];
	[self.captureSession dealloc];
}

@end

// Forward decl.
static char *getRGBA(UIImage * image);

// Simple interface from C++ layer to read PNG resource files as RGBA
bool read_png_image(const char *filename, char **data, int *width, int *height) {
	NSString* fileNameNS = [NSString stringWithUTF8String:filename];
	UIImage* image = [UIImage imageNamed:fileNameNS];
	if (image) {
		*width = (int)image.size.width;
		*height = (int)image.size.height;
		*data = getRGBA(image);		
		return true;
	}
	else {
		NSLog(@"No such image %@", fileNameNS);
	}
	return false;
}


// Get RGBA data from an UIImage

static char * getRGBA(UIImage * image) {
	size_t width = CGImageGetWidth(image.CGImage);
	size_t height = CGImageGetHeight(image.CGImage);
	size_t bitsPerComponent = 8;
	size_t bytesPerRow = width * 4;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); assert(colorSpace);
	
	void *data = malloc(bytesPerRow * height); assert(data);
	memset(data,0,bytesPerRow * height);
	
	CGContextRef context = CGBitmapContextCreate(data, 
												 width, 
												 height, 
												 bitsPerComponent, 
												 bytesPerRow, 
												 colorSpace, 
												 kCGImageAlphaPremultipliedLast);
	
	assert(context);
	
	CGColorSpaceRelease(colorSpace);
	
	// Draw image on bitmap
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
	
	CGContextRelease(context);
	
	return (char*) data;
}
