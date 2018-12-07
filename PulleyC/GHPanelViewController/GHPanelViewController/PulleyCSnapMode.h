//
//  PulleyCSnapMode.h
//  PulleyC
//
//  Created by Artem Kedrov on 12/3/18.
//  Copyright © 2018 Artem Kedrov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// Represents the 'snap' mode for Pulley. The default is 'nearest position'. You can use 'nearestPositionUnlessExceeded' to make the drawer feel lighter or heavier.
///
/// - nearestPosition: Snap to the nearest position when scroll stops
/// - nearestPositionUnlessExceeded: Snap to the nearest position when scroll stops, unless the distance is greater than 'threshold', in which case advance to the next drawer position.
@interface PulleyCSnapMode : NSObject
+ (PulleyCSnapMode *) nearestPosition;
+ (PulleyCSnapMode *) nearestPositionUnlessExceeded:(CGFloat) value;
- (CGFloat) rawValue;
@end

NS_ASSUME_NONNULL_END
