//
//  PulleyCDisplayMode.h
//  PulleyC
//
//  Created by Artem Kedrov on 12/3/18.
//  Copyright © 2018 Artem Kedrov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// Represents the current display mode for Pulley
///
/// - panel: Show as a floating panel (replaces: leftSide)
/// - drawer: Show as a bottom drawer (replaces: bottomDrawer)
/// - automatic: Determine it based on device / orientation / size class (like Maps.app)
@interface PulleyCDisplayMode : NSObject

@property (class, nonatomic, readonly) PulleyCDisplayMode * panel;
@property (class, nonatomic, readonly) PulleyCDisplayMode * drawer;
@property (class, nonatomic, readonly) PulleyCDisplayMode * automatic;


@end

NS_ASSUME_NONNULL_END
