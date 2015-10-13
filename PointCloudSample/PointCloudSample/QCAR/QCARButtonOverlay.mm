/*==============================================================================
Copyright (c) 2010-2011 QUALCOMM Austria Research Center GmbH .
All Rights Reserved.
Qualcomm Confidential and Proprietary
==============================================================================*/

#import <QuartzCore/QuartzCore.h>
#import <QCAR/QCAR.h>
#import <QCAR/CameraDevice.h>

#import "QCARButtonOverlay.h"
#import "OpenGLViewController.h"
#import "EAGLViewOGL.h"
#import "BackgroundWorker.h"
#import "SculpImage.h"

#import "EAGLViewQCAR.h"
#import "Event.h"
#import "Messager.h"


@interface QCARButtonOverlay()
-(void)disableButtons;
-(void)enableButtons;

-(void)takePictureButtonPushed;
-(void)backButtonPushed;
-(void)resetButtonPushed;
-(void)displayButtonPushed;

-(void)showCurvingMessage;

//Sidebar
@property (retain) UIPopoverController *popover;
@property (copy) void (^actionSheetBlock)(NSUInteger);
-(void)sideBarButtonsInsertButton:(NSNumber*)button atIndex:(NSInteger)index;
-(void)sidebarButtonsClearSelection;
@end

@implementation QCARButtonOverlay
@synthesize father;
@synthesize activityIndicator;

@synthesize logMesageLabel;

@synthesize sidebarImages = _sidebarImages, sidebarButtons = _sidebarButtons, images, buttons;
@synthesize popover;
@synthesize actionSheetBlock;


#pragma Mark
#pragma Mark UI Related Methods
#pragma Mark

/*
- (void)makeMyProgressBarMoving 
{   
    float actual = [displayProgressBar progress];  
    if (![backgroundWorker isFinished]) 
    {
        displayProgressBar.progress = MIN((actual+ 0.01), 1);
        [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(makeMyProgressBarMoving) userInfo:nil repeats:NO];  
    }
    else
    {
        displayProgressBar.progress = 0;
    }
}*/

-(void)startActivityIndicator 
{   
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
}

-(void)stopActivityIndicator 
{   
    [activityIndicator stopAnimating];
    [activityIndicator setHidden:YES];
}


#pragma Mark
#pragma Mark - Controller Functions

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        backgroundWorker = [[BackgroundWorker alloc] init];
        numberOfSculptedImages = 0;
        buttonsDisabled = NO;

    }
    return self;
}

-(void)viewDidLoad 
{
    [super viewDidLoad];
	_sidebarImages.delegate = self;
    _sidebarButtons.delegate = self;
    
    images = [[NSMutableArray alloc] init];
    buttons = [[NSMutableArray alloc] init];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPad"])
    {       
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:BACK_BUTTON]  atIndex:0];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:EMPTY_BUTTON] atIndex:1];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:EMPTY_BUTTON] atIndex:2];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:TAKE_PICTURE_BUTTON] atIndex:3];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:EMPTY_BUTTON]  atIndex:4];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:DISPLAY_BUTTON]  atIndex:5];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:RESET_BUTTON]  atIndex:6];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:EMPTY_BUTTON]  atIndex:7];
        
    }
    else
    {
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:BACK_BUTTON]  atIndex:0];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:TAKE_PICTURE_BUTTON] atIndex:1];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:DISPLAY_BUTTON]  atIndex:2];
        [self sideBarButtonsInsertButton:[NSNumber numberWithInt:RESET_BUTTON]  atIndex:3];
    };
   
    
    
    _sidebarButtons.selectedIndex = -1;
    
    
    CGRect tempRect = [self.view bounds];
    CGPoint centerPoint = CGPointMake(tempRect.origin.x + (tempRect.size.width / 2), tempRect.origin.y + (tempRect.size.height / 2));
    
    CGRect rect = CGRectMake(centerPoint.x, centerPoint.y, tempRect.size.height/10, tempRect.size.height/10);
    [activityIndicator setFrame:rect];

}

