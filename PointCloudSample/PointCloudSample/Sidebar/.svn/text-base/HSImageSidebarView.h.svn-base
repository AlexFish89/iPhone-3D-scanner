//
//  HSImageSidebarView.h
//  Sidebar

#import <UIKit/UIKit.h>
#import "HSImageSidebarViewDelegate.h"

/**HSImageSidebarView: sider bar view. The implementation is taken from the following site
 *@see:https://github.com/bjhomer/HSImageSidebarView, QCARButtonOverlay, OpenGLViewController
 */
@interface HSImageSidebarView : UIView
{
}

@property (readonly) NSUInteger imageCount;
@property (readonly) NSIndexSet *visibleIndices;

@property (assign) id<HSImageSidebarViewDelegate> delegate;
@property (assign) CGFloat rowHeight;
@property (assign) NSInteger selectedIndex;

- (CGRect)frameOfImageAtIndex:(NSUInteger)anIndex;

- (BOOL)imageAtIndexIsVisible:(NSUInteger)anIndex;
- (void)scrollRowAtIndexToVisible:(NSUInteger)anIndex;

- (void)insertRowAtIndex:(NSUInteger)anIndex;
- (void)deleteRowAtIndex:(NSUInteger)anIndex;
- (void)reloadData;

@end
