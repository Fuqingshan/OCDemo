//
//  AVFoundationVC14.m
//  AVFoundationDemo
//
//  Created by yier on 2020/2/12.
//  Copyright © 2020 yier. All rights reserved.
//

#import "AVFoundationVC14.h"
#import <AVFoundation/AVFoundation.h>

@interface AVFoundationVC14 ()
@property(nonatomic, strong) AVAssetReader *reader;
@property(nonatomic, strong) AVAssetReaderTrackOutput *timecodeOutput;
@end

@implementation AVFoundationVC14

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)initData{
    
}

- (void)setupUI{
    
}

#pragma mark - 1、创建Timecode轨道。注意：AVAssetWriterInput的naturalSize可以设置轨道尺寸
- (void)createTimecodeTrack{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES).firstObject;
    path = [[path stringByAppendingPathComponent:@"out"] stringByAppendingPathExtension:@"mov"];
    NSURL *localOutputURL = [NSURL URLWithString:path];
    NSError *error;
    AVAssetWriter *assetWriter = [[AVAssetWriter alloc] initWithURL:localOutputURL fileType:AVFileTypeQuickTimeMovie error:&error];
    //设置写入采样的视频轨道
    AVAssetWriterInput *videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:nil];
    [assetWriter addInput:videoInput];
    
    //设置写入timecode采样的timecode轨道
    AVAssetWriterInput *timecodeInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeTimecode outputSettings:nil];
   //设置timecode与视频轨道的关联
    [videoInput addTrackAssociationWithTrackOfInput:timecodeInput type:AVTrackAssociationTypeTimecode];
    
    [assetWriter addInput:timecodeInput];
}

#pragma mark - 2、时间码格式描述CMTimeCodeFormatDescriptionCreate
- (void)timecodeDes{
    //CMTimeCodeFormatDescriptionCreate
    /*
     时间码格式类型（CMTimeCodeFormatType） - 时间码格式类型之一，例如kCMTimeCodeFormatType_TimeCode32，它将样本类型描述为32位整数。
     帧持续时间（CMTime） - 每帧的持续时间（例如，100/2997）。 这指定了每个帧持续时间由时间标度定义的时间长度。
     Frame Quanta（uint32_t） - 表示每秒存储的帧数，例如30。
     时间码标志（uint32_t） - 提供某些时间码格式信息的标志，例如kCMTimeCodeFlag_DropFrame，表示时间码偶尔丢帧以保持同步。 某些时间代码以每秒不超过一帧的帧数运行。 例如，NTSC视频以每秒29.97帧的速度运行。 为了在时间码速率和每秒30帧的重播速率之间重新同步，时间码在可预测的时间丢弃帧（与闰年保持日历同步的方式大致相同）。 如果时间码使用drop-frame技术，则将此标志设置为1。 其他标志包括kCMTimeCodeFlag_24HourMax，以指示时间码值在24小时内换行。 如果时间码小时值在24小时包装（即返回0），并将kCMTimeCodeFlag_NegTimesOK指定为时间码支持负时间值，则将此标志设置为1。 如果时间码允许负值，则将此标志设置为1。
     扩展（CFDictionary） - 提供源名称信息（kCMTimeCodeFormatDescriptionExtension_SourceReferenceName）的可选字典。 此扩展名是包含以下两个键的CFDictionary; kCMTimeCodeFormatDescriptionKey_Value一个CFString和kCMTimeCodeFormatDescriptionKey_LangCode一个CFNumber。 描述键可能包含创建电影的录像带的名称。
     */
}

#pragma mark - 3、创建时间码格式描述
- (void)createTimecodeDes{
    CMTimeCodeFormatDescriptionRef formatDes = NULL;
    uint32_t tcFlags = kCMTimeCodeFlag_DropFrame | kCMTimeCodeFlag_24HourMax;
    OSStatus status = CMTimeCodeFormatDescriptionCreate(kCFAllocatorDefault, kCMTimeCodeFormatType_TimeCode32, CMTimeMake(100, 2997), 30, tcFlags, NULL, &formatDes);
}

#pragma mark - 4、时间吗媒体采样
- (void)timecodeSample{
//如果时间码值允许负时间值（格式描述标志字段设置了kCMTimeCodeFlag_NegTimesOK标志），则CVSMPTETime结构的分钟字段指示时间值是正还是负。 如果分钟字段的tcNegativeFlag（0x80）位被设置，则时间值为负
}

