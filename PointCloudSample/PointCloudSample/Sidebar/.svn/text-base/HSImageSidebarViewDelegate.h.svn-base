//
//  HSImageSidebarViewDelegate.h
//  Sidebar

#import <UIKit/UIKit.h>
@class HSImageSidebarView;

/**HSImageSidebarViewDelegate: HSImageSidebarView delegate
 *@see:HSImageSidebarView
 */
@protocol HSImageSidebarViewDelegate <NSObject>

#pragma mark -
#pragma mark Delegate methods
@optional
- (void)sidebar:(HSImageSidebarView *)sidebar didTapImageAtIndex:(NSUInteger)anIndex;
- (void)sidebar:(HSImageSidebarView *)sidebar didMoveImageAtIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex;
- (void)sidebar:(HSImageSidebarView *)sidebar didRemoveImageAtIndex:(NSUInteger)anIndex;

#pragma mark -
#pragma mark Data source methods
@required
- (NSUInteger)countOfImagesInSidebar:(HSImageSidebarView *)sidebar;
- (UIImage *)sidebar:(HSImageSidebarView *)sidebar imageForIndex:(NSUInteger)anIndex;

@end
