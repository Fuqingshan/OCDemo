//
//  OCVideoPlayer.m
//  AA
//
//  Created by yier on 2021/4/9.
//

#import "OCVideoPlayer.h"
#import <AVKit/AVKit.h>
#import <SDWebImage/SDWebImage.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface OCVideoPlayer ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *currentItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) id timeObserve;

//---------readwrite--------
@property (nonatomic, assign) OCVideoPlayerState state;
@property (nonatomic, assign) CGFloat fps;
@property (nonatomic, assign) CGFloat cacheOffset;
@property (nonatomic, assign) CGFloat playOffset;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat cacheProgress;
@property (nonatomic, assign) CGFloat playProgress;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIView *inView;
//--------------------------
@property (nonatomic, assign) CGFloat cacheProgForLog;///< 打印日志
@property (nonatomic, assign) CGFloat playProgForLog;///< 打印日志

@end

@implementation OCVideoPlayer

- (void)dealloc {
    [self destroy];
}

- (instancetype)init{
    return [self initWithURL:nil];
}

#pragma mark - prepare
- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.cacheProgress = 0.0;
    self.playProgress = 0.0;
    self.duration = 0.0;
    self.cacheOffset = 0.0;
    self.playOffset = 0.0;
    
    self.url = url;
    [self reloadCurrentItem];
    
    return self;
}

- (void)changeCurrentPlayerItemWithURL:(NSURL *)url {
    self.url = url;
    [self reloadCurrentItem];
}

- (void)reloadCurrentItem {
    if (self.currentItem) {
        [self reset];
        self.state = OCVideoPlayerStateEndStopped;
    }
    
    //AVPlayerItem
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.url options:nil];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    self.currentItem = item;
    
    //AVPlayer
    if (self.player) {
        [self.player replaceCurrentItemWithPlayerItem:self.currentItem];
    } else {
        self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
        if ([self.player respondsToSelector:@selector(automaticallyWaitsToMinimizeStalling)]) {
            self.player.automaticallyWaitsToMinimizeStalling = NO;
        }
    }
        
    //Observer
    [self addObserver];

    //State
    self.state = OCVideoPlayerStateWaiting;
}

- (void)preparePlayInView:(UIView *)view videoGravity:(AVLayerVideoGravity)videoGravity {
    if (self.playerLayer) {
        self.playerLayer.player = self.player;
        [self.playerLayer removeFromSuperlayer];
        [view.layer addSublayer:self.playerLayer];
    }else{
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [view.layer addSublayer:playerLayer];
        self.playerLayer = playerLayer;
    }
    
    if (videoGravity) {
        self.playerLayer.videoGravity = videoGravity;
    }
    
    self.playerLayer.frame = view.bounds;
    self.inView = view;
}

#pragma mark - video control
- (void)play {
    if ([self isErrorByNetwork:self.state]) {
        self.state = OCVideoPlayerStateBuffering;
    }
    
    BOOL selfStateAllow = (self.state == OCVideoPlayerStatePaused || self.state == OCVideoPlayerStateReadyToPlay);
    if (selfStateAllow) {
        [self.player play];
    }
}

- (void)pause {
    if (self.state == OCVideoPlayerStatePlaying) {
        [self.player pause];
        self.state = OCVideoPlayerStatePaused;
    }
}

/*
 结束播放 + 置空AVPlayer，销毁之后就不准备用了
 */
- (void)destroy {
    [self reset];
    self.playerLayer = nil;
    self.inView = nil;
    self.currentItem = nil;
    self.player = nil;
    self.url = nil;
}

- (void)seekTimeTo:(CGFloat)playProgress {
    [self innerSeekTimeTo:playProgress];
}

#pragma mark real operation
/**
 重置播放器
 */
- (void)reset{
    [self.player pause];
    self.cacheProgress = 0.0;
    self.playProgress = 0.0;
    self.duration = 0.0;
    self.cacheOffset = 0.0;
    self.playOffset = 0.0;
    
    if (self.timeObserve) {
        [self.player removeTimeObserver:self.timeObserve];
        self.timeObserve = nil;
    }
    [self.player replaceCurrentItemWithPlayerItem:nil];
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    self.state = OCVideoPlayerStateEndStopped;
}

- (void)innerSeekTimeTo:(CGFloat)progress {
    NSLog(@"OCPlayer --- willSeekTimeTo=%.2f",progress);
    [self pause];
    //修改状态，避免seek之后为其他状态，play检查state时被拦截
    if (self.state != OCVideoPlayerStatePaused) {
        self.state = OCVideoPlayerStatePaused;
    }
    CMTime startTime = CMTimeMakeWithSeconds(self.duration * progress, 1.0);
    @weakify(self);
    [self.player seekToTime:startTime completionHandler:^(BOOL finished) {
        @strongify(self);
        if (finished) {
            [self play];
            self.playOffset = progress * self.duration;
            self.playProgress = progress;
        }
    }];
}