#pragma mark - 5、时间码采集数据
- (void)timecodeSampleData{
    //'tmcd'时间码样本数据格式 - QuickTime文件格式规范
    /*
     CMTimeCodeFormatType_TimeCode32 ('tmcd') Timecode Sample Data Format.
      
     The timecode media sample data format is a big-endian signed 32-bit integer and may be interpreted into a timecode value as follows:
      
     Hours
     An 8-bit unsigned integer that indicates the starting number of hours.
      
     Negative
     A 1-bit value indicating the time’s sign. If bit is set to 1, the timecode record value is negative.
      
     Minutes
     A 7-bit integer that contains the starting number of minutes.
      
     Seconds
     An 8-bit unsigned integer indicating the starting number of seconds.
      
     Frames
     An 8-bit unsigned integer that specifies the starting number of frames. This field’s value cannot exceed the value of the frame quanta value in the timecode format description.
     */
}

#pragma mark - 6、创建一个时间码媒体采样
//创建时间码媒体样本所需的步骤。该方法为SMPTE时间01：30：15：07（HH：MM：SS：FF）创建单个时间码媒体样本，持续整个视频轨道持续时间的30fps丢帧格式。
- (CMSampleBufferRef)createTimecodeMediaSample{
    CMSampleBufferRef sampleBuffer = NULL;
    CMBlockBufferRef dataBuffer = NULL;
    
    CMTimeCodeFormatDescriptionRef formatDescription = NULL;
    CVSMPTETime timecodeSample = {0};
    
    OSStatus status = noErr;
    
    timecodeSample.hours = 1;//HH
    timecodeSample.minutes = 30;//MM
    timecodeSample.seconds = 15;//SS
    timecodeSample.frames = 7;//FF
    
    status = CMTimeCodeFormatDescriptionCreate(kCFAllocatorDefault, kCMTimeCodeFormatType_TimeCode32, CMTimeMake(100, 2997), 30, kCMTimeCodeFlag_DropFrame | kCMTimeCodeFlag_24HourMax, NULL, &formatDescription);
    
    if ((status != noErr) || !formatDescription) {
        NSLog(@"Could not create format description");
    }
    
    //使用函数将CVSMPTETime 时间转化为帧率写入
    int32_t frameNumberData = frameNumber32ForTimecodeUsingFormatDescription(timecodeSample,formatDescription);
    status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, NULL, sizeof(int32_t), kCFAllocatorDefault, NULL, 0, sizeof(int32_t), kCMBlockBufferAssureMemoryNowFlag, &dataBuffer);
       if ((status != kCMBlockBufferNoErr) || !dataBuffer) {
           NSLog(@"Could not create block buffer");
       }
    
       status = CMBlockBufferReplaceDataBytes(&frameNumberData, dataBuffer, 0, sizeof(int32_t));
       if (status != kCMBlockBufferNoErr) {
           NSLog(@"Could not write into block buffer");
       }
    
       CMSampleTimingInfo timingInfo;
       // duration of each timecode sample is from the current frame to the next frame specified along with a timecode
       // in this case the single sample will last the entire duration of the video content
       timingInfo.duration = CMTimeMake(1, 4);
       timingInfo.decodeTimeStamp = kCMTimeInvalid;
       timingInfo.presentationTimeStamp = kCMTimeZero;
    
       size_t sizes = sizeof(int32_t);
       status = CMSampleBufferCreate(kCFAllocatorDefault, dataBuffer, true, NULL, NULL, formatDescription, 1, 1, &timingInfo, 1, &sizes, &sampleBuffer);
       if ((status != noErr) || !sampleBuffer) {
           NSLog(@"Could not create block buffer");
       }
    
       CFRelease(formatDescription);
       CFRelease(dataBuffer);
    
    return sampleBuffer;
}

#pragma mark - 7、追加一个时间码媒体采样
//追加时间码媒体样本的方式与其他媒体数据完全相同。AVAssetWriterInput - （BOOL）appendSampleBuffer：（CMSampleBufferRef）sampleBuffer方法用于追加打包为CMSampleBuffer对象的媒体样本
- (void)appendingTimecodeMediaSample:(AVAssetWriterInput *)timecodeInput{
    BOOL completedOrFailed = NO;
    if ([timecodeInput isReadyForMoreMediaData] && !completedOrFailed) {
        CMSampleBufferRef sampleBuffer = NULL;
          sampleBuffer = [self createTimecodeMediaSample];
          if (sampleBuffer != NULL) {
              BOOL success = [timecodeInput appendSampleBuffer:sampleBuffer];
              CFRelease(sampleBuffer);
              sampleBuffer = NULL;
              completedOrFailed = !success;
          }else{
              completedOrFailed = YES;
          }
    }
  
}

