//
//  OCAudioPlayer.h
//  App
//
//  Created by yier on 2019/6/21.
//  Copyright © 2019 yier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger,FAAudioPlayStatus){
    FAAudioPlayStatusNormal,///<未播放的正常状态
    FAAudioPlayStatusError,///<播放异常
    FAAudioPlayStatusSystemInterruption,///<停止播放
};

typedef NS_ENUM(NSInteger,FAAudioPlayType){
    FAAudioPlayTypePreWaiting,///<预加载
    FAAudioPlayTypeWaiting,///<等待
    FAAudioPlayTypeBusy,///<坐席忙
    FAAudioPlayTypeHangup,///<挂断
};

typedef void (^FAAudioPlayCompleteBlock)(FAAudioPlayStatus status);

@interface OCAudioPlayer : NSObject
@property (nonatomic, copy) FAAudioPlayCompleteBlock playCompleteBlock;///<语音播放回调

- (void)playAudio:(NSString *)audioPath;
- (void)playRecord:(FAAudioPlayType)type;
- (void)stopCurrentPlayer;
- (void)pause;
- (void)resume;
- (BOOL)isPlaying;

@end
