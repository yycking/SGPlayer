//
//  SGPaddingSegment.h
//  SGPlayer
//
//  Created by Single on 2019/9/19.
//  Copyright © 2019 single. All rights reserved.
//

#import "SGSegment.h"

NS_ASSUME_NONNULL_BEGIN

@interface SGPaddingSegment : SGSegment

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 *
 */
- (instancetype)initWithDuration:(CMTime)duration;

/**
 *
 */
@property (NS_NONATOMIC_IOSONLY, readonly) CMTime duration;

@end

NS_ASSUME_NONNULL_END