#pragma mark - Reader
- (void)createReader{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES).firstObject;
    path = [[path stringByAppendingPathComponent:@"out"] stringByAppendingPathExtension:@"mov"];
    NSURL *localOutputURL = [NSURL URLWithString:path];
    
    AVAsset *asset = [AVAsset assetWithURL:localOutputURL];
    NSError *error;
    self.reader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    if (error) {
        return;
    }
    
    // Create asset reader output for the first timecode track of the asset

    AVAssetTrack *timecodeTrack = nil;
    
       // Grab first timecode track, if the asset has them
       NSArray *timecodeTracks = [asset tracksWithMediaType:AVMediaTypeTimecode];
       if ([timecodeTracks count] > 0)
           timecodeTrack = [timecodeTracks objectAtIndex:0];
       if (timecodeTrack) {
           self.timecodeOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:timecodeTrack outputSettings:nil];
           [self.reader addOutput:self.timecodeOutput];
       } else {
           NSLog(@"%@ has no timecode tracks", asset);
       }
}

//Read a Timecode Sample Buffer and print out the CVSMPTETime.
- (BOOL)startReadingAndPrintingOutputReturningError:(NSError **)outError{
    BOOL success= YES;
    NSError *localError = nil;
    
    //Instruct asset reader to get ready to do work
    success = [self.reader startReading];
    
    if (!success) {
        localError = [self.reader error];
    }else{
        CMSampleBufferRef currentSampleBuffer = NULL;
        
       while ((currentSampleBuffer = [self.timecodeOutput copyNextSampleBuffer])) {
           [self outputTimecodeDescriptionForSampleBuffer:currentSampleBuffer];
       }

       if (currentSampleBuffer) {
           CFRelease(currentSampleBuffer);
       }
    }
    
    if (!success && outError) {
        *outError = localError;
    }
    
    return success;
}

- (void)outputTimecodeDescriptionForSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    if (blockBuffer && formatDescription) {
        size_t length = 0;
        size_t totalLength = 0;
        char *rawData = NULL;
        
        OSStatus status = CMBlockBufferGetDataPointer(blockBuffer, 0, &length, &totalLength, &rawData);
        if (status != kCMBlockBufferNoErr) {
            NSLog(@"cloud not get data from block buffer");
        }else{
            CMMediaType type = CMFormatDescriptionGetMediaType(formatDescription);
            
            if (type == kCMTimeCodeFormatType_TimeCode32) {
                int32_t *frameNumberRead = (int32_t *)rawData;
                CVSMPTETime timecode = timecodeForFrameNumber32UsingFormatDescription(*frameNumberRead, formatDescription);
                BOOL dropFrame = CMTimeCodeFormatDescriptionGetTimeCodeFlags(formatDescription) & kCMTimeCodeFlag_DropFrame;
                   char separator = dropFrame ? ',' : '.';
                   NSLog(@"%@",[NSString stringWithFormat:@"HH:MM:SS%cFF => %02d:%02d:%02d%c%02d (frame number: %d)", separator, timecode.hours, timecode.minutes, timecode.seconds,  separator, timecode.frames, (int)(*frameNumberRead)]);
                
            }
        }
    }
}

enum{
  tcNegativeFlag = 0x80 /*nagative bit is in minutes*/
};

#pragma mark - 时间码实用函数
//如何将CVSMPTETime转换为帧编号，并将帧编号转换为kCMTimeCodeFormatType_TimeCode32时间代码媒体样本格式的CVSMPTETim
int32_t frameNumber32ForTimecodeUsingFormatDescription(CVSMPTETime timecode, CMTimeCodeFormatDescriptionRef formatDescription){
    int32_t frameNumber = 0;
 
    if (CMTimeCodeFormatDescriptionGetFormatType(formatDescription) == kCMTimeCodeFormatType_TimeCode32) {
        int32_t frameQuanta = CMTimeCodeFormatDescriptionGetFrameQuanta(formatDescription);
 
        frameNumber = timecode.frames;
        frameNumber += timecode.seconds * frameQuanta;
        frameNumber += (timecode.minutes & ~tcNegativeFlag) * frameQuanta * 60;
        frameNumber += timecode.hours * frameQuanta * 60 * 60;
 
        int32_t fpm = frameQuanta * 60;
 
        if (CMTimeCodeFormatDescriptionGetTimeCodeFlags(formatDescription) & kCMTimeCodeFlag_DropFrame) {
            int32_t fpm10 = fpm * 10;
            int32_t num10s = frameNumber / fpm10;
            int32_t frameAdjust = -num10s*(9*2);
            int32_t numFramesLeft = frameNumber % fpm10;
 
            if (numFramesLeft > 1) {
                int32_t num1s = numFramesLeft / fpm;
                if (num1s > 0) {
                    frameAdjust -= (num1s-1)*2;
                    numFramesLeft = numFramesLeft % fpm;
                    if (numFramesLeft > 1)
                        frameAdjust -= 2;
                    else
                        frameAdjust -= (numFramesLeft+1);
                }
            }
            frameNumber += frameAdjust;
        }
 
        if (timecode.minutes & tcNegativeFlag) {
            frameNumber = -frameNumber;
        }
    }
 //mac os
//    return EndianS32_NtoB(frameNumber);
    return frameNumber;
}

