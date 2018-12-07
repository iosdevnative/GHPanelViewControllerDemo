//
//  PulleyCViewController.m
//  PulleyC
//
//  Created by Artem Kedrov on 12/3/18.
//  Copyright © 2018 Artem Kedrov. All rights reserved.
//

#import "PulleyCViewController.h"
#import "PulleyCPassthroughScrollView.h"
#import "UIView+ConstraintToParent.h"
#import "PulleyCPosition.h"
#import "PulleyCDisplayMode.h"
#import "PulleyCPanelCornerPlacement.h"
#import "PulleyCSnapMode.h"

static CGFloat const kPulleyCDefaultCollapsedHeight = 68.0;
static CGFloat const kPulleyCDefaultPartialRevealHeight = 264.0;
static CGFloat const kPulleyCBounceOverflowMargin = 20.0;



@interface PulleyCViewController ()<PulleyCPassthroughScrollViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UIView *primaryContentContainer;
@property (nonatomic, strong) UIView *drawerContentContainer;
@property (nonatomic, strong) UIView *drawerShadowView;
@property (nonatomic, strong) PulleyCPassthroughScrollView *drawerScrollView;
@property (nonatomic, strong) UIView *backgroundDimmingView;
@property (nonatomic, strong) UITapGestureRecognizer *dimmingViewTapRecognizer;
@property (nonatomic, assign) CGPoint lastDragTargetContentOffset;
@property (strong, nonatomic, readwrite) UIViewController *primaryContentViewController;
@property (strong, nonatomic, readwrite) UIViewController *drawerContentViewController;
@property (nonatomic, strong, readwrite) PulleyCPosition *drawerPosition;
@property (nonatomic, strong, readwrite) PulleyCDisplayMode *currentDisplayMode;
@property (nonatomic, assign) BOOL isAnimatingDrawerPosition;

- (void) setDefault;
@end

@implementation PulleyCViewController

@synthesize primaryContentContainer = _primaryContentContainer;
@synthesize drawerContentContainer = _drawerContentContainer;
@synthesize drawerShadowView = _drawerShadowView;
@synthesize drawerScrollView= _drawerScrollView;
@synthesize backgroundDimmingView = _backgroundDimmingView;
@synthesize dimmingViewTapRecognizer = _dimmingViewTapRecognizer;
@synthesize lastDragTargetContentOffset = _lastDragTargetContentOffset;
@synthesize primaryContentViewController = _primaryContentViewController;
@synthesize drawerContentViewController = _drawerContentViewController;
@synthesize drawerPosition = _drawerPosition;
@synthesize drawerDistanceFromBottom = _drawerDistanceFromBottom;

