//
//  PulleyCPosition.m
//  PulleyC
//
//  Created by Artem Kedrov on 12/3/18.
//  Copyright © 2018 Artem Kedrov. All rights reserved.
//

#import "PulleyCPosition.h"

static NSString * const Collapsed          = @"collapsed";
static NSString * const Partiallyrevealed  = @"partiallyrevealed";
static NSString * const Open               = @"open";
static NSString * const Closed             = @"closed";

@interface PulleyCPosition ()
@property (nonatomic, assign, readwrite) int rawValue;
@end

@implementation PulleyCPosition

- (instancetype)initWithRawValue:(int)rawValue {
  if ([super init]) {
    [self setRawValue:rawValue];
    
  }
  return self;
}

+ (PulleyCPosition *)collapsed {
  return [[PulleyCPosition alloc] initWithRawValue:0];
}

+ (PulleyCPosition *)partiallyRevealed {
  return [[PulleyCPosition alloc] initWithRawValue:1];
}

+ (PulleyCPosition *)open {
  return [[PulleyCPosition alloc] initWithRawValue:2];
}

+ (PulleyCPosition *)closed {
  return [[PulleyCPosition alloc] initWithRawValue:3];
}

+ (PulleyCPosition *)positionForString:(nullable NSString *)string {
  if (string) {
    NSString *copyString = [string copy];
    if ([copyString isEqualToString: Collapsed]) {
      return PulleyCPosition.collapsed;
    } else if ([copyString isEqualToString:Partiallyrevealed]) {
      return PulleyCPosition.partiallyRevealed;
    } else if ([copyString isEqualToString:Open]) {
      return PulleyCPosition.open;
    } else {
      NSLog(@"PulleyViewController: Position for string '%@' not found or string equal 'collapsed'. Available values are: collapsed, partiallyRevealed, open, and closed. Defaulting to collapsed.", copyString);
      return PulleyCPosition.collapsed;
    }
    
  } else {
    return PulleyCPosition.collapsed;
  }
}

+ (NSArray<PulleyCPosition *> *)all {
  return [NSArray<PulleyCPosition *> arrayWithObjects:
          PulleyCPosition.collapsed,
          PulleyCPosition.open,
          PulleyCPosition.closed,
          PulleyCPosition.partiallyRevealed, nil];
}

- (int)rawValue {
  return _rawValue;
}

- (BOOL)isEqual:(PulleyCPosition *)object {
  return self.rawValue == object.rawValue;
}


- (NSString *)description
{
  switch ([self rawValue]) {
    case 0:
      return @"Collapsed";
      break;
    case 1:
      return @"partiallyRevealed";
      break;
    case 2:
      return @"Open";
      break;
    case 3:
      return @"Closed";
      break;
    default:
      return @"N/A";
      break;
  }
}
@end
