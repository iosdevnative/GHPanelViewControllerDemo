//
//  CustomMaskExample.m
//  PulleyC
//
//  Created by user1 on 12/3/18.
//

#import "CustomMaskExample.h"


@implementation CustomMaskExample

+ (CGFloat)cornerRadius {
  return 8.0;
}
+ (CGFloat)cutoutDistanceFromEdge {
  return 32.0;
}
+ (CGFloat)cutoutRadius {
  return 8.0;
}
- (UIBezierPath *)customMaskForBounds:(CGRect)bounds {
  CGFloat maxX = CGRectGetMaxX(bounds);
  CGFloat maxY = CGRectGetMaxY(bounds);
  UIBezierPath *path = [UIBezierPath bezierPath];
  [path moveToPoint:CGPointMake(0, maxY)];
  [path addLineToPoint:CGPointMake(0, CustomMaskExample.cornerRadius)];
  
  [path addArcWithCenter:CGPointMake(CustomMaskExample.cutoutDistanceFromEdge - CustomMaskExample.cutoutRadius, 0)
                  radius:CustomMaskExample.cutoutRadius
              startAngle: M_PI
                endAngle:1.5 * M_PI
               clockwise:true];
  
  [path addLineToPoint:CGPointMake(CustomMaskExample.cutoutDistanceFromEdge + CustomMaskExample.cutoutRadius, 0)];
  [path addArcWithCenter:CGPointMake(CustomMaskExample.cutoutDistanceFromEdge, 0)
                  radius:CustomMaskExample.cutoutRadius
              startAngle:M_PI
                endAngle:2.0 * M_PI
               clockwise: false];
  [path addLineToPoint:CGPointMake(CustomMaskExample.cutoutDistanceFromEdge + CustomMaskExample.cutoutRadius, 0)];
  
  [path addLineToPoint:CGPointMake(maxX - CustomMaskExample.cutoutDistanceFromEdge - CustomMaskExample.cutoutRadius, 0)];
  [path addArcWithCenter:CGPointMake(maxX - CustomMaskExample.cutoutDistanceFromEdge, 0)
                  radius:CustomMaskExample.cutoutRadius
              startAngle:M_PI
                endAngle:2.0 * M_PI
               clockwise:false];
  [path addLineToPoint: CGPointMake(maxX - CustomMaskExample.cornerRadius, CustomMaskExample.cornerRadius)];
  [path addLineToPoint: CGPointMake(maxX - CustomMaskExample.cornerRadius, CustomMaskExample.cornerRadius)];
  
  [path addArcWithCenter:CGPointMake(maxX - CustomMaskExample.cornerRadius, CustomMaskExample.cornerRadius)
                  radius:CustomMaskExample.cornerRadius
              startAngle:1.5 * M_PI
                endAngle:2.0 * M_PI
               clockwise: true];
  [path addLineToPoint:CGPointMake(maxX, maxY)];
  [path addLineToPoint:CGPointMake(0, maxY)];
  [path closePath];
  [path fill];
  
  return path;
  
}


@end
