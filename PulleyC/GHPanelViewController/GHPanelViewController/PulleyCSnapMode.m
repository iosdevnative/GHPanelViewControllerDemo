//
//  PulleyCSnapMode.m
//  PulleyC
//
//  Created by Artem Kedrov on 12/3/18.
//  Copyright © 2018 Artem Kedrov. All rights reserved.
//

#import "PulleyCSnapMode.h"

@interface PulleyCSnapMode ()
@property (nonatomic, assign) CGFloat value;
@end


@implementation PulleyCSnapMode
- (instancetype)initWithRawValue:(CGFloat) rawValue
{
  self = [super init];
  if (self) {
    [self setValue:rawValue];
  }
  return self;
}

+ (PulleyCSnapMode *)nearestPosition {
  return [[PulleyCSnapMode alloc] initWithRawValue:0.0];
}
+ (PulleyCSnapMode *)nearestPositionUnlessExceeded:(CGFloat)value {
  return [[PulleyCSnapMode  alloc] initWithRawValue:value];
}

- (BOOL)isEqual:(PulleyCSnapMode *)object {
  return [self value] == [object value];
}
- (CGFloat)rawValue {
  return [self value];
}
@end
