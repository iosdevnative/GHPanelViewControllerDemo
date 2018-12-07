//
//  PulleyCViewController.h
//  PulleyC
//
//  Created by Artem Kedrov on 12/3/18.
//  Copyright © 2018 Artem Kedrov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PulleyCDelegate.h"
NS_ASSUME_NONNULL_BEGIN

/**
 *  A completion block used for animation callbacks.
 */
typedef void(^PulleyAnimationCompletionBlock)(BOOL finished);

typedef struct DrawerDistanceFromBottom {
  CGFloat distance;
  CGFloat bottomSafeArea;
} DrawerDistanceFromBottom;

@interface UIViewController (TestTest)

@property (nonatomic, readonly) PulleyCViewController * _Nullable  pulleyViewController;

@end


@interface PulleyCViewController : UIViewController
// Interface Builder

/// When using with Interface Builder only! Connect a containing view to this outlet.
@property (weak, nonatomic) IBOutlet UIView * primaryContentContainerView;

/// When using with Interface Builder only! Connect a containing view to this outlet.
@property (weak, nonatomic) IBOutlet UIView * drawerContentContainerView;
@property (nonatomic, assign, readonly) CGFloat bounceOverflowMargin;

/// The current content view controller (shown behind the drawer).
@property (strong, nonatomic, readonly) UIViewController *primaryContentViewController;

/// The current drawer view controller (shown in the drawer).
@property (strong, nonatomic, readonly) UIViewController *drawerContentViewController;

/// Get the current bottom safe area for Pulley. This is a convenience accessor. Most delegate methods where you'd need it will deliver it as a parameter.
@property (nonatomic, assign, readonly) CGFloat bottomSafeSpace;

/// The content view controller and drawer controller can receive delegate events already. This lets another object observe the changes, if needed.
@property (weak, nonatomic) id<PulleyCDelegate> delegate;

/// The current position of the drawer.
@property (nonatomic, strong, readonly) PulleyCPosition *drawerPosition;

// The visible height of the drawer. Useful for adjusting the display of content in the main content view.
@property (nonatomic, assign, readonly) CGFloat visibleDrawerHeight;

/// The background visual effect layer for the drawer. By default this is the extraLight effect. You can change this if you want, or assign nil to remove it.
@property (nonatomic, strong) UIVisualEffectView *drawerBackgroundVisualEffectView;


/// The corner radius for the drawer.
/// Note: This property is ignored if your drawerContentViewController's view.layer.mask has a custom mask applied using a CAShapeLayer.
/// Note: Custom CAShapeLayer as your drawerContentViewController's view.layer mask will override Pulley's internal corner rounding and use that mask as the drawer mask.
@property (nonatomic, assign) IBInspectable CGFloat drawerCornerRadius;

/// The inset from the top safe area when the drawer is fully open. This property is only for the 'drawer' displayMode. Use panelInsets to control the top/bottom/left/right insets for the panel.
@property (nonatomic, assign) IBInspectable CGFloat drawerTopInset;

/// This replaces the previous panelInsetLeft and panelInsetTop properties. Depending on what corner placement is being used, different values from this struct will apply. For example, 'topLeft' corner placement will utilize the .top, .left, and .bottom inset properties and it will ignore the .right property (use panelWidth property to specify width)
@property (nonatomic, assign) IBInspectable UIEdgeInsets panelInsets;

/// The width of the panel in panel displayMode
@property (nonatomic, assign) IBInspectable CGFloat panelWidth;

/// The opacity of the drawer shadow.
@property (nonatomic, assign) IBInspectable float shadowOpacity;

/// The radius of the drawer shadow.
@property (nonatomic, assign) IBInspectable CGFloat shadowRadius;

/// The offset of the drawer shadow.
@property (nonatomic, assign) IBInspectable CGSize shadowOffset;

/// The opaque color of the background dimming view.
@property (nonatomic, strong) IBInspectable UIColor *backgroundDimmingColor;

/// The maximum amount of opacity when dimming.
@property (nonatomic, assign) IBInspectable CGFloat backgroundDimmingOpacity;

/// The drawer scrollview's delaysContentTouches setting
@property (nonatomic, assign) IBInspectable BOOL delaysContentTouches;

/// The drawer scrollview's canCancelContentTouches setting
@property (nonatomic, assign) IBInspectable BOOL canCancelContentTouches;

/// The starting position for the drawer when it first loads
@property (nonatomic, strong) PulleyCPosition *initialDrawerPosition;

/// The display mode for Pulley. Default is 'drawer', which preserves the previous behavior of Pulley. If you want it to adapt automatically, choose 'automatic'. The current display mode is available by using the 'currentDisplayMode' property.
@property (nonatomic, strong) PulleyCDisplayMode *displayMode;

/// The Y positioning for Pulley. This property is only oberserved when `displayMode` is set to `.automatic` or `bottom`. Default value is `.topLeft`.
@property (nonatomic, strong) PulleyCPanelCornerPlacement *panelCornerPlacement;

/// This is here exclusively to support IBInspectable in Interface Builder because Interface Builder can't deal with enums. If you're doing this in code use the -initialDrawerPosition property instead. Available strings are: open, closed, partiallyRevealed, collapsed
@property (nonatomic, strong) IBInspectable NSString *initialDrawerPositionFromIB;

