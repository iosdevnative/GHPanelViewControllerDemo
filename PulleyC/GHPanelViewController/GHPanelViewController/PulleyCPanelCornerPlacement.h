//
//  PulleyCPanelCornerPlacement.h
//  PulleyC
//
//  Created by Artem Kedrov on 12/3/18.
//  Copyright © 2018 Artem Kedrov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// Represents the positioning of the drawer when the `displayMode` is set to either `PulleyDisplayMode.panel` or `PulleyDisplayMode.automatic`.
///
/// - topLeft: The drawer will placed in the upper left corner
/// - topRight: The drawer will placed in the upper right corner
/// - bottomLeft: The drawer will placed in the bottom left corner
/// - bottomRight: The drawer will placed in the bottom right corner
@interface PulleyCPanelCornerPlacement : NSObject

@property (class, nonatomic, readonly) PulleyCPanelCornerPlacement *topLeft;
@property (class, nonatomic, readonly) PulleyCPanelCornerPlacement *topRight;
@property (class, nonatomic, readonly) PulleyCPanelCornerPlacement *bottomLeft;
@property (class, nonatomic, readonly) PulleyCPanelCornerPlacement *bottomRight;


@end

NS_ASSUME_NONNULL_END