-(void)viewDidUnload 
{
    self.logMesageLabel = nil;
    self.sidebarImages = nil;
    self.sidebarButtons = nil;
    self.activityIndicator = nil;
    
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([activityIndicator isAnimating])
    {
        [activityIndicator stopAnimating];
        [activityIndicator setHidden:YES];
    }
}

-(void)dealloc 
{
    logMesageLabel = nil;
    [dropShadowImage release];
    
    if(backgroundWorker != nil)
        [backgroundWorker release];

    
    [popover release];
    [_sidebarImages release];
    [_sidebarButtons release];
    
    
    
    [images removeAllObjects];
    [images release];
    [buttons removeAllObjects];
    [buttons release];
    [father release];
    
    [activityIndicator release];

    [super dealloc];
}

#pragma Mark
#pragma Mark - SideBar Methods

-(void)sideBarInsertRow:(UIImage*)image atIndex:(NSInteger)index
{

	[images insertObject:image atIndex:index];
    
	[_sidebarImages insertRowAtIndex:index];
	[_sidebarImages scrollRowAtIndexToVisible:index];
	_sidebarImages.selectedIndex = index;
}

-(void)sideBarButtonsInsertButton:(NSNumber*)button atIndex:(NSInteger)index
{
	[buttons insertObject:button atIndex:index];
	[_sidebarButtons insertRowAtIndex:index];
	[_sidebarButtons scrollRowAtIndexToVisible:index];
	_sidebarButtons.selectedIndex = index;
}

-(void)sideBarDeleteRowAtIndex:(NSInteger)selectedIndex
{
	if (selectedIndex != -1) {
		BOOL isLastRow = (selectedIndex == ([images count] - 1));
		[images removeObjectAtIndex:selectedIndex];
        //TODO check if removeObjectAtIndex calls release
		[_sidebarImages deleteRowAtIndex:selectedIndex];
		
		if ([images count] != 0) {
			NSUInteger newSelection = selectedIndex;
			if (isLastRow) {
				newSelection = [images count] - 1;
			}
			_sidebarImages.selectedIndex = newSelection;
			[_sidebarImages scrollRowAtIndexToVisible:newSelection];
		}
	}
}

-(void)sideBarDeleteSelection
{
    [self sideBarDeleteRowAtIndex:_sidebarImages.selectedIndex];
}

-(UIImage*)sidebar:(HSImageSidebarView *)sidebar imageForIndex:(NSUInteger)anIndex 
{
    if (sidebar == _sidebarButtons)
    {
        int button = [[buttons objectAtIndex:anIndex] intValue];
        switch (button) 
        {
            case EMPTY_BUTTON:
                return [UIImage imageNamed:@"Empty Icon.png"];
                break;
            
            case BACK_BUTTON:
                return [UIImage imageNamed:@"GoBackButton.png"];
                break;   
                
            case TAKE_PICTURE_BUTTON:
                return [UIImage imageNamed:@"TakePic Square.png"];
                break;  
            
            case DISPLAY_BUTTON:
                return [UIImage imageNamed:@"Display Square.png"];
                break; 
                
            case RESET_BUTTON:
                return [UIImage imageNamed:@"Reset Square.png"];
                break;
                
            default:
                return [UIImage imageNamed:@"Empty Icon.png"];
                break;  
        }
        
    }
    
    UIImage* image = [images objectAtIndex:anIndex];
    return image;
}

