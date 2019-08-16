//
//  CustomAudioPlayer.m
//  OC
//
//  Created by yier on 2019/8/12.
//  Copyright © 2019 yier. All rights reserved.
//

#import "CustomAudioPlayer.h"

@interface CustomAudioPlayer()
@property (nonatomic, strong) AVAudioEngine *engine;

@property (nonatomic, strong) AVAudioFile *audioFile;

@property (nonatomic, strong) AVAudioPlayerNode *playerNode;
// effects
@property (nonatomic, strong) AVAudioUnitReverb *audioReverb;
@property (nonatomic, strong) AVAudioUnitDistortion *audioDistortion;
@property (nonatomic, strong) AVAudioUnitVarispeed *audioSpeed;
@property (nonatomic, strong) AVAudioUnitEQ *audioEQ;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign)AVAudioFramePosition lastStartFramePosition;

@end

@implementation CustomAudioPlayer

- (void)dealloc {
    NSLog(@"CustomAudioPlayer dealloc");
    self.delegate = nil;
    [self.playerNode stop];
    [self.engine stop];
    [self.timer invalidate];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createEngine];
        
        // init a timer to catch current time;
        @weakify(self);
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 block:^(NSTimer * _Nonnull timer) {
            @strongify(self);
            [self catchCurrentTime];
        } repeats:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eqDidChangedNotification:) name:kEQChangedNotificationName object:nil];
    }
    return self;
}

