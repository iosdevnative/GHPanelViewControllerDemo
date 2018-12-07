//
//  PulleyCDisplayMode.m
//  PulleyC
//
//  Created by Artem Kedrov on 12/3/18.
//  Copyright © 2018 Artem Kedrov. All rights reserved.
//

#import "PulleyCDisplayMode.h"

@interface PulleyCDisplayMode ()
@property (nonatomic, assign) int rawValue;

@end

@implementation PulleyCDisplayMode
- (instancetype)initWithRawValue:(int)rawValue {
    if ([super init]) {
        [self setRawValue:rawValue];
    }
    return self;
}

+ (PulleyCDisplayMode *)panel {
    return [[PulleyCDisplayMode alloc] initWithRawValue:0];
}

+ (PulleyCDisplayMode *)drawer {
    return [[PulleyCDisplayMode alloc] initWithRawValue:1];
}

+ (PulleyCDisplayMode *)automatic {
    return [[PulleyCDisplayMode alloc] initWithRawValue:2];
}

- (int)rawValue {
    return _rawValue;
}

- (BOOL)isEqual:(PulleyCDisplayMode *)object {
  return self.rawValue == [object rawValue];
}

- (NSString *)description
{
  switch ([self rawValue]) {
    case 0:
      return @"Panel";
      break;
    case 1:
      return @"Drawer";
      break;
    case 2:
      return @"Automatic";
      break;
      
    default:
      return @"N/A";
      break;
  }
}


@end