- (void)setDefault {
  [self addObserver:self forKeyPath:@"currentDisplayMode" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    _primaryContentContainer = [[UIView alloc] init];
    _drawerContentContainer = [[UIView alloc] init];
    _drawerShadowView = [[UIView alloc] init];
    _drawerScrollView = [[PulleyCPassthroughScrollView alloc] init];
    _backgroundDimmingView = [[UIView alloc] init];

  
    _lastDragTargetContentOffset = CGPointZero;
    _drawerPosition = PulleyCPosition.collapsed;
    _drawerBackgroundVisualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    _drawerCornerRadius = 13.0;
    _drawerTopInset = 20.0;
    _panelInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    _panelWidth = 325.0;
    _shadowOpacity = 0.1;
    _shadowRadius = 3.0;
    _shadowOffset = CGSizeMake(0.0, -3.0);
    _backgroundDimmingColor = UIColor.blackColor;
    _backgroundDimmingOpacity = 0.5;
    _delaysContentTouches = true;
    _canCancelContentTouches = true;
    _initialDrawerPosition = PulleyCPosition.collapsed;
    _displayMode = PulleyCDisplayMode.drawer;
    _panelCornerPlacement = PulleyCPanelCornerPlacement.topLeft;
    _allowsUserDrawerPositionChange = true;
    _animationDuration = 0.3;
    _animationDelay = 0.0;
    _animationSpringDamping = 0.75;
    _animationSpringInitialVelocity = 0.0;
    _adjustDrawerHorizontalInsetToSafeArea = true;
    _animationOptions = UIViewAnimationOptionCurveEaseInOut;
    _snapMode = [PulleyCSnapMode nearestPositionUnlessExceeded:20.0];
    _supportedPositions = PulleyCPosition.all;
  _currentDisplayMode = PulleyCDisplayMode.automatic;
  _isAnimatingDrawerPosition = false;
}

- (void)loadView {
    [super loadView];
  
  if ([self primaryContentContainerView] != nil) {
    [[self primaryContentContainerView] removeFromSuperview];
  }
  if ([self drawerContentContainerView] != nil) {
    [[self drawerContentContainerView] removeFromSuperview];
  }
  
  [[self primaryContentContainerView] setBackgroundColor: UIColor.whiteColor];
  [self setDefinesPresentationContext: true];
  [[self drawerScrollView] setBounces:false];
  [[self drawerScrollView] setDelegate:self];
  [[self drawerScrollView] setClipsToBounds:false];
  [[self drawerScrollView] setShowsVerticalScrollIndicator:false];
  [[self drawerScrollView] setShowsHorizontalScrollIndicator:false];
  
  [[self drawerScrollView] setDelaysContentTouches: [self delaysContentTouches]];
  [[self drawerScrollView] setCanCancelContentTouches:[self canCancelContentTouches]];
  [[self drawerScrollView] setBackgroundColor: [UIColor clearColor]];
  [[self drawerScrollView] setDecelerationRate:UIScrollViewDecelerationRateFast];
  [[self drawerScrollView] setScrollsToTop:false];
  [[self drawerScrollView] setTouchDelegate:self];
  [[[self drawerShadowView] layer] setShadowOpacity:[self shadowOpacity]];
  [[[self drawerShadowView] layer] setShadowRadius: [self shadowRadius]];
  [[[self drawerShadowView] layer] setShadowOffset:[self shadowOffset]];
  [[self drawerShadowView] setBackgroundColor: [UIColor clearColor]];
  
  
  
  [[self drawerContentContainer] setBackgroundColor: UIColor.clearColor];
  
  [[self backgroundDimmingView] setBackgroundColor: [self backgroundDimmingColor]];
  [[self backgroundDimmingView] setUserInteractionEnabled: false];
  [[self backgroundDimmingView] setAlpha: 0.0];
  [[self drawerBackgroundVisualEffectView] setClipsToBounds: true];
  
  _dimmingViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapRecognizerAction:)];
  [[self backgroundDimmingView] addGestureRecognizer:[self dimmingViewTapRecognizer]];
  [[self drawerScrollView] addSubview: [self drawerShadowView]];
  
  if ([self drawerBackgroundVisualEffectView] != nil) {
    [[self drawerScrollView] addSubview: [self drawerBackgroundVisualEffectView]];
    [[[self drawerBackgroundVisualEffectView] layer] setCornerRadius: [self drawerCornerRadius]];
  }
  [[self drawerScrollView] addSubview: [self drawerContentContainer]];
  [[self primaryContentContainer] setBackgroundColor: UIColor.whiteColor];
  [[self view] setBackgroundColor: UIColor.whiteColor];
  
  [[self view] addSubview:[self primaryContentContainer]];
  [[self view] addSubview:[self backgroundDimmingView]];
  [[self view] addSubview:[self drawerScrollView]];
  
  [[self primaryContentContainer] constrainToParent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
  if ([self primaryContentViewController] == nil || [self drawerContentViewController] == nil) {
        NSAssert(_primaryContentContainerView != nil && _drawerContentContainerView != nil, @"When instantiating from Interface Builder you must provide container views with an embedded view controller.");
    
    for (UIViewController *child in [self childViewControllers]) {
      if ([[child view] isEqual: [[[self primaryContentContainerView] subviews] firstObject]]) {
        [self setPrimaryContentViewController: child];
      }
      if ([[child view] isEqual: [[[self drawerContentContainerView] subviews] firstObject]]) {
        [self setDrawerContentViewController: child];
      }
    }
    NSAssert(_primaryContentContainerView != nil && _drawerContentContainerView != nil, @"Container views must contain an embedded view controller.");

  }
  
  [self enforceCanScrollDrawer];
  [self setDrawerPosition:[self initialDrawerPosition] animated: false completion: nil];
  
  [self scrollViewDidScroll: [self drawerScrollView]];
  
  
  [[self delegate] drawerDisplayModeDidChange: self];
  if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *) [self drawerContentViewController] respondsToSelector:@selector(drawerDisplayModeDidChange:)]) {
    [((UIViewController<PulleyCDrawerViewControllerDelegate> *) [self drawerContentViewController]) drawerDisplayModeDidChange:self];

  }
  if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *) [self primaryContentViewController] respondsToSelector:@selector(drawerDisplayModeDidChange:)]) {
    [((UIViewController<PulleyCDrawerViewControllerDelegate> *) [self primaryContentViewController]) drawerDisplayModeDidChange:self];
  }
  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self setNeedsSupportedDrawerPositionsUpdate];
  
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
  if ([keyPath isEqualToString:@"currentDisplayMode"]) {
    id oldC = (PulleyCDisplayMode *)[change objectForKey:NSKeyValueChangeOldKey];
    id newC = (PulleyCDisplayMode *)[change objectForKey:NSKeyValueChangeNewKey];
    if (![oldC isEqual:newC]) {
      [_delegate drawerDisplayModeDidChange: self];
      if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *) _drawerContentViewController respondsToSelector:@selector(drawerDisplayModeDidChange:)]) {
        [(UIViewController<PulleyCDrawerViewControllerDelegate> *) _drawerContentViewController drawerDisplayModeDidChange:self];
        
      }
      if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *) _primaryContentViewController respondsToSelector:@selector(drawerDisplayModeDidChange:)]) {
        [(UIViewController<PulleyCDrawerViewControllerDelegate> *) _primaryContentViewController drawerDisplayModeDidChange:self];
      }
    }
  }
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  
  if ([self primaryContentViewController] != nil) {
    if ([[[self primaryContentViewController] view] superview] != nil && ![[[[self primaryContentViewController] view] superview] isEqual: [self primaryContentContainer]]) {
      [[self primaryContentContainer] addSubview: [[self primaryContentViewController] view]];
      [[self primaryContentContainer] sendSubviewToBack:[[self primaryContentViewController] view]];
      [[[self primaryContentViewController] view] constrainToParent];
    }
  }
  
  if ([self drawerContentViewController] != nil) {
    if ([[[self drawerContentViewController] view] superview] != nil && ![[[[self drawerContentViewController] view] superview] isEqual:[self drawerContentContainer]]) {
      [[self drawerContentContainer] addSubview: [[self drawerContentViewController] view]];
      [[self drawerContentContainer] sendSubviewToBack: [[self drawerContentViewController] view]];
      [[[self drawerContentViewController] view] constrainToParent];
    }
  }
  
  CGFloat safeAreaTopInset    = [self pulleySafeAreaInsets].top;
  CGFloat safeAreaBottomInset = [self pulleySafeAreaInsets].bottom;
  CGFloat safeAreaLeftInset   = [self pulleySafeAreaInsets].left;
  CGFloat safeAreaRightInset  = [self pulleySafeAreaInsets].right;
  PulleyCDisplayMode *displayModeForCurrentLayout;
  
  if (![[self displayMode] isEqual: PulleyCDisplayMode.automatic]) {
    displayModeForCurrentLayout = [self displayMode];
  } else if ([[self view] bounds].size.width >= 600.0 || [[self traitCollection] horizontalSizeClass] == UIUserInterfaceSizeClassRegular) {
    displayModeForCurrentLayout = PulleyCDisplayMode.panel;
  } else {
    displayModeForCurrentLayout = PulleyCDisplayMode.drawer;
  }
  
  [self setCurrentDisplayMode: displayModeForCurrentLayout];
  
  
  if ([displayModeForCurrentLayout isEqual: PulleyCDisplayMode.drawer]) {
    if (@available(iOS 11.0, *)) {
      [[self drawerScrollView] setContentInsetAdjustmentBehavior: UIScrollViewContentInsetAdjustmentScrollableAxes];
    } else {
      [self setAutomaticallyAdjustsScrollViewInsets: false];
      [[self drawerScrollView] setContentInset:UIEdgeInsetsMake(0.0, 0.0, [[self bottomLayoutGuide] length], 0.0)];
      [[self drawerScrollView] setScrollIndicatorInsets: UIEdgeInsetsMake(0.0, 0.0, [[self bottomLayoutGuide] length], 0.0)];
    }
    
    CGFloat lowestStop = [[[self getStopList] firstObject] floatValue];
    
    for (NSNumber *num in [self getStopList]) {
      if ([num floatValue] < lowestStop ) {
        lowestStop = [num floatValue];
      }
    }
    
    CGFloat adjustedLeftSafeArea = [self adjustDrawerHorizontalInsetToSafeArea] ? safeAreaLeftInset : 0.0;
    CGFloat adjustedRightSafeArea = [self adjustDrawerHorizontalInsetToSafeArea] ? safeAreaRightInset : 0.0;
    
    if ([[self supportedPositions] containsObject:PulleyCPosition.open]) {
      [[self drawerScrollView] setFrame: CGRectMake(adjustedLeftSafeArea, [self drawerTopInset] + safeAreaTopInset, [[self view] bounds].size.width - adjustedLeftSafeArea - adjustedRightSafeArea, [self heightOfOpenDrawer])];
    } else {
      CGFloat adjustedTopInset = [[[self getStopList] lastObject] floatValue];
      for (NSNumber *num in [self getStopList]) {
        if ([num floatValue] > adjustedTopInset) {
          adjustedTopInset = [num floatValue];
        }
      }
      
      [[self drawerScrollView] setFrame: CGRectMake(adjustedLeftSafeArea, [[self view] bounds].size.height - adjustedTopInset, [[self view] bounds].size.width -adjustedLeftSafeArea - adjustedRightSafeArea, adjustedTopInset)];
    }
    
    [[self drawerScrollView] addSubview: [self drawerShadowView]];
    
    if ([self drawerBackgroundVisualEffectView] != nil) {
      [[self drawerScrollView] addSubview: [self drawerBackgroundVisualEffectView]];
      
      [[[self drawerBackgroundVisualEffectView] layer] setCornerRadius: [self drawerCornerRadius]];
      
    }
    
    [[self drawerScrollView] addSubview: [self drawerContentContainer]];
    
    [[self drawerContentContainer] setFrame:CGRectMake(0, [[self drawerScrollView] bounds].size.height - lowestStop, [[self drawerScrollView] bounds].size.width, [[self drawerScrollView] bounds].size.height + [self bounceOverflowMargin])];
    
    [[self drawerBackgroundVisualEffectView] setFrame: [[self drawerContentContainer] frame]];
    [[self drawerShadowView] setFrame: [[self drawerContentContainer] frame]];
    [[self drawerScrollView] setContentSize: CGSizeMake([[self drawerScrollView] bounds].size.width, ([[self drawerScrollView] bounds].size.height - lowestStop) + [[self drawerScrollView] bounds].size.height - safeAreaBottomInset + ([self bounceOverflowMargin] - 5.0))];
    
    CGPathRef borderPath = [[self drawerMaskingPath:  UIRectCornerAllCorners] CGPath];
    CAShapeLayer *cardMaskLayer = [CAShapeLayer layer];
    [cardMaskLayer setPath: borderPath];
    [cardMaskLayer setFrame:[[self drawerContentContainer] bounds]];
    [cardMaskLayer setFillColor: [[UIColor whiteColor] CGColor]];
    [cardMaskLayer setBackgroundColor: [[UIColor clearColor] CGColor]];

    [[[self drawerContentContainer] layer] setMask:cardMaskLayer];
    [[[self drawerScrollView] layer] setShadowPath:borderPath];
    
    [[self backgroundDimmingView] setFrame: CGRectMake(0.0, 0.0, [[self view] bounds].size.width, [[self view] bounds].size.height + [[self drawerScrollView] contentSize].height)];
    
    [[self drawerScrollView] setTransform: CGAffineTransformIdentity];
    [[self backgroundDimmingView] setHidden: false];
    
  } else {
    
    if (@available(iOS 11.0, *)) {
      [[self drawerScrollView] setContentInsetAdjustmentBehavior: UIScrollViewContentInsetAdjustmentScrollableAxes];
    } else {
      [self setAutomaticallyAdjustsScrollViewInsets: false];
      [[self drawerScrollView] setContentInset: UIEdgeInsetsZero];
      [[self drawerScrollView] setScrollIndicatorInsets: UIEdgeInsetsZero];
    }
    
    CGFloat collapsedHeight = kPulleyCDefaultCollapsedHeight;
    CGFloat partialRevealHeight = kPulleyCDefaultPartialRevealHeight;
    
    if ([[self drawerContentViewController] conformsToProtocol: @protocol( PulleyCDrawerViewControllerDelegate)]) {
      if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *) _drawerContentViewController respondsToSelector:@selector(collapsedDrawerHeight:)]) {
        collapsedHeight = [(UIViewController<PulleyCDrawerViewControllerDelegate> *) _drawerContentViewController collapsedDrawerHeight: safeAreaBottomInset];

      } else {
        collapsedHeight = kPulleyCDefaultCollapsedHeight;
      }
      if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *) _drawerContentViewController respondsToSelector:@selector(partialRevealDrawerHeight:)]) {
      partialRevealHeight = [(UIViewController<PulleyCDrawerViewControllerDelegate> *) _drawerContentViewController partialRevealDrawerHeight: safeAreaBottomInset];
      } else {
        partialRevealHeight = kPulleyCDefaultPartialRevealHeight;
      }
    }
      NSArray<NSNumber *> *tmpArray = [NSArray<NSNumber *> arrayWithObjects:
                                       [NSNumber numberWithFloat: [[self view] bounds].size.height - [self panelInsets].bottom - safeAreaTopInset],
                                       [NSNumber numberWithFloat: collapsedHeight],
                                       [NSNumber numberWithFloat: partialRevealHeight], nil];
      CGFloat lowestStop = [[[tmpArray sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        if ([obj1 floatValue] < [obj2 floatValue]) {
          return NSOrderedAscending;
        } else if ([obj1 floatValue] > [obj2 floatValue]) {
          return NSOrderedDescending;
        } else {
          return NSOrderedSame;
        }
      }] firstObject] floatValue];
      
    
    CGFloat xOrigin = ([[self panelCornerPlacement] isEqual: PulleyCPanelCornerPlacement.bottomLeft] || [[self panelCornerPlacement] isEqual: PulleyCPanelCornerPlacement.topLeft]) ? (safeAreaLeftInset + [self panelInsets].left) : (CGRectGetMaxX([[self view] bounds]) - (safeAreaRightInset + [self panelInsets].right - [self panelWidth]));
    
    CGFloat yOrigin = ([[self panelCornerPlacement] isEqual: PulleyCPanelCornerPlacement.bottomLeft] || [[self panelCornerPlacement] isEqual: PulleyCPanelCornerPlacement.bottomRight]) ? ([self panelInsets].top + safeAreaTopInset) : ([self panelInsets].top + safeAreaTopInset + [self bounceOverflowMargin]);
    
    if ([[self supportedPositions] containsObject:PulleyCPosition.open]) {
      [[self drawerScrollView] setFrame: CGRectMake(xOrigin, yOrigin, [self panelWidth], [self heightOfOpenDrawer])];
    } else {
      CGFloat adjustedTopInset = [[self supportedPositions] containsObject:PulleyCPosition.partiallyRevealed] ? partialRevealHeight : collapsedHeight;
      [[self drawerScrollView] setFrame: CGRectMake(xOrigin, yOrigin, [self panelWidth], adjustedTopInset)];
    }
    
    [self syncDrawerContentViewSizeToMatchScrollPositionForSideDisplayMode];
    
    [[self drawerScrollView] setContentSize: CGSizeMake([[self drawerScrollView] bounds].size.width, [[self view] bounds].size.height + [[self view] bounds].size.height - lowestStop)];
    
    if ([[self panelCornerPlacement] isEqual: PulleyCPanelCornerPlacement.topLeft] || [[self panelCornerPlacement] isEqual: PulleyCPanelCornerPlacement.topRight]) {
      [[self drawerScrollView] setTransform: CGAffineTransformMakeScale(1.0, -1.0)];
    } else {
      [[self drawerScrollView] setTransform: CGAffineTransformMakeScale(1.0, 1.0)];
    }
    
    [[self backgroundDimmingView] setHidden: true];
    
  }
  
  
  [[self drawerContentContainer] setTransform:[[self drawerScrollView] transform]];
  [[self drawerShadowView] setTransform: [[self drawerScrollView] transform]];
  [[self drawerBackgroundVisualEffectView] setTransform: [[self drawerScrollView] transform]];
  
  CGFloat lowestStop = [[[self getStopList] firstObject] floatValue];
  
  for (NSNumber *num in [self getStopList]) {
    if (lowestStop > [num floatValue]) {
      lowestStop = [num floatValue];
    }
  }
  
  [[self delegate] drawerChangedDistanceFromBottom:self distance:[[self drawerScrollView] contentOffset].y + lowestStop bottomSafeArea:[self pulleySafeAreaInsets].bottom];
  if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] respondsToSelector:@selector(drawerChangedDistanceFromBottom:distance:bottomSafeArea:)]) {
  [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] drawerChangedDistanceFromBottom:self distance:[[self drawerScrollView] contentOffset].y + lowestStop  bottomSafeArea:[self pulleySafeAreaInsets].bottom];
  }
  if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self primaryContentViewController] respondsToSelector:@selector(drawerChangedDistanceFromBottom:distance:bottomSafeArea:)]) {
      [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self primaryContentViewController] drawerChangedDistanceFromBottom:self distance:[[self drawerScrollView] contentOffset].y + lowestStop bottomSafeArea:[self pulleySafeAreaInsets].bottom];
  }

  
  [self maskDrawerVisualEffectView];
  [self maskBackgroundDimmingView];
  
  [self setDrawerPosition:[self drawerPosition] animated:false completion:nil];
  
}


