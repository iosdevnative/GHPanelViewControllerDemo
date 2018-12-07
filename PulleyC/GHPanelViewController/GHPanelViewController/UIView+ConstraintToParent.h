//
//  UIView+ConstraintToParent.h
//  PulleyC
//
//  Created by Artem Kedrov on 12/3/18.
//  Copyright © 2018 Artem Kedrov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ConstraintToParent)

-(void)constrainToParent;
-(void)constrainToParent: (UIEdgeInsets) insets;

@end

NS_ASSUME_NONNULL_END
