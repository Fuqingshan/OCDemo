//
//  AVFoundationVC19.m
//  AVFoundationDemo
//
//  Created by yier on 2020/2/17.
//  Copyright © 2020 yier. All rights reserved.
//

#import "AVFoundationVC19.h"
#import <AVFoundation/AVFoundation.h>
#import "DisplayLinkDelloc.h"

static NSInteger secsPerMin = 60;
static NSInteger secsPerHour = 60 * 60;


@interface AVFoundationVC19 ()

//UI
@property(nonatomic, strong) UIButton *pauseButton;
@property(nonatomic, strong) UIButton *forwardButton;
@property(nonatomic, strong) UIButton *backButton;
@property(nonatomic, strong) UILabel *leftLabel;
@property(nonatomic, strong) UIProgressView *progress;
@property(nonatomic, strong) UISlider *rateSlider;
@property(nonatomic, strong) UILabel *rightLabel;
@property(nonatomic, strong) UILabel *rateLabel;

//Audio
@property(nonatomic, strong) AVAudioEngine *engine;
@property(nonatomic, strong) AVAudioPlayerNode *player;
@property(nonatomic, strong) AVAudioUnitTimePitch *rateEffect;
@property(nonatomic, strong) AVAudioFile *audioFile;
@property(nonatomic, strong) NSURL *audioFileURL;
@property(nonatomic, strong) AVAudioPCMBuffer *audioBuffer;
@property(nonatomic, strong) AVAudioFormat *audioFormat;

//Data
@property(nonatomic, assign) CGFloat audioSampleRate;
@property(nonatomic, assign) CGFloat audioLengthSeconds;
@property(nonatomic, assign) AVAudioFramePosition audioLengthSamples;
@property(nonatomic, assign) BOOL needsFileScheduled;
@property(nonatomic, strong) NSArray *rateSliderValues;
@property(nonatomic, assign) CGFloat rateValue;

//display
@property(nonatomic, strong) CADisplayLink *updater;
@property(nonatomic, assign) AVAudioFramePosition currentFrame;
@property(nonatomic, assign) AVAudioFramePosition seekFrame;
@property(nonatomic, assign) AVAudioFramePosition currentPosition;
@end

@implementation AVFoundationVC19

- (void)dealloc{
    [self.updater invalidate];
    [self.player stop];
     self.updater.paused = YES;
     self.pauseButton.selected = NO;
     [self disconnectVolumeTap];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)initData{
    //初始化参数
   self.needsFileScheduled = YES;
   self.rateSliderValues = @[@(0.5),@(1),@(1.25),@(1.5),@(1.75),@(2.0),@(2.5),@(3.0)];
   self.rateValue = 1.0;
   
   self.seekFrame = 0;
    
    [self createAudioField];
    [self createDisplayLink];
}

- (void)createAudioField{
    self.audioFileURL = [[NSBundle mainBundle] URLForResource:@"AVFoundation_waiting" withExtension:@"mp3"];
    self.audioFile = [[AVAudioFile alloc] initForReading:self.audioFileURL error:nil];

    self.player = [[AVAudioPlayerNode alloc] init];
    self.engine = [[AVAudioEngine alloc] init];
    self.rateEffect = [[AVAudioUnitTimePitch alloc] init];
    self.rateEffect.rate = self.rateValue;//设置速率
    
    self.audioLengthSamples = self.audioFile.length;
    self.audioFormat = self.audioFile.processingFormat;
    self.audioSampleRate = (self.audioFormat.sampleRate > 0) ? self.audioFormat.sampleRate : 44100;
    self.audioLengthSeconds = self.audioLengthSamples / self.audioSampleRate;
    
    [self.engine attachNode:self.player];
    [self.engine attachNode:self.rateEffect];
    [self.engine connect:self.player to:self.rateEffect format:self.audioFormat];
    [self.engine connect:self.rateEffect to:self.engine.mainMixerNode format:self.audioFormat];
    
    [self.engine prepare];
    
    NSError *error;
    BOOL success =[self.engine startAndReturnError:&error];
    if (!success) {
        NSLog(@"播放失败：%@",error);
    }
}