- (CGFloat)bounceOverflowMargin {
    return kPulleyCBounceOverflowMargin;
}

- (void)setPrimaryContentViewController:(UIViewController *)primaryContentViewController {
    if ([self primaryContentViewController] != nil) {
        [[self primaryContentViewController] willMoveToParentViewController:nil];
        [[[self primaryContentViewController] view] removeFromSuperview];
        [[self primaryContentViewController] removeFromParentViewController];
    }
    _primaryContentViewController = primaryContentViewController;
    [self addChildViewController:_primaryContentViewController];
    [_primaryContentContainer addSubview:[_primaryContentViewController view]];
    [[_primaryContentViewController view] constrainToParent];
    [_primaryContentViewController didMoveToParentViewController:self];
    if ([self isViewLoaded]) {
        [[self view] setNeedsLayout];
        [self setNeedsSupportedDrawerPositionsUpdate];
    }
}

- (void)setDrawerContentViewController:(UIViewController *)drawerContentViewController {
    if([self drawerContentViewController] != nil) {
        [[self drawerContentViewController] willMoveToParentViewController:nil];
        [[[self drawerContentViewController] view] removeFromSuperview];
        [[self drawerContentViewController] removeFromParentViewController];
    }
    _drawerContentViewController = drawerContentViewController;
    [self addChildViewController:_drawerContentViewController];
    [_drawerContentContainer addSubview:[_drawerContentViewController view]];
    [[_drawerContentViewController view] constrainToParent];
    [_drawerContentViewController didMoveToParentViewController:self];
    if ([self isViewLoaded]) {
        [[self view] setNeedsLayout];
        [self setNeedsSupportedDrawerPositionsUpdate];
    }
}

- (CGFloat)bottomSafeSpace {
    return [self pulleySafeAreaInsets].bottom;
}


- (UIEdgeInsets)pulleySafeAreaInsets {
    CGFloat safeAreaBottomInset = 0;
    CGFloat safeAreaLeftInset   = 0;
    CGFloat safeAreaRightInset  = 0;
    CGFloat safeAreaTopInset    = 0;
    
    if(@available(iOS 11.0, *)) {
        
        safeAreaBottomInset = [self view].safeAreaInsets.bottom;
        safeAreaLeftInset   = [self view].safeAreaInsets.left;
        safeAreaRightInset  = [self view].safeAreaInsets.right;
        safeAreaTopInset    = [self view].safeAreaInsets.top;
        
    } else {
        safeAreaBottomInset = [[self bottomLayoutGuide] length];
        safeAreaTopInset = [[self topLayoutGuide] length];
    }
  
    return UIEdgeInsetsMake(safeAreaTopInset, safeAreaLeftInset, safeAreaBottomInset, safeAreaRightInset);
}