- (void)eqDidChangedNotification:(NSNotification *)notification {
    NSArray *bands = [self.audioEQ.bands sortedArrayUsingComparator:^NSComparisonResult(AVAudioUnitEQFilterParameters *obj1, AVAudioUnitEQFilterParameters *obj2) {
        if (obj1.frequency > obj2.frequency) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    NSInteger bandsCount = bands.count;
    for (NSInteger i = 0; i < bandsCount; i ++) {
        AVAudioUnitEQFilterParameters *ban = [bands objectAtIndex:i];
        //        NSLog(@"%f", ban.frequency);
        CGFloat gainValue = [[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@%d", kEQBandKeyPrefix, (int)i]] floatValue];
        ban.bypass = gainValue == 0;
        ban.gain = gainValue;
    }
}

- (void)createEngine{
    self.engine = [[AVAudioEngine alloc] init];
    [self createAudioReverb];
    [self createAVAudioUnitDistortion];
    [self createAudioSpeed];
    [self createUnitEQ];
    
    [self createPlay];
    //[self createSing];
}

- (void)createPlay{
    self.playerNode = [[AVAudioPlayerNode alloc] init];
    
    [self.engine attachNode:self.playerNode];
    [self.engine attachNode:self.audioReverb];
    [self.engine attachNode:self.audioDistortion];
    [self.engine attachNode:self.audioSpeed];
    [self.engine attachNode:self.audioEQ];
    
    AVAudioMixerNode *mixer = self.engine.mainMixerNode;
    AVAudioFormat *formatInput= [mixer inputFormatForBus:AVAudioPlayerNodeBufferLoops];
    AVAudioFormat *formatOutput = [mixer outputFormatForBus:0];
    
    //音频播放链式,效果针对播放
    //input（音频文件playerNode）->效果器1->效果器2...->output
    [self.engine connect:self.playerNode to:self.audioEQ format:formatInput];
    [self.engine connect:self.audioEQ to:self.audioReverb format:formatOutput];
    [self.engine connect:self.audioReverb to:self.audioDistortion format:formatOutput];
    [self.engine connect:self.audioDistortion to:self.audioSpeed format:formatOutput];
    [self.engine connect:self.audioSpeed to:mixer format:formatOutput];
    
}

- (void)createSing{
    [self.engine attachNode:self.audioReverb];
    [self.engine attachNode:self.audioDistortion];
    [self.engine attachNode:self.audioSpeed];
    [self.engine attachNode:self.audioEQ];
    
    AVAudioNode *inputNode = self.engine.inputNode;
    AVAudioNode *outputNode = self.engine.outputNode;
    AVAudioFormat *formatInput= [inputNode inputFormatForBus:AVAudioPlayerNodeBufferLoops];
    AVAudioFormat *formatOutput = [outputNode outputFormatForBus:0];

    //清唱链式,input不要用变速，效果针对录入
    [self.engine connect:inputNode to:self.audioReverb format:formatInput];
    [self.engine connect:self.audioReverb to:self.audioDistortion format:formatInput];
    [self.engine connect:self.audioDistortion to:outputNode format:formatOutput];
    
    [self.engine startAndReturnError:nil];
}

/** 音频场景混响
 caseSmallRoom 小房间
 caseMediumRoom 中等房间
 caseLargeRoom 大房间
 caseMediumHall 中等大厦
 caseLargeHall 大型的大厦
 casePlate 光面墙
 caseMediumChamber 中等会议厅
 caseLargeChamber 大型会议厅
 caseCathedral 教堂
 caseLargeRoom2 大型房间2
 caseMediumHall2 中等大厦2
 caseMediumHall3 中等大厦3
 caseLargeHall2 大型大厦2
 */
- (void)createAudioReverb{
    self.audioReverb = [[AVAudioUnitReverb alloc] init];
    [self.audioReverb loadFactoryPreset:AVAudioUnitReverbPresetLargeRoom2];
    
    self.audioReverb.wetDryMix = 70;//声音更空灵
}

/**音频失真效果
 AVAudioUnitDistortionPresetDrumsBitBrush 轻微的小鼓刷
 AVAudioUnitDistortionPresetDrumsBufferBeats 鼓点
 AVAudioUnitDistortionPresetDrumsLoFi 低保真
 AVAudioUnitDistortionPresetMultiBrokenSpeaker 多通道 破裂的嗓音
 AVAudioUnitDistortionPresetMultiCellphoneConcert 老式电话机的声音
 AVAudioUnitDistortionPresetMultiDecimated1 削波失真
 AVAudioUnitDistortionPresetMultiDecimated2 削波失真
 AVAudioUnitDistortionPresetMultiDecimated3 削波失真
 AVAudioUnitDistortionPresetMultiDecimated4 削波失真
 AVAudioUnitDistortionPresetMultiDistortedFunk  扭曲的funk效果失真
 AVAudioUnitDistortionPresetMultiDistortedCubed 扭曲的立方体效果
 AVAudioUnitDistortionPresetMultiDistortedSquared 扭曲的正方体效果
 AVAudioUnitDistortionPresetMultiEcho1 回声
 AVAudioUnitDistortionPresetMultiEcho2  回声
 AVAudioUnitDistortionPresetMultiEchoTight1 紧密的回声
 AVAudioUnitDistortionPresetMultiEchoTight2 紧密的回声
 AVAudioUnitDistortionPresetMultiEverythingIsBroken 破碎的失真
 AVAudioUnitDistortionPresetSpeechAlienChatter 外星人喋喋不休的声音
 AVAudioUnitDistortionPresetSpeechCosmicInterference 宇宙电子干扰的声音
 AVAudioUnitDistortionPresetSpeechGoldenPi 金属声音
 AVAudioUnitDistortionPresetSpeechRadioTower 收音机的声音
 AVAudioUnitDistortionPresetSpeechWaves 波形的声音
 */
- (void)createAVAudioUnitDistortion{
    self.audioDistortion = [[AVAudioUnitDistortion alloc] init];
    [self.audioDistortion loadFactoryPreset:AVAudioUnitDistortionPresetMultiEcho2];
    self.audioDistortion.wetDryMix = 30;
}

- (void)createAudioSpeed{
    self.audioSpeed = [[AVAudioUnitVarispeed alloc] init];
    self.audioSpeed.rate = 1;
}


/**
 publicenumAVAudioUnitEQFilterType :Int{
 caseParametric 参量均衡器 可以通过设置一些参量，来调节咱们均衡器的频点
 caseLowPass 低通滤波器 衰弱高频
 caseHighPass 高通滤波器 衰弱低频
 caseResonantLowPass  可以引发共鸣的 低通滤波器
 caseResonantHighPass 可以引发共鸣的  高通滤波器
 caseBandPass 带通滤波器  提升某一频率附近的信号 忽略过高 或 过低的 部分
 caseBandStop 与上面的相反  忽略某一频率附近的信号
 caseLowShelf 低架 降低整体
 caseHighShelf 高架 提升整体
 caseResonantLowShelf  可以引发共鸣的 低架
 caseResonantHighShelf可以引发共鸣的 高架
 }
 */
- (void)createUnitEQ{
    //10段均衡器
    self.audioEQ = [[AVAudioUnitEQ alloc] initWithNumberOfBands:kEQBandCount];
    NSArray *bands = self.audioEQ.bands;
    NSInteger bandsCount = bands.count;
    
    // api默认的10分段是40、57、83、120、174、251、264、526、5414、10000，应该要改掉
    // 假设是10段，那么市面上的频率分段为32、64、125、250、500、1k、2k、4k、8k、16k
    NSInteger maxFre = 16000;
    for (NSInteger i = bandsCount - 1; i >= 0; i --) {
        AVAudioUnitEQFilterParameters *ban = [bands objectAtIndex:i];
//        ban.filterType = AVAudioUnitEQFilterTypeResonantHighShelf;//这个属性需要专业知识，设置的是苹果默认的滤波器
        ban.frequency = maxFre;
        maxFre /= 2;
    }
    
    [self eqDidChangedNotification:nil];
}

- (void)playAudioWithURL:(NSURL *)url{
    self.url = url;
    self.currentTime = 0;
    // create file or pcm buffer
    self.audioFile = [[AVAudioFile alloc] initForReading:self.url error:nil];
    
    // calculate duration
    AVAudioFrameCount frameCount = (AVAudioFrameCount)self.audioFile.length;
    double sampleRate = self.audioFile.processingFormat.sampleRate;
    if (sampleRate != 0) {
        self.duration = frameCount / sampleRate;
    } else {
        self.duration = 1;
    }
}

- (void)play {
    NSError *error = nil;
    if (!self.engine.running) {
        [self.engine prepare];
        [self.engine startAndReturnError:&error];
    }
    [self.playerNode play];
}

- (void)pause {
    [self.playerNode pause];
    [self.engine stop];
}

- (void)stop {
    self.delegate = nil; // 手动停的必须设delegate nil，不然回调出去又播放下一首了，内存超大
    if (self.isPlaying) {
        [self.playerNode stop];
    }
    [self.engine stop];
}

- (void)didFinishPlay {
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:successfully:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate audioPlayerDidFinishPlaying:(id)self successfully:self.isPlaying];
        });
    }
}

