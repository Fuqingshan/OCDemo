//
//  OCAudioPlayer.h
//  App
//
//  Created by yier on 2019/6/21.
//  Copyright © 2019 yier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger,OCAudioPlayStatus){
    OCAudioPlayStatusNormal,///<未播放的正常状态
    OCAudioPlayStatusError,///<播放异常
    OCAudioPlayStatusSystemInterruption,///<停止播放
};

typedef NS_ENUM(NSInteger,OCAudioPlayType){
    OCAudioPlayTypePreWaiting,///<预加载
    OCAudioPlayTypeWaiting,///<等待
    OCAudioPlayTypeBusy,///<坐席忙
    OCAudioPlayTypeHangup,///<挂断
};

typedef void (^OCAudioPlayCompleteBlock)(OCAudioPlayStatus status);

@interface OCAudioPlayer : NSObject
@property (nonatomic, copy) OCAudioPlayCompleteBlock playCompleteBlock;///<语音播放回调

- (void)playAudio:(NSString *)audioPath;
- (void)playRecord:(OCAudioPlayType)type;
- (void)stopCurrentPlayer;
- (void)pause;
- (void)resume;
- (BOOL)isPlaying;

@end