- (void)setDrawerPosition:(PulleyCPosition *)drawerPosition {
    _drawerPosition = drawerPosition;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (CGFloat)visibleDrawerHeight {
    if ([_drawerPosition isEqual: PulleyCPosition.closed]) {
        return 0.0;
    }
    return [_drawerScrollView bounds].size.height;
}

- (void)setDrawerBackgroundVisualEffectView:(UIVisualEffectView *)drawerBackgroundVisualEffectView {
    [_drawerBackgroundVisualEffectView removeFromSuperview];
    _drawerBackgroundVisualEffectView = drawerBackgroundVisualEffectView;
  if (_drawerBackgroundVisualEffectView != nil && [self isViewLoaded]) {
    [_drawerScrollView insertSubview:drawerBackgroundVisualEffectView aboveSubview:_drawerShadowView];
    [_drawerBackgroundVisualEffectView setClipsToBounds:true];
    [[_drawerBackgroundVisualEffectView layer] setCornerRadius:_drawerCornerRadius];
    [[self view] setNeedsLayout];
  }
}

- (void)setDrawerCornerRadius:(CGFloat)drawerCornerRadius {
    _drawerCornerRadius = drawerCornerRadius;
    if([self isViewLoaded]) {
        [[self view] setNeedsLayout];
        [[[self drawerBackgroundVisualEffectView] layer] setCornerRadius:drawerCornerRadius];
    }
}

- (void)setDrawerTopInset:(CGFloat)drawerTopInset {
    _drawerTopInset = drawerTopInset;
    if ([self isViewLoaded]) {
        [[self view] setNeedsLayout];
    }
}

- (void)setPanelInsets:(UIEdgeInsets)panelInsets {
    _panelInsets = panelInsets;
    if ([self isViewLoaded]) {
        [[self view] setNeedsLayout];
    }
}

- (void)setPanelWidth:(CGFloat)panelWidth {
    _panelWidth = panelWidth;
    if ([self isViewLoaded]) {
        [[self view] setNeedsLayout];
    }
}


- (void)setShadowOpacity:(float)shadowOpacity {
    _shadowOpacity = shadowOpacity;
    if ([self isViewLoaded]) {
        [[_drawerShadowView layer] setShadowOpacity:shadowOpacity];
        [[self view] setNeedsLayout];
    }
}

- (void)setShadowRadius:(CGFloat)shadowRadius {
    _shadowRadius = shadowRadius;
    if ([self isViewLoaded]) {
        [[_drawerShadowView layer] setShadowRadius:shadowRadius];
        [[self view] setNeedsLayout];
    }
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    _shadowOffset = shadowOffset;
    if ([self isViewLoaded]) {
        [[_drawerShadowView layer] setShadowOffset:shadowOffset];
        [[self view] setNeedsLayout];
    }
}

- (void)setBackgroundDimmingColor:(UIColor *)backgroundDimmingColor {
    _backgroundDimmingColor = backgroundDimmingColor;
    if ([self isViewLoaded]) {
        [[self backgroundDimmingView] setBackgroundColor:backgroundDimmingColor];
    }
}

- (void)setBackgroundDimmingOpacity:(CGFloat)backgroundDimmingOpacity {
    _backgroundDimmingOpacity = backgroundDimmingOpacity;
    if ([self isViewLoaded]) {
        [self scrollViewDidScroll:[self drawerScrollView]];
    }
}

- (void)setDelaysContentTouches:(BOOL)delaysContentTouches {
    _delaysContentTouches = delaysContentTouches;
    if ([self isViewLoaded]) {
        [[self drawerScrollView] setDelaysContentTouches:delaysContentTouches];
    }
}

- (void)setCanCancelContentTouches:(BOOL)canCancelContentTouches {
    _canCancelContentTouches = canCancelContentTouches;
    if ([self isViewLoaded]) {
        [[self drawerScrollView] setCanCancelContentTouches:canCancelContentTouches];
    }
}

- (void)setDisplayMode:(PulleyCDisplayMode *)displayMode {
    _displayMode = displayMode;
    if ([self isViewLoaded]) {
        [[self view] setNeedsLayout];
    }
}

- (void)setPanelCornerPlacement:(PulleyCPanelCornerPlacement *)panelCornerPlacement {
    _panelCornerPlacement = panelCornerPlacement;
    if ([self isViewLoaded]) {
        [[self view] setNeedsLayout];
    }
}
- (void)setInitialDrawerPositionFromIB:(NSString *)initialDrawerPositionFromIB {
    _initialDrawerPosition = [PulleyCPosition positionForString:initialDrawerPositionFromIB];
}

- (void)setAllowsUserDrawerPositionChange:(BOOL)allowsUserDrawerPositionChange {
    [self enforceCanScrollDrawer];
}

- (void)setAdjustDrawerHorizontalInsetToSafeArea:(BOOL)adjustDrawerHorizontalInsetToSafeArea {
    _adjustDrawerHorizontalInsetToSafeArea = adjustDrawerHorizontalInsetToSafeArea;
    if ([self isViewLoaded]) {
        [[self view] setNeedsLayout];
    }
}

- (DrawerDistanceFromBottom *)drawerDistanceFromBottom {
  if ([self isViewLoaded]) {
    
    CGFloat lowestStop = [[[self getStopList] firstObject] floatValue];
    
    for (NSNumber *num in [self getStopList]) {
      if (lowestStop > [num floatValue]) {
        lowestStop = [num floatValue];
      }
    }
    DrawerDistanceFromBottom *distance = malloc(sizeof(DrawerDistanceFromBottom));
    distance->distance = [_drawerScrollView contentOffset].y + lowestStop;
    distance->bottomSafeArea = [self pulleySafeAreaInsets].bottom;
    
    return distance;
  }
  DrawerDistanceFromBottom *defaultDistance = malloc(sizeof(DrawerDistanceFromBottom));
  defaultDistance->distance = 0.0;
  defaultDistance->bottomSafeArea = 0.0;
  return defaultDistance;
}

- (NSArray<UIGestureRecognizer *> *)drawerGestureRecognizers {
  return [_drawerScrollView gestureRecognizers];
}

- (UIPanGestureRecognizer *)drawerPanGestureRecognizer {
  return [_drawerScrollView panGestureRecognizer];
}

- (void)setSupportedPositions:(NSArray<PulleyCPosition *> *)supportedPositions {
  
  _supportedPositions = supportedPositions;
  if ([self isViewLoaded]) {
    if ([[self supportedPositions] count] > 0) {
      [[self view] setNeedsLayout];
      
      if ([supportedPositions containsObject: _drawerPosition]) {
        [self setDrawerPosition:_drawerPosition animated:true completion:nil];
      } else {
        PulleyCPosition *lowestDrawerState;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rawValue != %@", PulleyCPosition.closed];
        NSArray<PulleyCPosition *> *filteredArray = [[self supportedPositions] filteredArrayUsingPredicate:predicate];
        lowestDrawerState = [[filteredArray sortedArrayUsingComparator:^NSComparisonResult(PulleyCPosition *obj1, PulleyCPosition *obj2) {
          if (obj1.rawValue < obj2.rawValue) {
            return NSOrderedAscending;
          } else if (obj1.rawValue > obj2.rawValue) {
            return NSOrderedDescending;
          } else {
            return NSOrderedSame;
          }
            }] firstObject];
        
        [self setDrawerPosition:lowestDrawerState animated:false completion:nil];
      }
      
    } else {
      _supportedPositions = PulleyCPosition.all;
    }
    [self enforceCanScrollDrawer];
  }
}

- (void)setCurrentDisplayMode:(PulleyCDisplayMode *)currentDisplayMode {
  if ([self isViewLoaded]) {
    [[self view] setNeedsLayout];
  }

  _currentDisplayMode = currentDisplayMode;
}




- (CGFloat)heightOfOpenDrawer {
  CGFloat safeAreaTopInset = [self pulleySafeAreaInsets].top;
  CGFloat safeAreaBottomInset = [self pulleySafeAreaInsets].bottom;
  
  CGFloat height = [[self view] bounds].size.height - safeAreaTopInset;
  
  if ([_currentDisplayMode isEqual: PulleyCDisplayMode.panel]) {
    height -= [self panelInsets].top + [self bounceOverflowMargin];
    height -= [self panelInsets].bottom + safeAreaBottomInset;
  } else if ([_currentDisplayMode isEqual: PulleyCDisplayMode.drawer]) {
    height -= [self drawerTopInset];
  }
  
  return height;
}



- (instancetype) intiWithContentViewController:(UIViewController *) contentViewController drawerViewController:(UIViewController *) drawer {
  if ([super initWithNibName:nil bundle:nil]) {
    [self setPrimaryContentViewController:contentViewController];
    [self setDrawerContentViewController:drawer];
    [self setDefault];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    [self setDefault];
  }
  return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
  if ([super init]) {
    [[self view] setFrame:frame];
    [self setDefault];
  }
  return self;
}


- (UIBezierPath *) drawerMaskingPath:(UIRectCorner)corners {
  [[[self drawerContentViewController] view] layoutIfNeeded];
  UIBezierPath * path;
  if ([(CAShapeLayer *)_drawerContentViewController.view.layer.mask path]) {
    path = [UIBezierPath bezierPathWithCGPath:[(CAShapeLayer *)_drawerContentViewController.view.layer.mask path]];
  } else {
    path = [UIBezierPath bezierPathWithRoundedRect:[[self drawerContentContainer] bounds] byRoundingCorners:corners cornerRadii:CGSizeMake([self drawerCornerRadius], [self drawerCornerRadius])];
  }
  return path;
}


- (void) dimmingViewTapRecognizerAction:(UITapGestureRecognizer *) gestureRecognizer {
  if ([gestureRecognizer isEqual:[self dimmingViewTapRecognizer]]) {
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
      [self setDrawerPosition: PulleyCPosition.collapsed animated:true];
    }
  }
}

