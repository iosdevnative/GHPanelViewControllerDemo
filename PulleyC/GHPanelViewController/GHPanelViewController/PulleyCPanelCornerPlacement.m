//
//  PulleyCPanelCornerPlacement.m
//  PulleyC
//
//  Created by Artem Kedrov on 12/3/18.
//  Copyright © 2018 Artem Kedrov. All rights reserved.
//

#import "PulleyCPanelCornerPlacement.h"


@interface PulleyCPanelCornerPlacement ()
@property (nonatomic, assign) int rawValue;

@end


@implementation PulleyCPanelCornerPlacement

- (instancetype)initWithRawVale:(int)rawValue {
    if ([super init]) {
        [self setRawValue:rawValue];
    }
    return self;
}

+ (PulleyCPanelCornerPlacement *)topLeft {
    return [[PulleyCPanelCornerPlacement alloc] initWithRawVale:0];
}

+ (PulleyCPanelCornerPlacement *)topRight {
    return [[PulleyCPanelCornerPlacement alloc] initWithRawVale:1];
}

+ (PulleyCPanelCornerPlacement *)bottomLeft {
    return [[PulleyCPanelCornerPlacement alloc] initWithRawVale:2];
}

+ (PulleyCPanelCornerPlacement *)bottomRight {
    return [[PulleyCPanelCornerPlacement alloc] initWithRawVale:3];
}

- (BOOL)isEqual:(PulleyCPanelCornerPlacement *)object {
  return [self rawValue] == [object rawValue];
}
@end