// Frame Number (kCMTimeCodeFormatType_TimeCode32 Media Sample) to CVSMPTETime

CVSMPTETime timecodeForFrameNumber32UsingFormatDescription(int32_t frameNumber, CMTimeCodeFormatDescriptionRef formatDescription)
{
    CVSMPTETime timecode = {0};
 
    if (CMTimeCodeFormatDescriptionGetFormatType(formatDescription) == kCMTimeCodeFormatType_TimeCode32) {
        //mac os
        //        frameNumber = EndianS32_BtoN(frameNumber);
        frameNumber = frameNumber;
 
        short fps = CMTimeCodeFormatDescriptionGetFrameQuanta(formatDescription);
        BOOL neg = FALSE;
 
        if (frameNumber < 0) {
            neg = TRUE;
            frameNumber = -frameNumber;
        }
 
        if (CMTimeCodeFormatDescriptionGetTimeCodeFlags(formatDescription) & kCMTimeCodeFlag_DropFrame) {
            int32_t fpm = fps*60 - 2;
            int32_t fpm10 = fps*10*60 - 9*2;
            int32_t num10s = frameNumber / fpm10;
            int32_t frameAdjust = num10s*(9*2);
            int32_t numFramesLeft = frameNumber % fpm10;
 
            if (numFramesLeft >= fps*60) {
                numFramesLeft -= fps*60;
                int32_t num1s = numFramesLeft / fpm;
                frameAdjust += (num1s+1)*2;
            }
            frameNumber += frameAdjust;
        }
 
        timecode.frames = frameNumber % fps;
        frameNumber /= fps;
        timecode.seconds = frameNumber % 60;
        frameNumber /= 60;
        timecode.minutes = frameNumber % 60;
        frameNumber /= 60;
 
        if (CMTimeCodeFormatDescriptionGetTimeCodeFlags(formatDescription) & kCMTimeCodeFlag_24HourMax) {
            frameNumber %= 24;
            if (neg && !(CMTimeCodeFormatDescriptionGetTimeCodeFlags(formatDescription) & kCMTimeCodeFlag_NegTimesOK)) {
                neg = FALSE;
                frameNumber = 23 - frameNumber;
            }
        }
        timecode.hours = frameNumber;
        if (neg) {
            timecode.minutes |= tcNegativeFlag;
        }
 
        timecode.flags = kCVSMPTETimeValid;
    }
 
    return timecode;
}

/*
 建议使用kCMTimeCodeFormatType_TimeCode32，可与旧版本基于QuickTime的媒体应用程序交互
 CMTimeCodeFormatType_TimeCode64 ('tc64') Timecode Sample Data Format.
  
 The timecode media sample data format is a big-endian signed 64-bit integer representing a frame number that is typically converted to and from SMPTE timecodes representing hours, minutes, seconds, and frames, according to information carried in the format description.
  
 Converting to and from the frame number stored as media sample data and a CVSMPTETime structure is performed using simple modular arithmetic with the expected adjustments for drop frame timecode performed using information in the format description such as the frame quanta and the drop frame flag.
  
 The frame number value may be interpreted into a timecode value as follows:
  
 Hours
 A 16-bit signed integer that indicates the starting number of hours.
  
 Minutes
 A 16-bit signed integer that contains the starting number of minutes.
  
 Seconds
 A 16-bit signed integer indicating the starting number of seconds.
  
 Frames
 A 16-bit signed integer that specifies the starting number of frames. This field’s value cannot exceed the value of the frame quanta value in the timecode format description.
 */

@end
