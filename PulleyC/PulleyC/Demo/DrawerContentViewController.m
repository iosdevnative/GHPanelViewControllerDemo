//
//  DrawerContentViewController.m
//  PulleyC
//
//  Created by user1 on 12/3/18.
//

#import "DrawerContentViewController.h"
#import "CustomMaskExample.h"

@interface DrawerContentViewController ()<PulleyCDrawerViewControllerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@end

@implementation DrawerContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  [_searchBar setDelegate:self];
  [_tableView setDataSource:self];
  [_tableView setDelegate:self];
  
  _shouldDisplayCustomMaskExample = false;
  _drawerBottomSafeArea = 0.0;
  [[_gripperView layer] setCornerRadius:2.5];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (@available(iOS 10.0, *)) {
    UIFeedbackGenerator *feedbackGenerator = [[UIFeedbackGenerator alloc] init];
    [[self pulleyViewController] setFeedbackGenerator:feedbackGenerator];
  }
}
- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  
  if (_shouldDisplayCustomMaskExample) {
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    [maskLayer setPath: [[[[CustomMaskExample alloc] init] customMaskForBounds:[[self view] bounds]]CGPath]];
    [[[self view] layer] setMask:maskLayer];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(bounceDrawer) userInfo:nil repeats:false];

}

- (void) bounceDrawer {
  [[self pulleyViewController] bounceDrawer:50.0 speedMultiplier:0.75];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)setDrawerBottomSafeArea:(CGFloat)drawerBottomSafeArea {
  _drawerBottomSafeArea = drawerBottomSafeArea;
  [self loadViewIfNeeded];
  [_tableView setContentInset: UIEdgeInsetsMake(0.0, 0.0, drawerBottomSafeArea, 0.0)];
}

- (CGFloat)collapsedDrawerHeight:(CGFloat)bottomSafeArea {
  
  return 68 + (([[[self pulleyViewController] currentDisplayMode] isEqual:PulleyCDisplayMode.drawer]) ? bottomSafeArea : 0.0);
}

- (CGFloat)partialRevealDrawerHeight:(CGFloat)bottomSafeArea {
  
  return 264.0 + (([[[self pulleyViewController] currentDisplayMode] isEqual:PulleyCDisplayMode.drawer]) ? bottomSafeArea : 0.0);
}

- (NSArray<PulleyCPosition *> *)supportedDrawerPositions {
  return PulleyCPosition.all;
}



- (void)drawerPositionDidChange:(PulleyCViewController *)aDrawer bottomSafeArea:(CGFloat)bottomSafeArea {
  [self setDrawerBottomSafeArea:bottomSafeArea];
  
  if ([aDrawer.drawerPosition isEqual: PulleyCPosition.collapsed]) {
    [_headerSectionHeightConstraint setConstant:68.0  + _drawerBottomSafeArea];
  } else {
    [_headerSectionHeightConstraint setConstant:68.0];
  }
  
  [_tableView setScrollEnabled: [[aDrawer drawerPosition] isEqual:PulleyCPosition.open] || [[aDrawer currentDisplayMode] isEqual:PulleyCDisplayMode.panel]];
  
  if (![[aDrawer drawerPosition] isEqual: PulleyCPosition.open]) {
    [_searchBar resignFirstResponder];
  }
  
  if ([[aDrawer currentDisplayMode] isEqual:PulleyCDisplayMode.panel]) {
  
    [_topSeparatorView setHidden: [[aDrawer drawerPosition] isEqual:PulleyCPosition.collapsed]];
    [_bottomSeparatorView setHidden: [[aDrawer drawerPosition] isEqual: PulleyCPosition.collapsed]];
  } else {
    [_topSeparatorView setHidden:false];
    [_bottomSeparatorView setHidden:true];
  }
  
  
  
}

- (void)drawerDisplayModeDidChange:(PulleyCViewController *) aDrawer {
  [[self gripperViewTopConstraint] setActive:[[aDrawer currentDisplayMode] isEqual:PulleyCDisplayMode.drawer]];
  
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
  
  [[self pulleyViewController] setDrawerPosition:PulleyCPosition.open animated:true];
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return [tableView dequeueReusableCellWithIdentifier:@"SampleCell" forIndexPath:indexPath];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 81.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UIViewController * primaryContent = [[UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"PrimaryTransitionTargetViewController"];
  [[self pulleyViewController] setDrawerPosition:PulleyCPosition.collapsed animated:true];
  [[self pulleyViewController] setPrimaryContentViewController:primaryContent animated: false];
}
@end
