//
//  PulleyCDelegate.h
//  PulleyC
//
//  Created by Artem Kedrov on 12/3/18.
//  Copyright © 2018 Artem Kedrov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PulleyCViewController, PulleyCPosition, PulleyCDisplayMode, PulleyCPanelCornerPlacement, PulleyCSnapMode;
@protocol PulleyCDelegate <NSObject>

@optional
/** This is called after size changes, so if you care about the bottomSafeArea property for custom UI layout, you can use this value.
 * NOTE: It's not called *during* the transition between sizes (such as in an animation coordinator), but rather after the resize is complete.
 */
- (void) drawerPositionDidChange:(PulleyCViewController *) drawer bottomSafeArea:(CGFloat) safeArea;
/**
 *  Make UI adjustments for when Pulley goes to 'fullscreen'. Bottom safe area is provided for your convenience.
 */
- (void) makeUIAdjustmentsForFullscreen:(CGFloat) progress bottomSafeArea:(CGFloat) safeArea;
/**
 *  Make UI adjustments for changes in the drawer's distance-to-bottom. Bottom safe area is provided for your convenience.
 */
- (void) drawerChangedDistanceFromBottom:(PulleyCViewController *) drawer distance:(CGFloat) distance bottomSafeArea:(CGFloat) safeArea;
/**
 *  Called when the current drawer display mode changes (leftSide vs bottomDrawer). Make UI changes to account for this here.
 */
- (void) drawerDisplayModeDidChange:(PulleyCViewController *) drawer;


@end

/**
 *  View controllers in the drawer can implement this to receive changes in state or provide values for the different drawer positions.
 */
@protocol PulleyCDrawerViewControllerDelegate <PulleyCDelegate>

@optional
/**
 *  Provide the collapsed drawer height for Pulley. Pulley does NOT automatically handle safe areas for you, however: bottom safe area is provided for your convenience in computing a value to return.
 */
- (CGFloat) collapsedDrawerHeight:(CGFloat) bottomSafeArea;
/**
 *  Provide the partialReveal drawer height for Pulley. Pulley does NOT automatically handle safe areas for you, however: bottom safe area is provided for your convenience in computing a value to return.
 */
- (CGFloat) partialRevealDrawerHeight: (CGFloat) bottomSafeArea;
/**
 *  Return the support drawer positions for your drawer.
 */
- (NSArray<PulleyCPosition *> *) supportedDrawerPositions;

@end

@class PulleyCPassthroughScrollView;
/**
 *  View controllers that are the main content can implement this to receive changes in state.
 */
@protocol PulleyCPassthroughScrollViewDelegate <NSObject>

@optional
- (BOOL)shouldTouchPassthroughScrollView:(PulleyCPassthroughScrollView *) scrollView point:(CGPoint) point;
- (UIView *) viewToReceiveTouch:(PulleyCPassthroughScrollView *) scrollView point:(CGPoint) point;

@end

NS_ASSUME_NONNULL_END
