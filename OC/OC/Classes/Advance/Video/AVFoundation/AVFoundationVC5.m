//
//  AVFoundationVC5.m
//  AVFoundationDemo
//
//  Created by yier on 2020/2/9.
//  Copyright © 2020 yier. All rights reserved.
//

#import "AVFoundationVC5.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <Masonry/Masonry.h>

static void *kContext = &kContext;
@interface AVFoundationVC5 ()
@property(nonatomic, strong) AVPlayerViewController *playerVC;
@property(nonatomic, strong) AVAsset *asset;
@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) AVPlayerItem *playerItem;

@property(nonatomic, strong) id timeObserverToken;
@property(nonatomic, strong) id timeBoundaryObserverToken;
@property(nonatomic, strong) UIButton *seekButton1;
@property(nonatomic, strong) UIButton *seekButton2;

@end

@implementation AVFoundationVC5

- (void)dealloc{
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self addPeriodicObserver];
    [self addTimeBoundaryObserver];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
//    [self removePeriodicObserver];
    [self removeTimeBoundaryObserver];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)initData{
//    NSString *url = @"https://free-hls.boxueio.com/z62-asynchronous-values-in-combine.m3u8";
//    self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
//    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    if (!self.defaultAsset) {
        NSString *url = @"https://free-hls.boxueio.com/z62-asynchronous-values-in-combine.m3u8";
        self.asset = [AVAsset assetWithURL:[NSURL URLWithString:url]];
    }else{
        self.asset = self.defaultAsset;
    }
    
     self.playerItem = [[AVPlayerItem alloc] initWithAsset:self.asset automaticallyLoadedAssetKeys:@[@"playable",@"hasProtectedContent"]];
     self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:kContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (context != kContext) {
        return;
    }
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
                //准备播放
                break;
            case AVPlayerItemStatusFailed:
            //异常
            break;
            default:
                //unknown
                break;
        }
        
        NSLog(@"status:%@",change[NSKeyValueChangeNewKey]);
    }
}

- (void)setupUI{
    self.playerVC = [[AVPlayerViewController alloc] init];
    self.playerVC.view.frame = self.view.frame;
    [self.view addSubview:self.playerVC.view];
    [self addChildViewController:self.playerVC];
    [self.playerVC didMoveToParentViewController:self];

    [self.playerVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    self.playerVC.player = self.player;
    
    self.seekButton1 = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 200, 30)];
    self.seekButton1.backgroundColor = [UIColor blackColor];
    [self.seekButton1 setTitle:@"seek" forState:UIControlStateNormal];
    [self.seekButton1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.seekButton1 addTarget:self action:@selector(seek) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.seekButton1];
    
    self.seekButton2 = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 200, 30)];
    self.seekButton2.backgroundColor = [UIColor blackColor];
    [self.seekButton2 setTitle:@"seek by tolerance" forState:UIControlStateNormal];
    [self.seekButton2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.seekButton2 addTarget:self action:@selector(seekByTolerance) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.seekButton2];
}

- (void)testCTTime{
    // 0.25 seconds
    CMTime quarterSecond = CMTimeMake(1, 4);

    // 10 second mark in a 44.1 kHz audio file
    CMTime tenSeconds = CMTimeMake(441000,44100);
     
    // 3 seconds into a 30fps video
    CMTime cursor = CMTimeMake(90, 30);
}

#pragma mark - 定期观察
- (void)addPeriodicObserver{
    //0.5s
    CMTime time= CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:time queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //update UI
        NSLog(@"addPeriodicTimeObserverForInterval update UI");
    }];
}

- (void)removePeriodicObserver{
    if (!self.timeObserverToken) {
        return;
    }
    [self.player removeTimeObserver:self.timeObserverToken];
    self.timeObserverToken = nil;
}

#pragma mark - 边界观察
//如果您正在呈现无播放控件的视频，则可能会使用边界观察，并希望同时显示或显示补充内容的元素同步时间
//测试发现只有经过这么多时间才会触发，快进的不会
- (void)addTimeBoundaryObserver{
    CMTime interval = CMTimeMultiplyByFloat64(self.asset.duration, 0.25);
    CMTime currentTime = kCMTimeZero;
    NSMutableArray *times = @[].mutableCopy;
    while (CMTimeCompare(currentTime, self.asset.duration) == -1 ) {
        currentTime = CMTimeAdd(currentTime, interval);
        [times addObject:[NSValue valueWithCMTime:currentTime]];
    }
    self.timeBoundaryObserverToken = [self.player addBoundaryTimeObserverForTimes:times queue:dispatch_get_main_queue() usingBlock:^{
        //update UI
        NSLog(@"addBoundaryTimeObserverForTimes update UI");
    }];
}

- (void)removeTimeBoundaryObserver{
    if (!self.timeBoundaryObserverToken) {
        return;
    }
    
    [self.player removeTimeObserver:self.timeBoundaryObserverToken];
    self.timeBoundaryObserverToken = nil;
}

#pragma mark - 设置跳转时间
- (void)seek{
    //跳转2分钟，不保证精度
    [self.player seekToTime:CMTimeMake(120, 1)];
    NSLog(@"跳转到2分钟");
}

- (void)seekByTolerance{
    //跳转3分25秒
    CMTime seekTime = CMTimeMakeWithSeconds(205, NSEC_PER_SEC);
    //设置容差，KCMTimeZero或较小时会使得解码产生额外延迟
    [self.player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"精确跳转3:25成功");
        }
    }];
}

@end
