//
//  PrimaryContentViewController.m
//  PulleyC
//
//  Created by user1 on 12/3/18.
//

#import "PrimaryContentViewController.h"
@interface PrimaryContentViewController ()<PulleyCDrawerViewControllerDelegate>

@end

@implementation PrimaryContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  _temperatureLabelBottomDistance = 8.0;
  [[_controlsContainer layer] setCornerRadius:10.0];
  [[_temperatureLabel layer] setCornerRadius:7.0];
  
  
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[self pulleyViewController] setDisplayMode: PulleyCDisplayMode.automatic];
}

- (void)makeUIAdjustmentsForFullscreen:(CGFloat)progress bottomSafeArea:(CGFloat)safeArea {
  
  if ([self pulleyViewController] != nil) {
    
    if ([[[self pulleyViewController] currentDisplayMode] isEqual: PulleyCDisplayMode.drawer]) {
      [_controlsContainer setAlpha: 1.0 - progress];
    }
  } else {
    [_controlsContainer setAlpha: 1.0];
  }

}


- (void)drawerChangedDistanceFromBottom:(PulleyCViewController *)drawer distance:(CGFloat)distance bottomSafeArea:(CGFloat)safeArea {
  
  if ([[drawer currentDisplayMode] isEqual:PulleyCDisplayMode.drawer]) {
    if (distance <= 268 + safeArea) {
      [_temperatureLabelBottomConstraint setConstant: distance +_temperatureLabelBottomDistance];
    } else {
      [_temperatureLabelBottomConstraint setConstant: 268.0 + _temperatureLabelBottomDistance];
    }
  } else {
    [_temperatureLabelBottomConstraint setConstant:_temperatureLabelBottomDistance];
  }

}

- (IBAction)run1:(UIButton *)sender {
  
  UIViewController *primaryContent = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PrimaryTransitionTargetViewController"];
  [[self pulleyViewController] setPrimaryContentViewController:primaryContent animated:false completion:nil];
}

- (IBAction)run2:(UIButton *)sender {
  UIViewController *primaryContent = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PrimaryTransitionTargetViewController"];
  [[self pulleyViewController] setPrimaryContentViewController:primaryContent animated:true completion:nil];
}
@end
