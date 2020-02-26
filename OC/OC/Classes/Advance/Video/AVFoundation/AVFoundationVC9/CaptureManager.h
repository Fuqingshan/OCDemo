//
//  CaptureManager.h
//  OC
//
//  Created by yier on 2020/2/25.
//  Copyright © 2020 yier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

typedef void(^DataCallBack)(CMSampleBufferRef buffer);
typedef void(^CompletionHandler)(BOOL isSuccess, NSError *error);
@interface CaptureManager : NSObject
@property(nonatomic, copy) DataCallBack videoDataCallback;///<视频数据回调
@property(nonatomic, copy) DataCallBack audioDataCallback;///<音频数据回调

- (void)setupSession:(CompletionHandler)completion;

- (void)startSession;
- (void)stopSession;

- (NSDictionary *)recommendedVideoSettingsForAssetWriter:(AVFileType)outputFileType;
- (NSDictionary *)recommendedAudioSettingsForAssetWriter:(AVFileType)outputFileType;
@end