-(void)createDisplayLink{    
    DisplayLinkDelloc *displaylinkDealloc = [DisplayLinkDelloc weakProxyForObject:self];
    self.updater = [CADisplayLink displayLinkWithTarget:displaylinkDealloc selector:@selector(updateUI)];
    [self.updater addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.updater.paused = YES;
    
}

- (void)updateUI{
    self.currentPosition = self.currentFrame + self.seekFrame;
    self.currentPosition = MAX(self.currentPosition, 0);
    self.currentPosition = MIN(self.currentPosition, self.audioLengthSamples);
    
    self.progress.progress = self.currentPosition / self.audioLengthSamples;
    CGFloat time = self.currentPosition / self.audioSampleRate;
    self.leftLabel.text = [self formatTime:time];
    self.rightLabel.text = [self formatTime:self.audioLengthSeconds - time];
    
    if (self.currentPosition >= self.audioLengthSamples) {
        [self.player stop];
        self.updater.paused = YES;
        self.pauseButton.selected = NO;
        [self disconnectVolumeTap];
    }
}

- (void)setupUI{
    
    self.pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 200, 30)];
    self.pauseButton.backgroundColor = [UIColor blackColor];
    [self.pauseButton setTitle:@"播放" forState:UIControlStateNormal];
    [self.pauseButton setTitle:@"暂停" forState:UIControlStateSelected];
    [self.pauseButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.pauseButton setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
    [self.pauseButton addTarget:self action:@selector(pauseEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pauseButton];

    self.forwardButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 200, 30)];
    self.forwardButton.backgroundColor = [UIColor blackColor];
    [self.forwardButton setTitle:@"前进10s" forState:UIControlStateNormal];
    [self.forwardButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.forwardButton addTarget:self action:@selector(forwardEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.forwardButton];

    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 400, 200, 30)];
    self.backButton.backgroundColor = [UIColor blackColor];
    [self.backButton setTitle:@"后退10s" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
        
    self.leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 500, 50, 30)];
    self.leftLabel.text = [self formatTime:0];
    self.leftLabel.textColor = [UIColor orangeColor];
    self.leftLabel.font = [UIFont systemFontOfSize:12.0];
    [self.view addSubview:self.leftLabel];
    
    self.progress = [[UIProgressView alloc] initWithFrame:CGRectMake(50, 500, 300, 2)];
    self.progress.progress = 0.0;
    self.progress.progressTintColor = [UIColor whiteColor];
    self.progress.backgroundColor = [UIColor blackColor];
    self.progress.trackTintColor = [UIColor orangeColor];
    [self.view addSubview:self.progress];
    
    self.rateSlider = [[UISlider alloc] initWithFrame:CGRectMake(50, 600, 300, 2)];
    self.rateSlider.minimumTrackTintColor = [UIColor greenColor];
    self.rateSlider.maximumTrackTintColor = [UIColor redColor];
    self.rateSlider.thumbTintColor = [UIColor orangeColor];
    self.rateSlider.value = 1.0;
    self.rateSlider.minimumValue = 0;
    self.rateSlider.continuous = YES;
    self.rateSlider.maximumValue = self.rateSliderValues.count - 1;
    [self.rateSlider addTarget:self action:@selector(changeRate) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.rateSlider];
    
    self.rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(370, 500, 50, 30)];
    self.rightLabel.text = [self formatTime:self.audioLengthSeconds];
    self.rightLabel.textColor = [UIColor orangeColor];
    self.rightLabel.font = [UIFont systemFontOfSize:12.0];
    [self.view addSubview:self.rightLabel];
    
    self.rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 700, 200, 30)];
   self.rateLabel.text = [NSString stringWithFormat:@"当前速率：%f",self.rateValue];
   self.rateLabel.textColor = [UIColor orangeColor];
   self.rateLabel.font = [UIFont systemFontOfSize:12.0];
   [self.view addSubview:self.rateLabel];
}

- (NSString *)formatTime:(CGFloat)time{
    NSInteger secs = ceil(time);
    NSInteger hours = 0;
    NSInteger mins = 0;

      if (secs > secsPerHour) {
          hours = secs / secsPerHour;
          secs -= hours * secsPerHour;
      }

      if (secs > secsPerMin) {
          mins = secs / secsPerMin;
          secs -= mins * secsPerMin;
      }

    NSString *formattedString = @"";
      if (hours > 0) {
          formattedString = [NSString stringWithFormat:@"%zd",hours];
      }
      formattedString = [NSString stringWithFormat:@"%@ %zd : %zd",formattedString,mins,secs];
    return formattedString;
}

#pragma mark - Event
- (void)pauseEvent{
    //默认点击之后播放，按钮变成暂停
    if (self.player.isPlaying) {
        [self.player pause];
       self.updater.paused = YES;
       self.pauseButton.selected = YES;
       [self disconnectVolumeTap];
    }else{
        //播放
       if (self.needsFileScheduled) {
           self.needsFileScheduled = NO;
           [self scheduleAudioFile];
       }
       self.updater.paused = NO;
       self.pauseButton.selected = NO;
       [self connectVolumeTap];
       [self.player play];
    }
}

- (void)forwardEvent{
    if (!self.player.engine) {
        return;
    }
    [self seekTime:10];
}

