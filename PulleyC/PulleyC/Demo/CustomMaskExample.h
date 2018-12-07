//
//  CustomMaskExample.h
//  PulleyC
//
//  Created by user1 on 12/3/18.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CustomMaskExample : NSObject
@property (class, nonatomic, readonly) CGFloat cornerRadius;
@property (class, nonatomic, readonly) CGFloat cutoutDistanceFromEdge;
@property (class, nonatomic, readonly) CGFloat cutoutRadius;

- (UIBezierPath *) customMaskForBounds: (CGRect) bounds;

@end

NS_ASSUME_NONNULL_END

