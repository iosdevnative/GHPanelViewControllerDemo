//
//  PulleyCPassthroughScrollView.h
//  PulleyC
//
//  Created by Artem Kedrov on 12/3/18.
//  Copyright © 2018 Artem Kedrov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PulleyCDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface PulleyCPassthroughScrollView : UIScrollView
@property (nullable ,weak, nonatomic) id<PulleyCPassthroughScrollViewDelegate> touchDelegate;

@end

NS_ASSUME_NONNULL_END
