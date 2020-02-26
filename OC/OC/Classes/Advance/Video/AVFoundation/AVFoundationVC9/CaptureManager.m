//
//  CaptureManager.m
//  OC
//
//  Created by yier on 2020/2/25.
//  Copyright © 2020 yier. All rights reserved.
//

#import "CaptureManager.h"

@interface CaptureManager()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
@property(nonatomic, strong) AVCaptureSession *captureSession;
@property(nonatomic, weak) AVCaptureDeviceInput *activeCamera;///<当前正在使用的输入设备(摄像头)
@property(nonatomic, strong) dispatch_queue_t videoDataQueue;///<视频数据处理队列
@property(nonatomic, strong) dispatch_queue_t audioDataQueue;///<音频数据处理队列
@property(nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;///<捕捉的视频数据输出对象
@property(nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;///<捕捉的音频数据输出对象

@end

@implementation CaptureManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.videoDataQueue = dispatch_queue_create("com.yier.videoDataQueue", DISPATCH_QUEUE_SERIAL);
        self.audioDataQueue = dispatch_queue_create("com.yier.audioDataQueue", DISPATCH_QUEUE_SERIAL);
        
    }
    return self;
}

#pragma MARK: - SessionConfig
- (void)setupSession:(CompletionHandler)completion{
    self.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    [self setupSessionInput:^(BOOL isSuccess, NSError *error) {
        if (!isSuccess) {
            !completion?:completion(isSuccess,error);
        }
    }];
    
    [self setupSessionOutput:^(BOOL isSuccess, NSError *error) {
        !completion?:completion(isSuccess,error);
    }];
}

- (void)setupSessionInput:(CompletionHandler)completion{
    NSError *deviceError = [NSError errorWithDomain:@"com.session.error" code:0 userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"配置录制设备出错", @"")}];
    //配置摄像头
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!videoDevice) {
        completion(NO,deviceError);
        return;
    }
    NSError *error;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (error) {
        completion(NO,error);
        return;
    }
    if ([self.captureSession canAddInput:videoInput]) {
        [self.captureSession addInput:videoInput];
        self.activeCamera = videoInput;
    }
    
    //配置麦克风
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (!audioDevice) {
           completion(NO,deviceError);
           return;
       }
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    if (error) {
        completion(NO,error);
        return;
    }
    if ([self.captureSession canAddInput:audioInput]) {
        [self.captureSession addInput:audioInput];
    }
    completion(YES,nil);
}

- (void)setupSessionOutput:(CompletionHandler)completion{
    NSError *outputError = [NSError errorWithDomain:@"com.session.error" code:0 userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"配置输出设置出错", @"")}];
    //摄像头采集的yuv是压缩的视频信号，要还原成可以处理的数字信号
    NSDictionary *outputSettings = @{
        (__bridge NSString*)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)
    };
    self.videoDataOutput.videoSettings = outputSettings;
   //不丢弃迟到帧，但会增加内存开销
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = NO;
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataQueue];

    if ([self.captureSession canAddOutput:self.videoDataOutput]){
        [self.captureSession addOutput:self.videoDataOutput];
    }else{
        completion(NO,outputError);
        return;
   }
    
    [self.audioDataOutput setSampleBufferDelegate:self queue:self.audioDataQueue];
     if ([self.captureSession canAddOutput:self.audioDataOutput]){
           [self.captureSession addOutput:self.audioDataOutput];
       }else{
           completion(NO,outputError);
           return;
      }
           
    completion(YES,nil);
}

#pragma mark - Session operation
- (void)startSession{
       //防止阻塞主线程
    dispatch_async(self.videoDataQueue, ^{
        if (!self.captureSession.isRunning) {
            [self.captureSession startRunning];
        }
    });
}
- (void)stopSession{
    dispatch_async(self.videoDataQueue, ^{
        if (!self.captureSession.isRunning) {
            [self.captureSession stopRunning];
        }
    });
}
#pragma mark - utils
- (NSDictionary *)recommendedVideoSettingsForAssetWriter:(AVFileType)outputFileType{
       return [self.videoDataOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:outputFileType];
}

-(NSDictionary *)recommendedAudioSettingsForAssetWriter:(AVFileType)outputFileType{
    return [self.audioDataOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:outputFileType];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (output == self.videoDataOutput) {
        !self.videoDataCallback?:self.videoDataCallback(sampleBuffer);
    }else if (output == self.audioDataOutput){
        !self.audioDataCallback?:self.audioDataCallback(sampleBuffer);
    }
}

#pragma mark - lazy load

- (AVCaptureSession *)captureSession{
    if(!_captureSession){
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

- (AVCaptureVideoDataOutput *)videoDataOutput{
    if(!_videoDataOutput){
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    }
    return _videoDataOutput;
}

- (AVCaptureAudioDataOutput *)audioDataOutput{
    if(!_audioDataOutput){
        _audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    }
    return _audioDataOutput;
}

@end
