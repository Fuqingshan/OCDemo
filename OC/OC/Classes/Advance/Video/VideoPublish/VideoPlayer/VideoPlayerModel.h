//
//  VideoPlayerModel.h
//  OC
//
//  Created by yier on 2021/4/8.
//  Copyright © 2021 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayerModel : NSObject<YYModel>
@property(nonatomic, strong) NSURL *videoURL;
@property(nonatomic, strong) NSURL *thumbnailURL;
@property(nonatomic, copy) NSString *content;

@end

NS_ASSUME_NONNULL_END
