//
//  VideoWriteManager.h
//  OC
//
//  Created by yier on 2020/2/25.
//  Copyright © 2020 yier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

typedef void(^FinishWriteCallback)(NSURL *url);
@interface VideoWriteManager : NSObject
@property(nonatomic, copy) FinishWriteCallback finishWriteCallback;

- (instancetype)initWithVideoSettings:(NSDictionary *)videoSettings audioSettings:(NSDictionary *)audioSettings fileType:(AVFileType)fileType;

- (void)startWriting;
- (void)stopWriting;

- (void)processImageData:(CIImage *)image atTime:(CMTime)time;

- (void)processAudioData:(CMSampleBufferRef)buffer;
@end