- (void)backEvent{
    if (!self.player.engine) {
        return;
    }
    [self seekTime:-10];
}

- (void)changeRate{
    NSInteger index = round(self.rateSlider.value);
    [self.rateSlider setValue:index animated:false];
    self.rateValue = [self.rateSliderValues[index] floatValue];
    self.rateEffect.rate = self.rateValue;
    self.rateLabel.text = [NSString stringWithFormat:@"当前速率：%f",self.rateValue];
}

- (void)scheduleAudioFile{
    if (!self.audioFileURL) {
        return;
    }
    
    self.seekFrame = 0;
    __weak typeof(self) weakSelf = self;
    //at：是您希望音频播放的未来时间（AVAudioTime）。 设置为nil会立即开始播放。 该文件仅调度播放一次
    //该文件仅调度播放一次。 再次点击Play按钮不会从头重新开始。 您需要重新调度再次播放。 播放完音频文件后，在完成块中设置标志needsFileScheduled
    [self.player scheduleFile:self.audioFile atTime:nil completionHandler:^{
        __strong typeof(self) strongSelf = weakSelf;
        
        strongSelf.needsFileScheduled = YES;
        strongSelf.pauseButton.selected = NO;
    }];
    
}

- (void)seekTime:(CGFloat)time{
    if (!self.audioFile || !self.updater) {
        return;
    }
    
    /*
     1）通过乘以audioSampleRate将时间（以秒为单位）转换为帧位置，并将其添加到currentPosition。然后，确保skipFrame不在文件开头之前，也不超过文件末尾。
     2）player.stop（）不仅停止播放，还清除所有先前调度的事件。调用updateUI（）将UI设置为新的currentPosition值。
     3）player.scheduleSegment（_：startingFrame：frameCount：at :)调度从audioFile的skipFrame位置开始播放。 frameCount是要播放的帧数。您想要播放到文件末尾，因此将其设置为audioLengthSamples - skipFrame。最后，at：nil指定立即开始播放，而不是在将来的某个时间开始播放。
     4）如果在调用skip之前播放器正在播放，则调用player.play（）以恢复播放。 updater.isPaused可以方便地确定这一点，因为只有先前暂停了播放器才会生效。
     */
    
    self.seekFrame = self.currentPosition  + time * self.audioSampleRate;
    self.seekFrame = MAX(self.seekFrame, 0);
    self.seekFrame = MIN(self.seekFrame, self.audioLengthSamples);
    self.currentPosition = self.seekFrame;
    
    [self.player stop];
    
    //如果拖动之后当前进度没有播放完，接着播放
    if (self.currentPosition < self.audioLengthSamples) {
        [self updateUI];
        self.needsFileScheduled = NO;
        AVAudioFrameCount count = (AVAudioFrameCount)(self.audioLengthSamples - self.seekFrame);
        __weak typeof(self) weakSelf = self;
        [self.player scheduleSegment:self.audioFile startingFrame:self.seekFrame frameCount:count atTime:nil completionHandler:^() {
            __strong typeof(self) strongSelf = weakSelf;

            strongSelf.needsFileScheduled = NO;
        }];
        
        //之前如果不是暂停状态，接着播放
        if (!self.updater.paused) {
            [self.player play];
        }
    }
    
}

#pragma mark - connect
- (void)connectVolumeTap{
    /*
     1）获取mainMixerNode输出的数据格式。
 2）installTap（onBus：0，bufferSize：1024，format：format）使您可以访问mainMixerNode输出总线上的音频数据。您请求1024字节的缓冲区大小，但不保证请求的大小，特别是如果您请求的缓冲区太小或太大。 Apple的文档没有说明这些限制是什么。完成block接收AVAudioPCMBuffer和AVAudioTime作为参数。您可以检查buffer.frameLength以确定实际的缓冲区大小。 when提供缓冲区的捕获时间。
     3）buffer.floatChannelData为您提供了指向每个样本数据的指针数组。 channelDataValue是UnsafeMutablePointer <Float>的数组
     */
    
    AVAudioFormat *format = [self.engine.mainMixerNode outputFormatForBus:0];
    
    __weak typeof(self) weakSelf = self;
    [self.engine.mainMixerNode installTapOnBus:0 bufferSize:1024 format:format block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!buffer.floatChannelData || !strongSelf.updater) {
            return ;
        }
        
        //
        
    }];
}

- (void)disconnectVolumeTap{
    [self.engine.mainMixerNode removeTapOnBus:0];
}

#pragma mark - lazy load
- (AVAudioFramePosition)currentFrame{
    _currentFrame = [self.player playerTimeForNodeTime:self.player.lastRenderTime].sampleTime;
    return _currentFrame;
}

@end