-(void)sidebar:(HSImageSidebarView *)sidebar didTapImageAtIndex:(NSUInteger)anIndex 
{
	
    if (sidebar == _sidebarButtons)
    {
        if (buttonsDisabled == YES) return;
        
        int button = [[buttons objectAtIndex:anIndex] intValue];
        switch (button) 
        {
            case EMPTY_BUTTON:
                [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(sidebarButtonsClearSelection)];
                [backgroundWorker runWorkerAsync];
                
                break;
                
            case BACK_BUTTON:
                [self backButtonPushed];
                break;
            
            case TAKE_PICTURE_BUTTON:                
                [self takePictureButtonPushed];
                break;
            
            case DISPLAY_BUTTON:
                [self displayButtonPushed];
                break;
                
            case RESET_BUTTON:
                [self resetButtonPushed];
                break;
            
            default:
                break;  
        }
    }
    else
    {
        NSLog(@"Touched image at index: %u", anIndex);
        if (sidebar.selectedIndex == anIndex) 
        {        
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                 destructiveButtonTitle:@"Delete" 
                                                      otherButtonTitles:@"Sculpt Image", @"Expand Image",@"Cancel",nil];        
            
            
            self.actionSheetBlock = ^(NSUInteger selectedIndex) 
            { 
                SculpImage* image = [images objectAtIndex:anIndex];
                switch (selectedIndex) 
                {
                    case 0: //delete
                        
                        if (image.sculpted == TRUE)
                        {
                            Messager* messager = [[Messager alloc] initWith:logMesageLabel];
                            [messager showMessage:@"Sculpted Images are undeletable" withFadeDuration:2.0 withShowDuration:2.0];
                            [messager release];
                            break;
                            
                        }
                        
                        [self sideBarDeleteSelection];
                        self.actionSheetBlock = nil;
                        break;
                    case 1: //Sculpt Image
                        
                        [self startActivityIndicator];

                        if (image.sculpted == TRUE)
                        {
                            Messager* messager = [[Messager alloc] initWith:logMesageLabel];
                            [messager showMessage:@"The Image is allready scultped" withFadeDuration:2.0 withShowDuration:2.0];
                            [self stopActivityIndicator];
                            [messager release];
                            break;
                            
                        }
                        [father sculptImage:image index:anIndex];
                        numberOfSculptedImages ++;
                        
                        [self stopActivityIndicator];
                        
                        break;
                    case 2: //expand = 2
                        
                        [self sideBarExpandSelectedImage];
                        break;
                        
                    default:
                        break;
                }
            };
            
            [sheet showFromRect:[sidebar frameOfImageAtIndex:anIndex]
                         inView:sidebar
                       animated:YES];
            [sheet release];
        }
    }
}

-(void)takePictureButtonPushed
{
    if([backgroundWorker isFinished])
    {
        [backgroundWorker.onBeforeWork signMethod:self :@selector(disableButtons)];
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(startActivityIndicator)];
        
        [backgroundWorker.onDoWork signMethod:father :@selector(takePictureButtonPushed)];
        
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(enableButtons)];
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(stopActivityIndicator)];
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(sidebarButtonsClearSelection)];
        
        [backgroundWorker runWorkerAsync];
    }
}

-(void)backButtonPushed
{
    if([backgroundWorker isFinished])
    {
        [backgroundWorker.onBeforeWork signMethod:self :@selector(disableButtons)];
        [backgroundWorker.onDoWork signMethod:father :@selector(backPushed)];
        
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(enableButtons)];
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(sidebarButtonsClearSelection)];
        
        [backgroundWorker runWorkerAsync];
    }
}

-(void)resetButtonPushed
{
    numberOfSculptedImages = 0;
    int numOfimages = [self countOfImagesInSidebar:_sidebarImages];
    for (int i = 0; i < numOfimages; i++)
    {
        [self sideBarDeleteRowAtIndex:0];
    }
    
    if([backgroundWorker isFinished])
    {
        [backgroundWorker.onBeforeWork signMethod:self :@selector(disableButtons)];
        
        [backgroundWorker.onDoWork signMethod:father :@selector(resetPushed)];
        
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(enableButtons)];
        [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(sidebarButtonsClearSelection)];
        
        [backgroundWorker runWorkerAsync];
    }
}