- (void) setDrawerPosition:(PulleyCPosition *) position animated:(BOOL) animated completion:(PulleyAnimationCompletionBlock) completion {
  
  if ([[self supportedPositions] containsObject:position]) {
    
    [self setDrawerPosition:position];
    
    CGFloat collapsedHeight = kPulleyCDefaultCollapsedHeight;
    CGFloat partialRevealHeight = kPulleyCDefaultPartialRevealHeight;
    
    if ([[self drawerContentViewController] conformsToProtocol:@protocol(PulleyCDrawerViewControllerDelegate)]) {
      collapsedHeight = [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] collapsedDrawerHeight: [self pulleySafeAreaInsets].bottom];
      if (collapsedHeight) {
        collapsedHeight = kPulleyCDefaultCollapsedHeight;
      }
      partialRevealHeight = [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] partialRevealDrawerHeight: [self pulleySafeAreaInsets].bottom];
      if (partialRevealHeight) {
        partialRevealHeight = kPulleyCDefaultPartialRevealHeight;
      }
    }
    
    CGFloat stopToMoveTo;
    
    if ([[self drawerPosition] isEqual: PulleyCPosition.collapsed]) {
      stopToMoveTo = collapsedHeight;
    } else if ([[self drawerPosition] isEqual: PulleyCPosition.partiallyRevealed]) {
      stopToMoveTo = partialRevealHeight;
    } else if ([[self drawerPosition] isEqual: PulleyCPosition.open]) {
      stopToMoveTo = [self heightOfOpenDrawer];
    } else {
      stopToMoveTo = 0.0;
    }
    
    CGFloat lowestStop = [[[self getStopList] firstObject] floatValue];
    
    for (NSNumber *num in [self getStopList]) {
      if ([num floatValue] < lowestStop ) {
        lowestStop = [num floatValue];
      }
    }
    
    [self triggerFeedbackGenerator];
    
    if (animated == true && [[self view] window] != nil) {
      [self setIsAnimatingDrawerPosition:true];
      [UIView animateWithDuration:[self animationDuration] delay:[self animationDelay] usingSpringWithDamping:[self animationSpringDamping] initialSpringVelocity:[self animationSpringInitialVelocity] options: [self animationOptions] animations:^{
        __weak PulleyCViewController * weakSelf = self;
        [[weakSelf drawerScrollView] setContentOffset: CGPointMake(0.0, stopToMoveTo - lowestStop) animated:false];
        
        [[weakSelf backgroundDimmingView] setFrame: [weakSelf backgroundDimmingViewFrameForDrawerPosition:stopToMoveTo]];
        [[weakSelf delegate] drawerPositionDidChange: weakSelf bottomSafeArea:[weakSelf pulleySafeAreaInsets].bottom];
        if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *)[weakSelf drawerContentViewController] respondsToSelector:@selector(drawerPositionDidChange:bottomSafeArea:)]) {
            [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[weakSelf drawerContentViewController] drawerPositionDidChange:weakSelf bottomSafeArea:[weakSelf pulleySafeAreaInsets].bottom];
        }
        if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *)[weakSelf primaryContentViewController] respondsToSelector:@selector(drawerPositionDidChange:bottomSafeArea:)]) {
          [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[weakSelf primaryContentViewController] drawerPositionDidChange:weakSelf bottomSafeArea:[weakSelf pulleySafeAreaInsets].bottom];
          [[weakSelf view] layoutIfNeeded];
        }
        
      } completion:^(BOOL finished) {
        __weak PulleyCViewController * weakSelf = self;
        [weakSelf setIsAnimatingDrawerPosition: false];
        [weakSelf syncDrawerContentViewSizeToMatchScrollPositionForSideDisplayMode];
        if(completion) {
          completion(finished);
        }
      }];
    } else {
      
      [[self drawerScrollView] setContentOffset:CGPointMake(0.0, stopToMoveTo - lowestStop) animated:false];
      [[self backgroundDimmingView] setFrame: [self backgroundDimmingViewFrameForDrawerPosition:stopToMoveTo]];
      [[self delegate] drawerPositionDidChange:self bottomSafeArea:[self pulleySafeAreaInsets].bottom];
      if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] respondsToSelector:@selector( drawerPositionDidChange:bottomSafeArea:)]) {
              [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] drawerPositionDidChange:self bottomSafeArea:[self pulleySafeAreaInsets].bottom];
      }
      if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self primaryContentViewController] respondsToSelector:@selector(drawerPositionDidChange:bottomSafeArea:)]) {
              [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self primaryContentViewController] drawerPositionDidChange:self bottomSafeArea:[self pulleySafeAreaInsets].bottom];
      }

      if (completion) {
        completion(true);
      }
    }

  } else {
    NSLog(@"PulleyViewController: You can't set the drawer position to something not supported by the current view controller contained in the drawer. If you haven't already, you may need to implement the PulleyDrawerViewControllerDelegate.");
  }
  
  
}

- (void)setDrawerPosition:(PulleyCPosition *)position animated:(BOOL)animated {
  
  [self setDrawerPosition:position animated:animated completion:nil];
}

- (void)setPrimaryContentViewController:(UIViewController *)controller animated:(BOOL)animated completion:(_Nullable PulleyAnimationCompletionBlock)completion {
  [[controller view] setFrame: [[self primaryContentContainer] bounds]];
  [[controller view] layoutIfNeeded];
  if (animated == true) {
    [UIView transitionWithView:[self primaryContentContainer] duration:0.5 options: UIViewAnimationOptionTransitionCrossDissolve animations:^{
      __weak PulleyCViewController * weakSelf = self;
      [weakSelf setPrimaryContentViewController: controller];
      
    } completion:^(BOOL finished) {
      if(completion) {
        completion(finished);
      }
    }];
  } else {
    [self setPrimaryContentViewController: controller];
    if (completion) {
      completion(true);
    }
  }
}

- (void) setPrimaryContentViewController:(UIViewController *)controller animated:(BOOL)animated {
  [self setPrimaryContentViewController:controller animated:animated completion: nil];
}

- (void)setDrawerContentViewController:(UIViewController *)controller animated:(BOOL)animated completion:(PulleyAnimationCompletionBlock)completion {
  [[controller view] setFrame: [[self drawerContentContainer] bounds]];
  [[controller view] layoutIfNeeded];
  if (animated == true) {
    [UIView transitionWithView:[self drawerContentContainer] duration:0.5 options: UIViewAnimationOptionTransitionCrossDissolve animations:^{
      __weak PulleyCViewController *weakSelf = self;
      [weakSelf setDrawerContentViewController: controller];
      [weakSelf setDrawerPosition: [weakSelf drawerPosition] animated:false];
    } completion:^(BOOL finished) {
      if (completion) {
        completion(finished);
      }
    }];
  } else {
    [self setDrawerContentViewController:controller];
    [self setDrawerPosition:[self drawerPosition] animated:false];
    if (completion) {
      completion(true);
    }
  }
}



