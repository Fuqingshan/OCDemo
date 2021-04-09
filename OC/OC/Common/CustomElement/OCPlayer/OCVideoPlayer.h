//
//  OCVideoPlayer.m
//  AA
//
//  Created by yier on 2021/4/9.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, OCVideoPlayerState) {
    OCVideoPlayerStateWaiting = 0,
    OCVideoPlayerStateReadyToPlay,
    OCVideoPlayerStatePlaying,
    OCVideoPlayerStatePaused,
    OCVideoPlayerStateBuffering,
    OCVideoPlayerStateEndStopped,
    OCVideoPlayerStateEndFailed,
    OCVideoPlayerStateEndErrorUnknown,
};

@interface OCVideoPlayer : NSObject

//设置是否重复播放，默认为NO
@property (nonatomic, assign) BOOL autoReplay;

@property (nonatomic, assign, readonly) OCVideoPlayerState state;
@property (nonatomic, assign, readonly) CGFloat fps;
@property (nonatomic, assign, readonly) CGFloat duration;

//当前播放时间，单位：秒
@property (nonatomic, assign, readonly) CGFloat playOffset;

@property (nonatomic, assign, readonly) CGFloat cacheProgress;
@property (nonatomic, assign, readonly) CGFloat playProgress;

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) UIView *inView;

#pragma mark - init
- (instancetype)initWithURL:(NSURL *)url;
- (void)changeCurrentPlayerItemWithURL:(NSURL *)url;
- (void)preparePlayInView:(UIView *)view videoGravity:(AVLayerVideoGravity)videoGravity;

#pragma mark - control
- (void)play;
- (void)pause;///< 暂停播放器
- (void)reset;///< 重置播放器
- (void)destroy;///< 销毁播放器
- (void)seekTimeTo:(CGFloat)playProgress;

#pragma mark - play state
- (BOOL)isPlaying;
@end
