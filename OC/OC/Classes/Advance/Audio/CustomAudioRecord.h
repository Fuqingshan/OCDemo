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
@property (nonatomic, copy) CustomAudioRecordBlock successBlock;///<成功回调
@property (nonatomic, copy) CustomAudioRecordBlock failureBlock;///<失败回调
@property (nonatomic, assign) CGFloat recordTime;///<录制时长，精度0.1

/**
 设置忽略混响录制

 @param ignoreMixer 默认NO
 */
- (instancetype)initIfIgnoreMixer:(BOOL)ignoreMixer;

/**
 设置录制原生，格式pcm，同时忽略混响录制

 @param supportPCM 默认NO
 */
- (instancetype)initIfSupportPCM:(BOOL)supportPCM;
- (instancetype)initIfIgnoreMixer:(BOOL)ignoreMixer supportPCM:(BOOL)supportPCM;

/**
 开始录制
 */
- (void)startRecordWithURL:(NSURL *)url;

/**
 结束录制
 */
- (void)stopRecord;

@end

