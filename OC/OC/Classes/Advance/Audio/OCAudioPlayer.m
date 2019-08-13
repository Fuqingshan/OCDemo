//
//  OCAudioPlayer.m
//  App
//
//  Created by yier on 2019/6/21.
//  Copyright © 2019 yier. All rights reserved.
//

#import "OCAudioPlayer.h"

@interface OCAudioPlayer()<AVAudioPlayerDelegate>
@property (nonatomic, strong) AVAudioPlayer * player;

@end

@implementation OCAudioPlayer

- (void)dealloc {
    self.player.delegate = nil;
    self.player = nil;
}

- (instancetype)init {
    if (self = [super init]) {
        @weakify(self);
        //电话、闹铃等
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:AVAudioSessionInterruptionNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
            @strongify(self);
            AVAudioSessionInterruptionType type = numberInDictionaryForKey(x.userInfo, AVAudioSessionInterruptionTypeKey).integerValue;
            switch (type) {
                case AVAudioSessionInterruptionTypeBegan:
                    {
                        if(self.player.isPlaying){
                            [self.player stop];
                            //不会走回调
                        }
                        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
                        self.player = nil;
                        !self.playCompleteBlock?:self.playCompleteBlock(FAAudioPlayStatusSystemInterruption);
                    }
                    break;
                case AVAudioSessionInterruptionTypeEnded:
                {
                   //拨打电话等回来就不开启了直接退出，和腾讯保持一致
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.player play];
                    });
                }
                    break;
            }
            
        }];
        
    }
    return self;
}

- (void)playRecord:(FAAudioPlayType)type{
    NSString *playPath;
    switch (type) {
        case FAAudioPlayTypePreWaiting:
            playPath = [self preWaitingPath];
            break;
        case FAAudioPlayTypeWaiting:
            playPath = [self waitingPath];
            break;
        case FAAudioPlayTypeBusy:
            playPath = [self busyPath];
            break;
        case FAAudioPlayTypeHangup:
            playPath = [self hangupPath];
            break;
    }
    
    [self playAudio:playPath type:type];
}

- (void)playAudio:(NSString *)audioPath type:(FAAudioPlayType)type{
    if(self.player.isPlaying){
        //不会走回调
        [self.player stop];
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        self.player = nil;
    }
    
    if (![audioPath isValide]) {
        NSString * log = [NSString stringWithFormat:@"AudioService --- 播放语音异常：文件路径错误"];
        LKLog(log);
        !self.playCompleteBlock?:self.playCompleteBlock(FAAudioPlayStatusError);
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:audioPath];
    if (!data) {
        NSString * log = [NSString stringWithFormat:@"AudioService --- 播放语音异常：文件数据错误"];
        LKLog(log);
        !self.playCompleteBlock?:self.playCompleteBlock(FAAudioPlayStatusError);
        return;
    }
    
    NSString * playLog = [NSString stringWithFormat:@"AudioService --- 播放路径：%@",audioPath];
    LKLog(playLog);
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    NSError * error = nil;
    self.player = [[AVAudioPlayer alloc] initWithData:data error:&error];
    self.player.delegate = self;
    self.player.numberOfLoops = type == FAAudioPlayTypeWaiting? -1: 0;
    [self.player prepareToPlay];
    BOOL playBOOL = [self.player play];
    if (!playBOOL || error) {
        NSString * log = [NSString stringWithFormat:@"AudioService --- 播放语音异常：\n%@",error];
        LKLog(log);
        !self.playCompleteBlock?:self.playCompleteBlock(FAAudioPlayStatusError);
        return;
    }
}

- (void)stopCurrentPlayer {
    if(self.player.isPlaying){
        [self.player stop];
        //不会走回调
        self.player = nil;
        !self.playCompleteBlock?:self.playCompleteBlock(FAAudioPlayStatusError);
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }
}

- (void)pause {
    [self.player pause];
}

- (void)resume {
    [self.player play];
}

- (BOOL)isPlaying {
    return self.player.isPlaying;
}

#pragma mark - player delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    !self.playCompleteBlock?:self.playCompleteBlock(FAAudioPlayStatusNormal);
    self.player = nil;
    NSString * playLog = [NSString stringWithFormat:@"AudioService --- 正常播放完成回调"];
    LKLog(playLog);
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    !self.playCompleteBlock?:self.playCompleteBlock(FAAudioPlayStatusError);
    self.player = nil;
    NSString * playLog = [NSString stringWithFormat:@"AudioService --- 播放Error回调:%@",error];
    LKLog(playLog);
}

#pragma mark lazy load
- (NSString *)preWaitingPath{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"live_preWaiting" ofType:@"mp3"];
    return path;
}

- (NSString *)waitingPath{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"live_waiting" ofType:@"mp3"];
    return path;
}

- (NSString *)busyPath{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"live_busy" ofType:@"mp3"];
    return path;
}

- (NSString *)hangupPath{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"live_hangup" ofType:@"mp3"];
    return path;
}

@end