-(void)displayButtonPushed
{
    UIActionSheet *sheet;
    NSString* destructiveButtonTitle;
    if (numberOfSculptedImages == [self countOfImagesInSidebar:_sidebarImages] )
    {
        sheet = [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:self
                                   cancelButtonTitle:nil
                              destructiveButtonTitle:@"Display" 
                                   otherButtonTitles:@"Cancel",nil];
        destructiveButtonTitle = @"Display";
        
    }
    else
    {
        sheet = [[UIActionSheet alloc] initWithTitle:@"Sculpt all unsculted images?"
                                            delegate:self
                                   cancelButtonTitle:nil
                              destructiveButtonTitle:@"YES" 
                                   otherButtonTitles:@"NO", @"Cancel",nil]; 
        
        destructiveButtonTitle = @"YES";
    }
    
    self.actionSheetBlock = ^(NSUInteger choise) 
    {
        if ((destructiveButtonTitle == @"YES" && choise != 0 && choise != 1) ||
            (destructiveButtonTitle == @"Display" && choise != 0))
        {
            [self sidebarButtonsClearSelection];
            return;
        }
        
        if([backgroundWorker isFinished])
        {
            [backgroundWorker.onBeforeWork signMethod:self :@selector(startActivityIndicator)];
            [backgroundWorker.onBeforeWork signMethod:self :@selector(disableButtons)];
            
            if(choise == 0 && (destructiveButtonTitle == @"YES"))
            {
                numberOfSculptedImages = [self countOfImagesInSidebar:_sidebarImages];
                [backgroundWorker.onDoWork signMethod:father :@selector(displayMeshButtonPushedWithSculp)];
            }
            if(choise == 1 || (destructiveButtonTitle == @"Display"))
            {
                
                [backgroundWorker.onDoWork signMethod:father :@selector(displayMeshButtonPushedNoSculp)];
            }
            
            
            [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(enableButtons)];
            [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(stopActivityIndicator)];
            [backgroundWorker.onRunWorkerCompleted signMethod:self :@selector(sidebarButtonsClearSelection)];
            [backgroundWorker.onRunWorkerCompleted signMethod:father :@selector(gotoOpenGLView)];
            
            
            [backgroundWorker runWorkerAsync];
        }
        
    };
    
    [sheet showFromRect:[_sidebarButtons frameOfImageAtIndex:5] //DISPLAY_BUTTON
                 inView:_sidebarButtons
               animated:YES];
    [sheet release];
}

-(void)showCurvingMessage
{
    Messager* messager = [[Messager alloc] initWith:logMesageLabel];
    
    [messager showMessage:@"Performin Marching Cubes algorithm" withFadeDuration:2.0 withShowDuration:50.0];
    [messager release];
}
-(void)disableButtons
{
    buttonsDisabled = YES;
}

-(void)enableButtons
{
    buttonsDisabled = NO;
}

-(void)sidebar:(HSImageSidebarView *)sidebar didMoveImageAtIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex {
    
    if (sidebar == _sidebarButtons)
    {
        NSLog(@"Image at index %d moved to index %d", oldIndex, newIndex);
        
        NSNumber *button = [[buttons objectAtIndex:oldIndex] retain];
        [buttons removeObjectAtIndex:oldIndex];
        [buttons insertObject:button atIndex:newIndex];
        [button release];
        if([backgroundWorker isFinished])
        {
            [backgroundWorker.onDoWork signMethod:father :@selector(sidebarButtonsClearSelection)];
            
            [backgroundWorker runWorkerAsync];
        }
        
        return;
    }
	NSLog(@"Image at index %d moved to index %d", oldIndex, newIndex);
	
	UIImage *image = [[images objectAtIndex:oldIndex] retain];
	[images removeObjectAtIndex:oldIndex];
	[images insertObject:image atIndex:newIndex];
	[image release];
}

-(void)sidebar:(HSImageSidebarView *)sidebar didRemoveImageAtIndex:(NSUInteger)anIndex {
    
    if (sidebar == _sidebarButtons)
    {
        return;
    }
    
	NSLog(@"Image at index %d removed", anIndex);
	[images removeObjectAtIndex:anIndex];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    actionSheetBlock(buttonIndex);
}


-(void)sidebarButtonsClearSelection
{
    _sidebarButtons.selectedIndex = -1;
}

-(NSUInteger)countOfImagesInSidebar:(HSImageSidebarView *)sidebar 
{
	if (sidebar == _sidebarImages)
    {
            return [images count];
    }
    return [buttons count];
}

-(void)sideBarExpandSelectedImage
{
    [father expandImageButtonPushed];
}

@end
