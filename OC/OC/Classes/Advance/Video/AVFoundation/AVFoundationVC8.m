//
//  AVFoundationVC8.m
//  AVFoundationDemo
//
//  Created by yier on 2020/2/11.
//  Copyright © 2020 yier. All rights reserved.
//

#import "AVFoundationVC8.h"
#import <AVFoundation/AVFoundation.h>

@interface AVFoundationVC8 ()<AVAudioPlayerDelegate>
@property(nonatomic, strong) AVAudioPlayer *player;
@end

@implementation AVFoundationVC8

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)initData{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)setupUI{
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AVFoundation_waiting" ofType:@"mp3"]] error:&error];
    self.player.numberOfLoops = -1;
    self.player.delegate = self;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    [self.player  prepareToPlay];
    BOOL success = [self.player  play];
    if (success) {
        NSLog(@"播放成功");
    }
}

//监听中断挂起
- (void)handleInterruption:(NSNotification *)notifacation{
    AVAudioSessionInterruptionType type = [notifacation.userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"Interruption began, take appropriate actions");
        return;
    }
    
    AVAudioSessionInterruptionOptions option = [notifacation.userInfo[AVAudioSessionInterruptionOptionKey] integerValue];
    if (option == AVAudioSessionInterruptionOptionShouldResume) {
        NSLog(@"Interruption Ended - playback should resume");
       } else {
           NSLog(@"Interruption Ended - playback should NOT resume");
        }
}

//监听路由变更
- (void)handleRouteChange:(NSNotification *)notifacation{
    AVAudioSessionRouteChangeReason reason = [notifacation.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
    
    //下面判断output的porttype时，自己的耳机打印出来是Headphones，!= AVAudioSessionPortHeadphones，有点奇怪
    if (reason == AVAudioSessionRouteChangeReasonNewDeviceAvailable) {
        // Handle new device available.
        NSArray<AVAudioSessionPortDescription *> *outputs =  [AVAudioSession sharedInstance].currentRoute.outputs;
        for (AVAudioSessionPortDescription *output in outputs) {
            if (output.portType == AVAudioSessionPortHeadphones) {
                NSLog(@"headphone connect");

                break;
            }
        }
        
    }else if(reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable){
        // Handle old device removed.
        AVAudioSessionRouteDescription *previousRoute = notifacation.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
        for (AVAudioSessionPortDescription *output in previousRoute.outputs) {
            if (output.portType == AVAudioSessionPortHeadphones) {
                NSLog(@"headphone disconnect");
                break;
            }
        }

    }
}

#pragma mark - player delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];

}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

@end
