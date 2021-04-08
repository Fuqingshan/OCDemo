//
//  VideoPlayerModel.m
//  OC
//
//  Created by yier on 2021/4/8.
//  Copyright © 2021 yier. All rights reserved.
//

#import "VideoPlayerModel.h"

@implementation VideoPlayerModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"videoURL":@"videoURL",
             @"thumbnailURL"  : @"thumbnailURL",
             @"content"  : @"content"
            };
}

@end
