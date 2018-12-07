//
//  PulleyCPosition.h
//  PulleyC
//
//  Created by Artem Kedrov on 12/3/18.
//  Copyright © 2018 Artem Kedrov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 Represents a Pulley drawer position.
 
 - collapsed:         When the drawer is in its smallest form, at the bottom of the screen.
 - partiallyRevealed: When the drawer is partially revealed.
 - open:              When the drawer is fully open.
 - closed:            When the drawer is off-screen at the bottom of the view. Note: Users cannot close or reopen the drawer on their own. You must set this programatically
 */
@interface PulleyCPosition : NSObject

@property (class, nonatomic, readonly) PulleyCPosition *collapsed;
@property (class, nonatomic, readonly) PulleyCPosition *partiallyRevealed;
@property (class, nonatomic, readonly) PulleyCPosition *open;
@property (class, nonatomic, readonly) PulleyCPosition *closed;
@property (class, nonatomic, readonly) NSArray<PulleyCPosition *> *all;
@property (nonatomic, assign, readonly) int rawValue;

+ (PulleyCPosition *) positionForString:(nullable NSString *) string;

@end

NS_ASSUME_NONNULL_END
