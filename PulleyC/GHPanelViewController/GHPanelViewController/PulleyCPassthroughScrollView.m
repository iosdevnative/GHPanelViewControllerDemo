//
//  PulleyCPassthroughScrollView.m
//  PulleyC
//
//  Created by Artem Kedrov on 12/3/18.
//  Copyright © 2018 Artem Kedrov. All rights reserved.
//

#import "PulleyCPassthroughScrollView.h"

@implementation PulleyCPassthroughScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  if ([self touchDelegate] != nil && [[self touchDelegate] shouldTouchPassthroughScrollView:self point:point]) {
       
    return [[[self touchDelegate] viewToReceiveTouch:self point:point] hitTest:[[[self touchDelegate] viewToReceiveTouch:self point:point] convertPoint:point fromView:self] withEvent:event];

  }
  return [super hitTest:point withEvent:event];
}
@end
