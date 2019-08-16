//
//  CustomAudioRecord.h
//  OC
//
//  Created by yier on 2019/8/16.
//  Copyright © 2019 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CustomAudioRecordBlock)(id model);

@interface CustomAudioRecord : NSObject
@property (nonatomic, assign) BOOL ignoreMixer;///<忽略混响录制
@property (nonatomic, assign) BOOL supportPCM;///<录制原声，格式pcm，同时忽略混响录制
@property (nonatomic, copy) CustomAudioRecordBlock successBlock;///<成功回调
@property (nonatomic, copy) CustomAudioRecordBlock failureBlock;///<失败回调

/**
 开始录制
 */
- (void)startRecordWithURL:(NSURL *)url;

/**
 结束录制
 */
- (void)stopRecord;

@end

