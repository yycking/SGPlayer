//
//  SGVRViewport.h
//  SGPlayer
//
//  Created by Single on 2018/8/27.
//  Copyright © 2018 single. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGVRViewport : NSObject

@property (nonatomic) double degress;        // Default value is 60.
@property (nonatomic) double x;              // Default value is 0, range is (-360, 360).
@property (nonatomic) double y;              // Default value is 0, range is (-360, 360).
@property (nonatomic) BOOL flipX;            // Default value is NO.
@property (nonatomic) BOOL flipY;            // Default value is NO.
@property (nonatomic) BOOL sensorEnable;     // Default value is YES.

@end
