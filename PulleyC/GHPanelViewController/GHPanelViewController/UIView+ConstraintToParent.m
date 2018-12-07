//
//  UIView+ConstraintToParent.m
//  PulleyC
//
//  Created by Artem Kedrov on 12/3/18.
//  Copyright © 2018 Artem Kedrov. All rights reserved.
//

#import "UIView+ConstraintToParent.h"

@implementation UIView (ConstraintToParent)
- (void)constrainToParent {
    [self constrainToParent:UIEdgeInsetsZero];
}

- (void)constrainToParent:(UIEdgeInsets)insets {
    if ([self superview] != nil) {
        [self setTranslatesAutoresizingMaskIntoConstraints:false];
        NSArray<NSString *> *keys = [NSArray<NSString *> arrayWithObjects:
                                     @"left", @"right", @"top", @"bottom", nil];
        NSArray<NSNumber *> *objects = [NSArray<NSNumber *> arrayWithObjects:
                                        [NSNumber numberWithFloat:insets.left],
                                        [NSNumber numberWithFloat:insets.right],
                                        [NSNumber numberWithFloat:insets.top],
                                        [NSNumber numberWithFloat:insets.bottom], nil];
        
        NSDictionary<NSString *, NSNumber *> *metrics = [NSDictionary<NSString *, NSNumber *> dictionaryWithObjects:objects forKeys:keys];
        
        NSArray<NSLayoutConstraint *> *constrHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[view]-(right)-|"
                                                                                              options:0
                                                                                              metrics:metrics
                                                                                                views:@{@"view" : self}];
        NSArray<NSLayoutConstraint *> * constrWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[view]-(bottom)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:@{@"view" : self}];
        NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray<NSLayoutConstraint *> arrayWithArray:constrHeight];
        [constraints addObjectsFromArray:constrWidth];
        [[self superview] addConstraints: constraints];
    }
}
@end
