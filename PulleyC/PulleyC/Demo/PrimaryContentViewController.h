//
//  PrimaryContentViewController.h
//  PulleyC
//
//  Created by user1 on 12/3/18.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GHPanelViewController/GHPanelViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface PrimaryContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *controlsContainer;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *temperatureLabelBottomConstraint;
- (IBAction)run1:(UIButton *)sender;
- (IBAction)run2:(UIButton *)sender;

@property (nonatomic) CGFloat temperatureLabelBottomDistance;
@end

NS_ASSUME_NONNULL_END