- (void)setDrawerContentViewController:(UIViewController *)controller animated:(BOOL)animated {
  [self setDrawerContentViewController:controller animated:animated completion:nil];
}


- (void) setNeedsSupportedDrawerPositionsUpdate {
  
  if([[self drawerContentViewController] conformsToProtocol:@protocol(PulleyCDrawerViewControllerDelegate)]) {
    [self setSupportedPositions: [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] supportedDrawerPositions]];
  } else {
    [self setSupportedPositions: PulleyCPosition.all];
  }
}




- (NSArray<NSNumber *> *)getStopList {
  NSMutableArray<NSNumber *> *drawerStops = [NSMutableArray<NSNumber *> array];
  
  CGFloat collapsedHeight = kPulleyCDefaultCollapsedHeight;
  CGFloat partialRevealHeight = kPulleyCDefaultPartialRevealHeight;
  
  if ([[self drawerContentViewController] conformsToProtocol:@protocol(PulleyCDrawerViewControllerDelegate)]) {
    collapsedHeight = [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] collapsedDrawerHeight:[self pulleySafeAreaInsets].bottom];
    if (collapsedHeight) {
      collapsedHeight = kPulleyCDefaultCollapsedHeight;
    }
    
    partialRevealHeight = [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] partialRevealDrawerHeight: [self pulleySafeAreaInsets].bottom];
    if (partialRevealHeight) {
      partialRevealHeight = kPulleyCDefaultPartialRevealHeight;
    }
  }
  
  if ([[self supportedPositions] containsObject:PulleyCPosition.collapsed]) {
    [drawerStops addObject: [NSNumber numberWithFloat: collapsedHeight]];
  }
  
  if ([[self supportedPositions] containsObject:PulleyCPosition.partiallyRevealed]) {
    [drawerStops addObject: [NSNumber numberWithFloat:partialRevealHeight]];
  }
  
  if ([[self supportedPositions] containsObject:PulleyCPosition.open]) {
    [drawerStops addObject: [NSNumber numberWithFloat: [[self view] bounds].size.height - [self drawerTopInset] - [self pulleySafeAreaInsets].top]];
  }
  return drawerStops;
}

- (void) enforceCanScrollDrawer {
  if ([self isViewLoaded]) {
    [[self drawerScrollView] setScrollEnabled: [self allowsUserDrawerPositionChange] && [self supportedPositions].count > 1];
    
    
  }
  
}

- (void) syncDrawerContentViewSizeToMatchScrollPositionForSideDisplayMode {
  
  if ([[self currentDisplayMode] isEqual:PulleyCDisplayMode.panel]) {
    CGFloat lowestStop = [[[self getStopList] firstObject] floatValue];
    
    for (NSNumber *num in [self getStopList]) {
      if ([num floatValue] < lowestStop ) {
        lowestStop = [num floatValue];
      }
    }
    
    [[self drawerContentContainer] setFrame: CGRectMake(0.0, [[self drawerScrollView] bounds].size.height - lowestStop, [[self drawerScrollView] bounds].size.width, [[self drawerScrollView] contentOffset].y + lowestStop + [self bounceOverflowMargin])];
    [[self drawerBackgroundVisualEffectView] setFrame: [[self drawerContentContainer] frame]];
    [[self drawerShadowView] setFrame: [[self drawerContentContainer] frame]];
    CGPathRef borderPath = [[self drawerMaskingPath: UIRectCornerAllCorners] CGPath];
    CAShapeLayer *cardMaskLayer = [CAShapeLayer layer];
    
    [cardMaskLayer setPath:borderPath];
    [cardMaskLayer setFrame: [[self drawerContentContainer] bounds]];
    [cardMaskLayer setFillColor: [[UIColor whiteColor] CGColor]];
    [cardMaskLayer setBackgroundColor: [[UIColor clearColor] CGColor]];
    [[[self drawerContentContainer] layer] setMask: cardMaskLayer];
    [self maskDrawerVisualEffectView];
    if ([self isAnimatingDrawerPosition] == false || CGPathGetBoundingBox(borderPath).size.height < CGPathGetBoundingBox([[[self drawerShadowView] layer] shadowPath]).size.height) {
      [[[self drawerShadowView] layer] setShadowPath:borderPath];
    }
    
  }
}

- (void) maskDrawerVisualEffectView {
  if ([self drawerBackgroundVisualEffectView] != nil) {
    CGPathRef path = [[self drawerMaskingPath: UIRectCornerTopLeft | UIRectCornerTopRight] CGPath];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    [maskLayer setPath: path];
    [[[self drawerBackgroundVisualEffectView] layer] setMask: maskLayer];
  }
}

- (void) maskBackgroundDimmingView {
  CGFloat cutoutHeight = 2 * [self drawerCornerRadius];
  CGFloat maskHeight = [[self backgroundDimmingView] bounds].size.height - cutoutHeight - [[self drawerScrollView] contentSize].height;

  UIBezierPath *borderPath = [self drawerMaskingPath: UIRectCornerTopLeft | UIRectCornerTopRight];
  [borderPath applyTransform:CGAffineTransformMakeTranslation(0.0, maskHeight)];
  CAShapeLayer *maskLayer = [CAShapeLayer layer];

  [borderPath appendPath:[UIBezierPath bezierPathWithRect: [[self backgroundDimmingView] bounds]]];
  [maskLayer setFillRule:kCAFillRuleEvenOdd];
  [maskLayer setPath: [borderPath CGPath]];
  [[[self backgroundDimmingView] layer] setMask: maskLayer];
  
}

- (void)prepareFeedbackGenerator {
  if (@available(iOS 10.0, *)) {
    if ([[self feedbackGenerator] isKindOfClass: UIFeedbackGenerator.class]) {
      [(UIFeedbackGenerator *)[self feedbackGenerator] prepare];
    }
  }
}

- (void)triggerFeedbackGenerator {
  if (@available(iOS 10.0, *)) {
    [self prepareFeedbackGenerator];
    if ([[self feedbackGenerator] isKindOfClass: UIImpactFeedbackGenerator.class]) {
      [(UIImpactFeedbackGenerator *)[self feedbackGenerator] impactOccurred];
    }
    if ([[self feedbackGenerator] isKindOfClass:UISelectionFeedbackGenerator.class]) {
      [(UISelectionFeedbackGenerator *)[self feedbackGenerator] selectionChanged];
    }
    if([[self feedbackGenerator] isKindOfClass:UINotificationFeedbackGenerator.class]) {
          [(UINotificationFeedbackGenerator *)[self feedbackGenerator] notificationOccurred: UINotificationFeedbackTypeSuccess];
    }

  }
}

- (void)addDrawerGestureRecognizer:(UIGestureRecognizer *)recognizer {
  [[self drawerScrollView] addGestureRecognizer: recognizer];
}

- (void)removeDrawerGestureRecognizer:(UIGestureRecognizer *)recognizer {
  [[self drawerScrollView] removeGestureRecognizer: recognizer];
}

- (void)bounceDrawer:(CGFloat)height speedMultiplier:(CGFloat)multimplier {
  if ([[self drawerPosition] isEqual: PulleyCPosition.collapsed] || [[self drawerPosition] isEqual: PulleyCPosition.partiallyRevealed]) {
    if([[self currentDisplayMode] isEqual: PulleyCDisplayMode.drawer]) {
      CGRect drawerStartingBounds = [[self drawerScrollView] bounds];
      NSArray<NSNumber *> *factors = [NSArray arrayWithObjects: @0, @32, @60, @83, @100, @114, @124, @128, @128, @124, @114, @100, @83, @60, @32, @0, @24, @42, @54, @62, @64, @62, @54, @42, @24, @0, @18, @28, @32, @28, @18, @0, nil];
      NSMutableArray<NSNumber *> *values = [NSMutableArray<NSNumber *> array];
      
      for (NSNumber *obj in factors) {
        [values addObject: [NSNumber numberWithFloat: drawerStartingBounds.origin.y + (([obj floatValue] / 128.0) * height)]];
      }
      CAKeyframeAnimation *animation = [[CAKeyframeAnimation alloc] init];
      [animation setKeyPath:@"bounds.origin.y"];
      [animation setRepeatCount:1];
      [animation setDuration: (32.0/30.0) * multimplier];
      [animation setFillMode:kCAFillModeBackwards];
      [animation setValues: values];
      [animation setRemovedOnCompletion: true];
      [animation setAutoreverses:false];
      
      [[[self drawerScrollView] layer] addAnimation:animation forKey:@"bounceAnimation"];
    } else {
      NSLog(@"Pulley: Error: You can only bounce the drawer when it's in the .drawer display mode.");
    }
  } else {
    NSLog(@"Pulley: Error: You can only bounce the drawer when it's in the collapsed or partially revealed position.");

  }
}

