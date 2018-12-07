//
//  PrimaryTransitionTargetViewController.m
//  PulleyC
//
//  Created by user1 on 12/3/18.
//

#import "PrimaryTransitionTargetViewController.h"
@interface PrimaryTransitionTargetViewController ()

@end

@implementation PrimaryTransitionTargetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (IBAction)goBack:(UIButton *)sender {
  
  UIViewController *primaryContent = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PrimaryContentViewController"];
  
  [[self pulleyViewController] setPrimaryContentViewController:primaryContent animated:true completion:nil];
  
}

@end
