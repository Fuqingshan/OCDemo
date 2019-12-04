//
//  CustomAudioPlayer.m
//  OC
//
//  Created by yier on 2019/8/12.
//  Copyright © 2019 yier. All rights reserved.
//

#import "CustomAudioPlayer.h"

const double sampleRate = 44100;
const NSInteger channelCount = 1;
const NSInteger bitDepth = 8;

@interface CustomAudioPlayer()
@property (nonatomic, strong) AVAudioEngine *engine;
@property (nonatomic, strong) AVAudioPlayerNode *playerNode;

@property (nonatomic, strong) AVAudioFile *audioFile;

// effects
@property (nonatomic, strong) AVAudioUnitReverb *audioReverb;
@property (nonatomic, strong) AVAudioUnitDistortion *audioDistortion;
@property (nonatomic, strong) AVAudioUnitEQ *audioEQ;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign)AVAudioFramePosition lastStartFramePosition;

@end

@implementation CustomAudioPlayer

- (void)dealloc {
    self.delegate = nil;
    [self.playerNode stop];
    [self.engine stop];
    [self.timer invalidate];
}

- (instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError * _Nullable __autoreleasing *)outError {
    if (url == nil) {
        NSError *err = [NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:nil];
        *outError = err;
        return nil;
    }
    self = [super init];
    if (self) {
        self.url = url;
        [self myInit];
        [self readPCMData];
    }
    return self;
}

- (void)myInit {
    // create engine and nodes
    self.engine = [[AVAudioEngine alloc] init];
    self.playerNode = [[AVAudioPlayerNode alloc] init];
    
    
    /*
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
    self.audioReverb = [[AVAudioUnitReverb alloc] init];
    [self.audioReverb loadFactoryPreset:AVAudioUnitReverbPresetLargeRoom2];
    self.audioReverb.wetDryMix = 20;

    /*
     caseDrumsBitBrush 轻微的小鼓刷
     caseDrumsBufferBeats 鼓点
     caseDrumsLoFi 低保真
     AVAudioUnitDistortionPresetMultiBrokenSpeaker 多通道 破裂的嗓音
     caseMultiCellphoneConcert 老式电话机的声音
     caseMultiDecimated1 削波失真
     caseMultiDecimated2 削波失真
     caseMultiDecimated3 削波失真
     caseMultiDecimated4 削波失真
     caseMultiDistortedFunk  扭曲的funk效果失真
     caseMultiDistortedCubed 扭曲的立方体效果
     caseMultiDistortedSquared 扭曲的正方体效果
     caseMultiEcho1 回声
     AVAudioUnitDistortionPresetMultiEcho2  回声
     caseMultiEchoTight1 紧密的回声
     caseMultiEchoTight2 紧密的回声
     caseMultiEverythingIsBroken 破碎的失真
     AVAudioUnitDistortionPresetSpeechAlienChatter 外星人喋喋不休的声音
     caseSpeechCosmicInterference 宇宙电子干扰的声音
     caseSpeechGoldenPi 金属声音
     caseSpeechRadioTower 收音机的声音
     caseSpeechWaves 波形的声音
     */
    self.audioDistortion = [[AVAudioUnitDistortion alloc] init];
    [self.audioDistortion loadFactoryPreset:AVAudioUnitDistortionPresetMultiEcho2];
    self.audioDistortion.wetDryMix = 30;
    
    //10段均衡器
    self.audioEQ = [[AVAudioUnitEQ alloc] initWithNumberOfBands:kEQBandCount];
    NSArray *bands = self.audioEQ.bands;
    NSInteger bandsCount = bands.count;
        
    // api默认的10分段是40、57、83、120、174、251、264、526、5414、10000，应该要改掉
    // 假设是10段，那么市面上的频率分段为32、64、125、250、500、1k、2k、4k、8k、16k
    NSInteger maxFre = 16000;
    for (NSInteger i = bandsCount - 1; i >= 0; i --) {
        AVAudioUnitEQFilterParameters *ban = [bands objectAtIndex:i];
        ban.frequency = maxFre;
        maxFre /= 2;
    }
    
    [self eqDidChangedNotification:nil];
    
    AVAudioUnitEffect *effect = self.audioEQ;
    
    // connect effects
    AVAudioMixerNode *mixer = self.engine.mainMixerNode;
    AVAudioFormat *format = [mixer outputFormatForBus:0];
    
    [self.engine attachNode:self.playerNode];
    [self.engine attachNode:self.audioReverb];
    [self.engine attachNode:self.audioDistortion];
    [self.engine attachNode:effect];

    //连接时必须串联，最后输出到输出设备上面
    [self.engine connect:self.playerNode to:effect format:format];
    [self.engine connect:effect to:self.audioReverb format:format];
    [self.engine connect:self.audioReverb to:self.audioDistortion format:format];
    [self.engine connect:self.audioDistortion to:mixer format:format];

    
    // start engine
    NSError *error = nil;
    [self.engine startAndReturnError:&error];
    
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
    
    // play file, or buffer
    self.currentTime = 0;
    
   // init a timer to catch current time;
    @weakify(self);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 block:^(NSTimer * _Nonnull timer) {
        @strongify(self);
        [self catchCurrentTime];
    } repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eqDidChangedNotification:) name:kEQChangedNotificationName object:nil];
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
    __weak typeof(self) weself = self;
    
    AVAudioFramePosition startingFrame = currentTime * self.audioFile.processingFormat.sampleRate;
    
    AVAudioFrameCount frameCount = (AVAudioFrameCount)(self.audioFile.length - startingFrame);
    if (frameCount > 1000) {
        self.lastStartFramePosition = startingFrame;
        [self.playerNode scheduleSegment:self.audioFile startingFrame:startingFrame frameCount:frameCount atTime:nil completionHandler:^{
            [weself didFinishPlay];
        }];
    }
    if (isPlaying) {
        [self.playerNode play];
    }
}

- (void)readPCMData {
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