- (BOOL)isPlaying {
    return self.playerNode.isPlaying;
}

- (void)catchCurrentTime {
    if (self.playing) {
        AVAudioTime *playerTime = [self.playerNode playerTimeForNodeTime:self.playerNode.lastRenderTime];
        if (playerTime.sampleRate != 0) {
            _currentTime = (self.lastStartFramePosition + playerTime.sampleTime) / playerTime.sampleRate;
        } else {
            _currentTime = 0;
        }
    }
    if (_currentTime > self.duration) {
        [self.playerNode stop];
    }
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    
    BOOL isPlaying = self.isPlaying;
    id lastdelegate = self.delegate;
    self.delegate = nil;
    [self.playerNode stop];
    self.delegate = lastdelegate;
    
    //计算需要播放的内容长度
    AVAudioFramePosition startingFrame = currentTime * self.audioFile.processingFormat.sampleRate;
    AVAudioFrameCount frameCount = (AVAudioFrameCount)(self.audioFile.length - startingFrame);
    if (frameCount > 1000) {
        self.lastStartFramePosition = startingFrame;
        @weakify(self);
        [self.playerNode scheduleSegment:self.audioFile startingFrame:startingFrame frameCount:frameCount atTime:nil completionHandler:^{
            @strongify(self);
            [self didFinishPlay];
        }];
    }
    if (isPlaying) {
        [self.playerNode play];
    }
}

- (void)readPCMData {
    double sampleRate = 44100;
    NSInteger channelCount = 1;
    NSInteger bitDepth = 8;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 我现在知道通过（采样率、声道数、时长）可以计算出样品个数
        NSInteger sampleCount = self.duration * sampleRate * channelCount;

        NSMutableData *sampleData = [NSMutableData dataWithLength:sampleCount];
        self.pcmData = sampleData;

        if (!self.url) {
            return;
        }
        AVAsset *asset = [AVAsset assetWithURL:self.url];
        AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:nil];
        if (!reader) {
            return;
        }
        AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        NSDictionary *dic = @{AVFormatIDKey:@(kAudioFormatLinearPCM),
                              AVLinearPCMIsBigEndianKey:@NO,
                              AVLinearPCMIsFloatKey:@NO,
                              AVLinearPCMBitDepthKey:@(bitDepth),
                              AVSampleRateKey:@(sampleRate),
                              AVNumberOfChannelsKey:@(channelCount),
                              };
        AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc]initWithTrack:track outputSettings:dic];
        [reader addOutput:output];
        [reader startReading];

        size_t readOffset = 0;
        while (reader.status == AVAssetReaderStatusReading) {
            CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
            if (sampleBuffer) {
                CMBlockBufferRef blockBUfferRef = CMSampleBufferGetDataBuffer(sampleBuffer);
                size_t length = CMBlockBufferGetDataLength(blockBUfferRef);
                if (readOffset + length > sampleCount) {
                    length = sampleCount - readOffset;
                }
                Byte readSampleBytes[length];
                CMBlockBufferCopyDataBytes(blockBUfferRef, 0, length, readSampleBytes);

                [sampleData replaceBytesInRange:NSMakeRange(readOffset, length) withBytes:readSampleBytes length:length];
                readOffset += length; // 修改当前已读数

                CMSampleBufferInvalidate(sampleBuffer);//销毁
                CFRelease(sampleBuffer); //释放
            }
        }
    });
}



@end
