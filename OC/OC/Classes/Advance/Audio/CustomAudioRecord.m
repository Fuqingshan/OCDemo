//
//  CustomAudioRecord.m
//  OC
//
//  Created by yier on 2019/8/16.
//  Copyright © 2019 yier. All rights reserved.
//

#import "CustomAudioRecord.h"
#import <AVFoundation/AVFoundation.h>

@interface CustomAudioRecord()
@property (nonatomic, strong) AVAudioEngine *engine;

@property (nonatomic, strong) AVAudioFile *audioFile;

// effects
@property (nonatomic, strong) AVAudioUnitReverb *audioReverb;
@property (nonatomic, strong) AVAudioUnitDistortion *audioDistortion;
@property (nonatomic, strong) AVAudioUnitEQ *audioEQ;

@property (nonatomic, strong) AVAudioNode *outputNode;

@end

@implementation CustomAudioRecord

- (void)dealloc{
    NSLog(@"CustomAudioRecord dealloc");
    [self.engine stop];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createEngine];
    }
    return self;
}


- (void)createEngine{
    self.engine = [[AVAudioEngine alloc] init];
    [self createAudioReverb];
    [self createAVAudioUnitDistortion];
    [self createUnitEQ];
    
    [self createSing];
}

- (void)createSing{
    [self.engine attachNode:self.audioReverb];
    [self.engine attachNode:self.audioDistortion];
    [self.engine attachNode:self.audioEQ];
    
    AVAudioNode *inputNode = self.engine.inputNode;
    AVAudioFormat *formatInput;
    AVAudioFormat *formatOutput;
    AVAudioNode *recordNode;

    //根据设置确认录制的是原生还是混响
    if ((self.ignoreMixer || self.supportPCM)) {
        self.outputNode = self.engine.outputNode;
        formatInput = [inputNode inputFormatForBus:AVAudioPlayerNodeBufferLoops];
    }else{
        self.outputNode = self.engine.mainMixerNode;
        formatInput = [self.engine.mainMixerNode inputFormatForBus:AVAudioPlayerNodeBufferLoops];
    }
    
    AVAudioFormat *formatOutput = [self.outputNode outputFormatForBus:0];
    
    //清唱链式,input不要用变速，效果针对录入
    [self.engine connect:inputNode to:self.audioReverb format:formatInput];
    [self.engine connect:self.audioReverb to:self.audioDistortion format:formatInput];
    [self.engine connect:self.audioDistortion to:self.outputNode format:formatOutput];
    
    @weakify(self);
    [self.outputNode installTapOnBus:0 bufferSize:4096 format:[self.outputNode inputFormatForBus:AVAudioPlayerNodeBufferLoops] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        @strongify(self);
        [self.audioFile writeFromBuffer:buffer error:nil];
        !self.successBlock?:self.successBlock(self.audioFile.url.path);
        CGFloat second = when.sampleTime/when.sampleRate;
        //如果录制时间大于10秒，则停止录制
        if (second > 10) {
            [self stopRecord];
        }
    }];
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
    
    self.audioReverb.wetDryMix = 100;//声音更空灵
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
    self.audioEQ = [[AVAudioUnitEQ alloc] initWithNumberOfBands:10];
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
}

#pragma mark - 开始录音
- (void)startRecordWithURL:(NSURL *)url{
    if (!url) {
        !self.failureBlock?:self.failureBlock([NSError errorWithDomain:@"录制的url不能为空" code:-1 userInfo:nil]);
        return;
    }
    
    if (self.supportPCM) {
        url = [[url URLByDeletingPathExtension] URLByAppendingPathExtension:@"pcm"];
    }
    
    NSError *error;
    self.audioFile = [[AVAudioFile alloc] initForWriting:url settings:@{} error:&error];
    if (error) {
        !self.failureBlock?:self.failureBlock(error);
        return;
    }
    //如果之前在录制，则停止
    [self stopRecord];
    
    //开始录制
    [self startRecord];
}

#pragma mark - Event
- (void)startRecord{
    if (!self.engine.running) {
        NSError *error;
        [self.engine prepare];
       BOOL success = [self.engine startAndReturnError:&error];
        if (!success) {
            [self.engine stop];
            !self.failureBlock?:self.failureBlock(error);
        }
    }
}

- (void)stopRecord{
    if (self.engine.isRunning) {
        [self.engine stop];
    }
}

@end
