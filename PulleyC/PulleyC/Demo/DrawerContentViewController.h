//
//  DrawerContentViewController.h
//  PulleyC
//
//  Created by user1 on 12/3/18.
//

#import <UIKit/UIKit.h>
#import <GHPanelViewController/GHPanelViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface DrawerContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *gripperView;
@property (weak, nonatomic) IBOutlet UIView *topSeparatorView;
@property (weak, nonatomic) IBOutlet UIView *bottomSeparatorView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *gripperViewTopConstraint;


@property (nonatomic) CGFloat drawerBottomSafeArea;

@property (nonatomic) BOOL shouldDisplayCustomMaskExample;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *headerSectionHeightConstraint;

@end

NS_ASSUME_NONNULL_END