/// Whether the drawer's position can be changed by the user. If set to `false`, the only way to move the drawer is programmatically. Defaults to `true`.
@property (nonatomic, assign) IBInspectable BOOL allowsUserDrawerPositionChange;

/// The animation duration for setting the drawer position
@property (nonatomic, assign) IBInspectable NSTimeInterval animationDuration;

/// The animation delay for setting the drawer position
@property (nonatomic, assign) IBInspectable NSTimeInterval animationDelay;

/// The spring damping for setting the drawer position
@property (nonatomic, assign) IBInspectable CGFloat animationSpringDamping;

/// The spring's initial velocity for setting the drawer position
@property (nonatomic, assign) IBInspectable CGFloat animationSpringInitialVelocity;

/// This setting allows you to enable/disable Pulley automatically insetting the drawer on the left/right when in 'bottomDrawer' display mode in a horizontal orientation on a device with a 'notch' or other left/right obscurement.
@property (nonatomic, assign) IBInspectable BOOL adjustDrawerHorizontalInsetToSafeArea;

/// The animation options for setting the drawer position
@property (nonatomic, assign) UIViewAnimationOptions animationOptions;

/// The drawer snap mode
@property (nonatomic, strong) PulleyCSnapMode *snapMode;

// The feedback generator to use for drawer positon changes. Note: This is 'Any' to preserve iOS 9 compatibilty. Assign a UIFeedbackGenerator to this property. Anything else will be ignored.

@property (nonatomic, strong) id feedbackGenerator;

/// Access to the safe areas that Pulley is using for layout (provides compatibility for iOS < 11)
@property (nonatomic, assign, readonly) UIEdgeInsets pulleySafeAreaInsets;

/// Get the current drawer distance. This value is equivalent in nature to the one delivered by PulleyDelegate's `drawerChangedDistanceFromBottom` callback.

@property (nonatomic, assign, readonly) DrawerDistanceFromBottom *drawerDistanceFromBottom;

/// Get all gesture recognizers in the drawer scrollview
@property (nonatomic, strong, readonly) NSArray<UIGestureRecognizer *> *drawerGestureRecognizers;

/// Get the drawer scrollview's pan gesture recognizer
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *drawerPanGestureRecognizer;

/// The drawer positions supported by the drawer
@property (nonatomic, strong) NSArray<PulleyCPosition *> *supportedPositions;

/// The currently rendered display mode for Pulley. This will match displayMode unless you have it set to 'automatic'. This will provide the 'actual' display mode (never automatic).
@property (nonatomic, strong, readonly) PulleyCDisplayMode *currentDisplayMode;

/// The height of the open position for the drawer
@property (nonatomic, assign, readonly) CGFloat heightOfOpenDrawer;



- (void) scrollViewDidScroll:(UIScrollView *) scrollView;

/**
 Initialize the drawer controller programmtically.
 
 - parameter contentViewController: The content view controller. This view controller is shown behind the drawer.
 - parameter drawerViewController:  The view controller to display inside the drawer.
 
 - note: The drawer VC is 20pts too tall in order to have some extra space for the bounce animation. Make sure your constraints / content layout take this into account.
 
 - returns: A newly created Pulley drawer.
 */
- (instancetype) intiWithContentViewController:(UIViewController *) contentViewController drawerViewController:(UIViewController *) drawer;
/**
 Initialize the drawer controller from Interface Builder.
 
 - note: Usage notes: Make 2 container views in Interface Builder and connect their outlets to -primaryContentContainerView and -drawerContentContainerView. Then use embed segues to place your content/drawer view controllers into the appropriate container.
 
 - parameter aDecoder: The NSCoder to decode from.
 
 - returns: A newly created Pulley drawer.
 */





- (void) prepareFeedbackGenerator;
- (void) triggerFeedbackGenerator;

- (void) addDrawerGestureRecognizer:(UIGestureRecognizer *) recognizer;
- (void) removeDrawerGestureRecognizer:(UIGestureRecognizer *) recognizer;

- (void) bounceDrawer:(CGFloat) height speedMultiplier:(CGFloat) multimplier;

- (void) setDrawerPosition:(PulleyCPosition *) position animated:(BOOL) animated;

- (void) setPrimaryContentViewController:(UIViewController *) controller animated:(BOOL) animated completion:(_Nullable  PulleyAnimationCompletionBlock) completion;

- (void) setPrimaryContentViewController:(UIViewController *) controller animated:(BOOL) animated;

- (void) setDrawerContentViewController:(UIViewController *) controller animated:(BOOL) animated completion:(_Nullable PulleyAnimationCompletionBlock) completion;
- (void) setDrawerContentViewController:(UIViewController *) controller animated:(BOOL) animated;

- (CGFloat) collapsedDrawerHeight:(CGFloat) bottomSafeArea;

- (CGFloat) partialRevealDrawerHeight: (CGFloat) bottomSafeArea;

- (NSArray<PulleyCPosition *> *) supportedDrawerPositions;

- (void) drawerPositionDidChange:(PulleyCViewController *) drawer bottomSafeArea:(CGFloat) bottomSafeArea;

- (void) makeUIAdjustmentsForFullscreen:(CGFloat) progress bottomSafeArea:(CGFloat)safeArea;

- (void) drawerChangedDistanceFromBottom:(PulleyCViewController *) drawer distance:(CGFloat)distance bottomSafeArea:(CGFloat)safeArea;

@end

NS_ASSUME_NONNULL_END