/// 优先返回当前进度
/// @param dest 当前
/// @param orig 上一次的
- (CGFloat)checkDest:(CGFloat)dest greaterThanOrig:(CGFloat)orig {
    if (dest > orig) {
        return dest;
    }
    return orig;
}

#pragma mark - state
- (BOOL)isPlaying {
    if (self.state == OCVideoPlayerStatePlaying) {
        return YES;
    }
    return NO;
}

- (CGFloat)fps {
    BOOL available = self.state == OCVideoPlayerStatePlaying || self.state == OCVideoPlayerStatePaused || self.state == OCVideoPlayerStateBuffering;
    return (self.currentItem && available) ? [[[self.currentItem.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] nominalFrameRate] : 0.f;
}

- (void)setState:(OCVideoPlayerState)state {
    _state = state;
    NSLog(@"OCPlayer --- 设置状态state=%@",[OCVideoPlayer innerSelfStateStringFromState:state]);
}

- (void)setCacheOffset:(CGFloat)cacheOffset {
    _cacheOffset = cacheOffset;
    [self calculateCacheProgress];
}

- (void)setPlayOffset:(CGFloat)playOffset {
    _playOffset = playOffset;
    [self calculatePlayProgress];
}

- (void)setDuration:(CGFloat)duration {
    _duration = duration;
    [self calculatePlayProgress];
    [self calculateCacheProgress];
}

- (void)calculatePlayProgress {
    CGFloat pProgress = (_duration <= 0) ? 0 : (_playOffset / _duration);
    if (pProgress > self.playProgress) {
        self.playProgress = pProgress;
    }
}

- (void)calculateCacheProgress {
    CGFloat cProgress = (_duration <= 0) ? 0 : (_cacheOffset / _duration);
    if (cProgress > self.cacheProgress) {
        self.cacheProgress = cProgress;
    }
}

- (void)setCacheProgress:(CGFloat)cacheProgress {
    _cacheProgress = cacheProgress;
    if (cacheProgress > self.cacheProgForLog + 0.2) {
        self.cacheProgForLog = cacheProgress;
        NSLog(@"OCPlayer --- cacheProgress=%.2f",cacheProgress);
    }
}

- (void)setPlayProgress:(CGFloat)playProgress {
    _playProgress = playProgress;
    if (playProgress > self.playProgForLog + 0.2) {
        self.playProgForLog = playProgress;
        NSLog(@"OCPlayer ---  playProgress=%.2f",playProgress);
    }
}

/**
 由于网络原因导致的异常，可重试
 */
- (BOOL)isErrorByNetwork:(OCVideoPlayerState)state {
    switch (state) {
        case OCVideoPlayerStateEndFailed:
        case OCVideoPlayerStateEndErrorUnknown:
            return YES;
            break;
        default:
            break;
    }
    return NO;
}

#pragma mark - KVO
- (void)addObserver {
    //播放进度
    @weakify(self);
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_global_queue(0, 0) usingBlock:^(CMTime time) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            CGFloat current = CMTimeGetSeconds(time);
            self.playOffset = [self checkDest:current greaterThanOrig:self.playOffset];
            CGFloat getDuration = CMTimeGetSeconds(self.currentItem.duration);
            self.duration = [self checkDest:getDuration greaterThanOrig:self.duration];
        });
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil]
      takeUntil:[self cleanPlayItemSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        if (self.autoReplay) {
            self.playOffset = 0;
            self.playProgress = 0;
            self.playProgForLog = 0;
            [self innerSeekTimeTo:0];
        } else {
//            [self.player pause];
            self.state = OCVideoPlayerStateEndStopped;
        }
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:AVPlayerItemFailedToPlayToEndTimeNotification object:nil]
      takeUntil:[self cleanPlayItemSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        [self pause];
        self.state = OCVideoPlayerStateEndFailed;
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:AVPlayerItemNewErrorLogEntryNotification object:nil]
      takeUntil:[self cleanPlayItemSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        [self pause];
        self.state = OCVideoPlayerStateEndErrorUnknown;
    }];
    
    [[[RACObserve(self.player, rate)
       takeUntil:[self cleanPlayItemSignal]] distinctUntilChanged]
     subscribeNext:^(NSNumber  *rateNumber) {
        @strongify(self);
        CGFloat rate = rateNumber.floatValue;
        NSLog(@"OCPlayer --- 播放速率rate = %.2f",rate);
        if (rate == 0.0) {
            self.state = OCVideoPlayerStateBuffering;
        } else {
            self.state = OCVideoPlayerStatePlaying;
        }
    }];
    
    [[[RACObserve(self.currentItem, loadedTimeRanges)
       takeUntil:[self cleanPlayItemSignal]] distinctUntilChanged]
     subscribeNext:^(NSArray<NSValue *> *loadedTimeRanges) {
        @strongify(self);
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];//本次缓冲的时间范围
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        if (totalBuffer > self.cacheOffset && self.duration > 0) {
            NSLog(@"OCPlayer --- 缓冲总长度%.2f self.duration=%.2f",totalBuffer,self.duration);
        }
        self.cacheOffset = [self checkDest:totalBuffer greaterThanOrig:self.cacheOffset];
    }];
    
    [[[RACObserve(self.currentItem, status)
       takeUntil:[self cleanPlayItemSignal]] distinctUntilChanged]
     subscribeNext:^(NSNumber *statusNumber) {
        @strongify(self);
        NSLog(@"OCPlayer --- 状态改变status=%@",[OCVideoPlayer playerStatusStringFromStatus:self.currentItem.status]);
        AVPlayerItemStatus status = [statusNumber intValue];
        switch (status) {
            case AVPlayerItemStatusFailed:
                [self pause];
                self.state = OCVideoPlayerStateEndFailed;
                break;
            case AVPlayerItemStatusReadyToPlay: {
                //self.state = OCVideoPlayerStateBuffering;
                //[self play];
            }
                break;
            case AVPlayerItemStatusUnknown:
                [self pause];
                self.state = OCVideoPlayerStateEndErrorUnknown;
                break;
            default:
                break;
        }
    }];
    
    [[[RACObserve(self.currentItem, playbackBufferEmpty)
       takeUntil:[self cleanPlayItemSignal]] distinctUntilChanged]
     subscribeNext:^(NSNumber *playbackBufferEmptyNumber) {
        @strongify(self);
        NSLog(@"OCPlayer --- 播放器已经耗尽资源，即将停止或结束Empty=%@",playbackBufferEmptyNumber);
        
        BOOL playbackBufferEmpty = playbackBufferEmptyNumber.boolValue;
        if (playbackBufferEmpty) {
            self.state = OCVideoPlayerStateBuffering;
        }
    }];
    
    [[[RACObserve(self.currentItem, playbackBufferFull)
       takeUntil:[self cleanPlayItemSignal]] distinctUntilChanged]
     subscribeNext:^(NSNumber *playbackBufferFullNumber) {
        @strongify(self);
        NSLog(@"OCPlayer --- 缓冲区状态BufferFull=%@",playbackBufferFullNumber);
        
        BOOL playbackBufferFull = playbackBufferFullNumber.boolValue;
        BOOL available = self.state == OCVideoPlayerStateWaiting || self.state == OCVideoPlayerStateBuffering;
        if (playbackBufferFull && available) {
            self.state = OCVideoPlayerStateReadyToPlay;
        }
    }];
    
    [[[RACObserve(self.currentItem, playbackLikelyToKeepUp)
       takeUntil:[self cleanPlayItemSignal]] distinctUntilChanged]
     subscribeNext:^(NSNumber *playbackLikelyToKeepUpNumber) {
        @strongify(self);
        NSLog(@"OCPlayer --- 缓冲足够可以播了KeepUp=%@",playbackLikelyToKeepUpNumber);
        
        BOOL playbackLikelyToKeepUp = playbackLikelyToKeepUpNumber.boolValue;
        BOOL available = self.state == OCVideoPlayerStateWaiting || self.state == OCVideoPlayerStateBuffering;
        // 缓冲够了再播放
        if (playbackLikelyToKeepUp) {
            //当前是缓冲状态，那么直接改为准备播放，如果是暂停状态，那么直接播放就好了
            if (available) {
                self.state = OCVideoPlayerStateReadyToPlay;
            }
            [self play];
        }
    }];
}