- (CGRect) backgroundDimmingViewFrameForDrawerPosition:(CGFloat)drawerPosition {
  CGFloat cutoutHeight = (2 * [self drawerCornerRadius]);
  CGRect backgroundDimmingViewFrame = [[self backgroundDimmingView] frame];
  backgroundDimmingViewFrame.origin.y = 0 - drawerPosition + cutoutHeight;
  return backgroundDimmingViewFrame;
}


- (UIViewController *)childViewControllerForStatusBarStyle {
  if ([[self drawerPosition] isEqual: PulleyCPosition.open]) {
    return [self drawerContentViewController];
  } else {
    return [self primaryContentViewController];
  }
}

- (UIViewController *)childViewControllerForStatusBarHidden {
  if ([[self drawerPosition] isEqual: PulleyCPosition.open]) {
    return [self drawerContentViewController];
  } else {
    return [self primaryContentViewController];
  }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
  if(@available(iOS 10.0, *)) {
    [coordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
      __weak PulleyCViewController *weakSelf = self;
      if ([weakSelf drawerPosition] != nil) {
        [weakSelf setDrawerPosition: [weakSelf drawerPosition] animated:false];
      }
    }];
  } else {
    [coordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
      __weak PulleyCViewController *weakSelf = self;
      if ([weakSelf drawerPosition] != nil) {
        [weakSelf setDrawerPosition:[weakSelf drawerPosition] animated:false];
      }
    }];
  }
}

- (CGFloat)collapsedDrawerHeight:(CGFloat)bottomSafeArea {
  if ([[self drawerContentViewController] conformsToProtocol: @protocol(PulleyCDrawerViewControllerDelegate)]) {
    return [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] collapsedDrawerHeight:bottomSafeArea];
  } else {
    return 68.0 + bottomSafeArea;
  }
}

- (CGFloat)partialRevealDrawerHeight:(CGFloat)bottomSafeArea {
  if ([[self drawerContentViewController] conformsToProtocol: @protocol(PulleyCDrawerViewControllerDelegate)]) {
    return [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] partialRevealDrawerHeight:bottomSafeArea];
  } else {
    return 264.0 + bottomSafeArea;
  }
}

- (NSArray<PulleyCPosition *> *)supportedDrawerPositions {
  if ([[self drawerContentViewController] conformsToProtocol: @protocol(PulleyCDrawerViewControllerDelegate)]) {
    return [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] supportedDrawerPositions];
  } else {
    return PulleyCPosition.all;
  }
}

- (void)drawerPositionDidChange:(PulleyCViewController *)drawer bottomSafeArea:(CGFloat)bottomSafeArea {
  if ([[self drawerContentViewController] conformsToProtocol: @protocol(PulleyCDrawerViewControllerDelegate)]) {
    if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] respondsToSelector:@selector(drawerPositionDidChange:bottomSafeArea:)]) {
    [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] drawerPositionDidChange:drawer bottomSafeArea:bottomSafeArea];
    }
  }
}

- (void)makeUIAdjustmentsForFullscreen:(CGFloat)progress bottomSafeArea:(CGFloat)safeArea {
  if ([[self drawerContentViewController] conformsToProtocol: @protocol(PulleyCDrawerViewControllerDelegate)]) {
    if([(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] respondsToSelector:@selector(makeUIAdjustmentsForFullscreen:bottomSafeArea:)]) {
    [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] makeUIAdjustmentsForFullscreen:progress bottomSafeArea:safeArea];
    }
  }
}

- (void)drawerChangedDistanceFromBottom:(PulleyCViewController *)drawer distance:(CGFloat)distance bottomSafeArea:(CGFloat)safeArea {
  if ([[self drawerContentViewController] conformsToProtocol: @protocol(PulleyCDrawerViewControllerDelegate)]) {
    if ([[self drawerContentViewController] respondsToSelector:@selector(drawerChangedDistanceFromBottom:distance:bottomSafeArea:)]) {
       [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] drawerChangedDistanceFromBottom:drawer distance:distance bottomSafeArea:safeArea];
    }
   
  }
}

- (BOOL)shouldTouchPassthroughScrollView:(PulleyCPassthroughScrollView *)scrollView point:(CGPoint)point {
  
  return !CGRectContainsPoint([[self drawerContentContainer] bounds], [[self drawerContentContainer] convertPoint:point fromView:scrollView]);
}

