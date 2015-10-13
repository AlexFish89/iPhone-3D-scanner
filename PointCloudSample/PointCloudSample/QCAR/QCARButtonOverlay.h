/*==============================================================================
Copyright (c) 2010-2011 QUALCOMM Austria Research Center GmbH .
All Rights Reserved.
Qualcomm Confidential and Proprietary
==============================================================================*/


#import <UIKit/UIKit.h>
#import "../Sidebar/HSImageSidebarView.h"
#import "../Sidebar/HSImageSidebarViewDelegate.h"

@class BackgroundWorker;


/**QCARViewController: Controller class responsible for UI layer of QCARViewController
 *@see QCARViewController, SculpImage, HSImageSidebarView, BackgroundWorker
 */
@interface QCARButtonOverlay : UIViewController 
<UIActionSheetDelegate, HSImageSidebarViewDelegate, UIPopoverControllerDelegate>
{
    @private
    BackgroundWorker* backgroundWorker;
    
    UIImageView *dropShadowImage;
    
    
    HSImageSidebarView *_sidebarImages;
    NSMutableArray* images; 
    HSImageSidebarView *_sidebarButtons;    
    NSMutableArray* buttons;
    
    
    BOOL buttonsDisabled;
    NSUInteger numberOfSculptedImages;
}

/**label for displaying messages to the user*/
@property (nonatomic, retain) IBOutlet UILabel* logMesageLabel;


/**activity indicator*/
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
/**activity indicator actions*/
-(void)startActivityIndicator; 
-(void)stopActivityIndicator;


/**left sidebar of images*/
@property (nonatomic, retain) IBOutlet HSImageSidebarView *sidebarImages;
/**right sidebar of images - buttons*/
@property (nonatomic, retain) IBOutlet HSImageSidebarView *sidebarButtons;
/**image (UIImages and SculpImages) set in _sidebarImages*/
@property (nonatomic, retain) NSMutableArray* images;
/**button image set in _sidebarButtons*/
@property (nonatomic, retain) NSMutableArray* buttons;

/**refers only to the _sidebarImages*/
-(void)sideBarInsertRow:(UIImage*)image atIndex:(NSInteger)index;
/**refers only to the _sidebarImages*/
-(void)sideBarDeleteSelection;
/**refers only to the _sidebarImages*/
-(void)sideBarDeleteRowAtIndex:(NSInteger)selectedIndex;
/**refers only to the _sidebarImages*/
-(void)sideBarExpandSelectedImage;

@end