- (RACSignal *)cleanPlayItemSignal{
    return  [self.currentItem.rac_willDeallocSignal merge:[self rac_signalForSelector:@selector(reset)]];
}

#pragma mark - extension
+ (NSString *)playerStatusStringFromStatus:(AVPlayerItemStatus)status {
    switch (status) {
        case AVPlayerItemStatusUnknown:
            return @"AVPlayerItemStatusUnknown";
            break;
        case AVPlayerItemStatusReadyToPlay:
            return @"AVPlayerItemStatusReadyToPlay";
            break;
        case AVPlayerItemStatusFailed:
            return @"AVPlayerItemStatusFailed";
            break;
        default:
            break;
    }
}

+ (NSString *)innerSelfStateStringFromState:(OCVideoPlayerState)state {
    switch (state) {
        case OCVideoPlayerStateWaiting:
            return @"OCVideoPlayerStateWaiting";
            break;
        case OCVideoPlayerStateReadyToPlay:
            return @"OCVideoPlayerStateReadyToPlay";
            break;
        case OCVideoPlayerStatePlaying:
            return @"OCVideoPlayerStatePlaying";
            break;
        case OCVideoPlayerStatePaused:
            return @"OCVideoPlayerStatePaused";
            break;
        case OCVideoPlayerStateBuffering:
            return @"OCVideoPlayerStateBuffering";
            break;
        case OCVideoPlayerStateEndFailed:
            return @"OCVideoPlayerStateEndFailed";
            break;
        case OCVideoPlayerStateEndErrorUnknown:
            return @"OCVideoPlayerStateEndErrorUnknown";
            break;
        case OCVideoPlayerStateEndStopped:
            return @"OCVideoPlayerStateEndStopped";
            break;
        default:
            break;
    }
}

@end