- (UIView *)viewToReceiveTouch:(PulleyCPassthroughScrollView *)scrollView point:(CGPoint)point {
  
  if ([[self currentDisplayMode] isEqual: PulleyCDisplayMode.drawer]) {
    
    if ([[self drawerPosition] isEqual: PulleyCPosition.open]) {
      
      return [self backgroundDimmingView];
      
    }
    
    return [self primaryContentContainer];
    
  } else {
    
    if (CGRectContainsPoint([[self drawerContentContainer] bounds], [[self drawerContentContainer] convertPoint:point fromView:scrollView])) {
      
      return [[self drawerContentViewController] view];
      
    }
    
    return [self primaryContentContainer];
    
  }
  
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if ([scrollView isEqual:[self drawerScrollView]]) {
    CGFloat collapsedHeight = kPulleyCDefaultCollapsedHeight;
    CGFloat partialRevealHeight = kPulleyCDefaultPartialRevealHeight;
    
    if ([[self drawerContentViewController] conformsToProtocol:@protocol(PulleyCDrawerViewControllerDelegate)]) {
      collapsedHeight = [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] collapsedDrawerHeight:[self pulleySafeAreaInsets].bottom];
      if (collapsedHeight) {
        collapsedHeight = kPulleyCDefaultCollapsedHeight;
      }
      partialRevealHeight = [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] partialRevealDrawerHeight:[self pulleySafeAreaInsets].bottom];
      if (partialRevealHeight) {
        partialRevealHeight = kPulleyCDefaultPartialRevealHeight;
      }
    }
    
    
    NSMutableArray<NSNumber *> *drawerStops = [NSMutableArray<NSNumber *> array];
    CGFloat currentDrawerPositionStop = 0.0;
    if ([[self supportedPositions] containsObject:PulleyCPosition.open]) {
      [drawerStops addObject: [NSNumber numberWithFloat: [self heightOfOpenDrawer]]];
      if ([[self drawerPosition] isEqual: PulleyCPosition.open]) {
        currentDrawerPositionStop = [[drawerStops lastObject] floatValue];
      }
    }
    
    if ([[self supportedPositions] containsObject:PulleyCPosition.collapsed]) {
      [drawerStops addObject: [NSNumber numberWithFloat:collapsedHeight]];
      if ([[self drawerPosition] isEqual: PulleyCPosition.collapsed]) {
        currentDrawerPositionStop = [[drawerStops lastObject] floatValue];
      }
    }
    
    if ([[self supportedPositions] containsObject:PulleyCPosition.partiallyRevealed]) {
      [drawerStops addObject: [NSNumber numberWithFloat: partialRevealHeight]];
      if ([[self drawerPosition] isEqual: PulleyCPosition.partiallyRevealed]) {
        currentDrawerPositionStop = [[drawerStops lastObject] floatValue];
      }
    }
    
    CGFloat lowestStop = [[[self getStopList] firstObject] floatValue];
    
    for (NSNumber *num in [self getStopList]) {
      if ([num floatValue] < lowestStop ) {
        lowestStop = [num floatValue];
      }
    }
    
    CGFloat distanceFromBottomOfView = lowestStop + [self lastDragTargetContentOffset].y;
    
    CGFloat currentClosestStop = lowestStop;
    
    for (NSNumber *currentStop in drawerStops) {
      if (fabs([currentStop floatValue] - distanceFromBottomOfView) < fabs(currentClosestStop - distanceFromBottomOfView)) {
        currentClosestStop = [currentStop floatValue];
      }
    }
    
    PulleyCPosition *closestValidDrawerPosition = [self drawerPosition];
    if (fabs(currentClosestStop - [self heightOfOpenDrawer]) <= FLT_EPSILON && [[self supportedPositions] containsObject:PulleyCPosition.open]) {
      closestValidDrawerPosition = PulleyCPosition.open;
    } else if (fabs(currentClosestStop - collapsedHeight) <= FLT_EPSILON && [[self supportedPositions] containsObject:PulleyCPosition.collapsed]) {
      closestValidDrawerPosition = PulleyCPosition.collapsed;
    } else if ([[self supportedPositions] containsObject:PulleyCPosition.partiallyRevealed]) {
      closestValidDrawerPosition = PulleyCPosition.partiallyRevealed;
    }
    
    PulleyCSnapMode *snapModeToUse = [closestValidDrawerPosition isEqual:[self drawerPosition]] ? [self  snapMode] : [PulleyCSnapMode nearestPosition];
    
    if ([snapModeToUse isEqual: [PulleyCSnapMode nearestPosition]]) {
      [self setDrawerPosition:closestValidDrawerPosition animated:true];
    } else {
      CGFloat distance = currentDrawerPositionStop - distanceFromBottomOfView;
      PulleyCPosition *positionToSnapTo = [self drawerPosition];
      
      if (fabs(distance) > [snapModeToUse rawValue]) {
        if (distance < 0) {
          NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rawValue != %@", PulleyCPosition.closed];

          NSArray<PulleyCPosition *> *orderedSupportedDrawerPositions = [[[self supportedPositions] sortedArrayUsingComparator:^NSComparisonResult(PulleyCPosition *obj1, PulleyCPosition *obj2) {
            if (obj1.rawValue < obj2.rawValue) {
              return NSOrderedAscending;
            } else if (obj1.rawValue > obj2.rawValue) {
              return NSOrderedDescending;
            } else {
              return NSOrderedSame;
            }
          }] filteredArrayUsingPredicate:predicate];
          
          for (PulleyCPosition *position in orderedSupportedDrawerPositions) {
            if (position.rawValue > [self drawerPosition].rawValue) {
              positionToSnapTo = position;
              break;
            }
          }
        } else {
          NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rawValue != %@", PulleyCPosition.closed];
          
          NSArray<PulleyCPosition *> *orderedSupportedDrawerPositions = [[[self supportedPositions] sortedArrayUsingComparator:^NSComparisonResult(PulleyCPosition *obj1, PulleyCPosition *obj2) {
            if (obj1.rawValue > obj2.rawValue) {
              return NSOrderedAscending;
            } else if (obj1.rawValue < obj2.rawValue) {
              return NSOrderedDescending;
            } else {
              return NSOrderedSame;
            }
          }] filteredArrayUsingPredicate:predicate];
          for (PulleyCPosition *position in orderedSupportedDrawerPositions) {
            if (position.rawValue < [self drawerPosition].rawValue) {
              positionToSnapTo = position;
              break;
            }
          }
        }
      }
      [self setDrawerPosition:positionToSnapTo animated:true];
    }
    
  }
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
  if([scrollView isEqual:[self drawerScrollView]]) {
    [self setLastDragTargetContentOffset:*targetContentOffset];
    *targetContentOffset = [scrollView contentOffset];
  }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if([scrollView isEqual: [self drawerScrollView]]) {

    CGFloat partialRevealHeight = [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] partialRevealDrawerHeight:[self pulleySafeAreaInsets].bottom];
    if(partialRevealHeight) {
      partialRevealHeight = kPulleyCDefaultPartialRevealHeight;
      
      CGFloat lowestStop = [[[self getStopList] firstObject] floatValue];
      
      for (NSNumber *num in [self getStopList]) {
        if ([num floatValue] < lowestStop ) {
          lowestStop = [num floatValue];
        }
      }

      
      if([scrollView contentOffset].y - [self pulleySafeAreaInsets].bottom > (partialRevealHeight - lowestStop) && [[self supportedPositions] containsObject:PulleyCPosition.open]) {
        CGFloat fullRevealHeight = [self heightOfOpenDrawer];
        CGFloat progress;
        if (fullRevealHeight == partialRevealHeight) {
          progress = 1.0;
        } else {
          progress = ([scrollView contentOffset].y - (partialRevealHeight - lowestStop)) / (fullRevealHeight - (partialRevealHeight));
        }
        [[self delegate] makeUIAdjustmentsForFullscreen:progress bottomSafeArea:[self pulleySafeAreaInsets].bottom];
        if([(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] respondsToSelector:@selector(makeUIAdjustmentsForFullscreen:bottomSafeArea:)]) {
                  [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] makeUIAdjustmentsForFullscreen:progress bottomSafeArea:[self pulleySafeAreaInsets].bottom];
          
        }
        if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self primaryContentViewController] respondsToSelector:@selector(makeUIAdjustmentsForFullscreen:bottomSafeArea:)]) {
                          [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self primaryContentViewController] makeUIAdjustmentsForFullscreen:progress bottomSafeArea:[self pulleySafeAreaInsets].bottom];
          
          
        }
        [[self backgroundDimmingView] setAlpha: progress * [self backgroundDimmingOpacity]];
        [[self backgroundDimmingView] setUserInteractionEnabled:true];

      } else {
        
        if ([[self backgroundDimmingView] alpha] >= 0.001) {
          [[self backgroundDimmingView] setAlpha:0.0];
          [[self delegate] makeUIAdjustmentsForFullscreen:0.0 bottomSafeArea:[self pulleySafeAreaInsets].bottom];
          if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] respondsToSelector:@selector(makeUIAdjustmentsForFullscreen:bottomSafeArea:)]) {
                      [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] makeUIAdjustmentsForFullscreen:0.0 bottomSafeArea:[self pulleySafeAreaInsets].bottom];
          }
          if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self primaryContentViewController] respondsToSelector:@selector(makeUIAdjustmentsForFullscreen:bottomSafeArea:)]) {
                      [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self primaryContentViewController] makeUIAdjustmentsForFullscreen:0.0 bottomSafeArea:[self pulleySafeAreaInsets].bottom];
          }


          [[self backgroundDimmingView] setUserInteractionEnabled:false];
          
        }

      }
      [[self delegate] drawerChangedDistanceFromBottom:self distance:[scrollView contentOffset].y + lowestStop bottomSafeArea:[self pulleySafeAreaInsets].bottom];
      
      if([(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] respondsToSelector:@selector(drawerChangedDistanceFromBottom:distance:bottomSafeArea:)]) {
        [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self drawerContentViewController] drawerChangedDistanceFromBottom:self distance:[scrollView contentOffset].y + lowestStop bottomSafeArea:[self pulleySafeAreaInsets].bottom];
      }
      if ([(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self primaryContentViewController] respondsToSelector:@selector(drawerChangedDistanceFromBottom:distance:bottomSafeArea:)]) {
        [(UIViewController<PulleyCDrawerViewControllerDelegate> *)[self primaryContentViewController] drawerChangedDistanceFromBottom:self distance:[scrollView contentOffset].y + lowestStop bottomSafeArea:[self pulleySafeAreaInsets].bottom];
      }
      

      [[self backgroundDimmingView] setFrame:[self backgroundDimmingViewFrameForDrawerPosition:[scrollView contentOffset].y + lowestStop]];
      
      [self syncDrawerContentViewSizeToMatchScrollPositionForSideDisplayMode];
    }
  }
}


- (void)dealloc {
  [self removeObserver:self forKeyPath:@"currentDisplayMode"];
}


@end

@implementation UIViewController (TestTest)



- (PulleyCViewController * _Nullable )pulleyViewController {
  UIViewController * parentVC = [self parentViewController];
  while (parentVC != nil) {
    if([parentVC isKindOfClass:PulleyCViewController.class]) {
      
      return (PulleyCViewController *)parentVC;
    }
    parentVC = [parentVC parentViewController];
  }
  return NULL;
}
@end
