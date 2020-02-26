//
//  VideoWriteManager.m
//  OC
//
//  Created by yier on 2020/2/25.
//  Copyright © 2020 yier. All rights reserved.
//

#import "VideoWriteManager.h"

@interface VideoWriteManager()
@property(nonatomic, strong) NSDictionary *videoSettings;
@property(nonatomic, strong) NSDictionary *audioSettings;
@property(nonatomic, assign) AVFileType fileType;

@property(nonatomic, strong) AVAssetWriter *assetWriter;
@property(nonatomic, strong) AVAssetWriterInput *videoInput;
@property(nonatomic, strong) AVAssetWriterInput *audioInput;
@property(nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor;
@property(nonatomic, strong) dispatch_queue_t processQueue;

@property(nonatomic, strong) CIContext *ciContext;
@property(nonatomic, assign) BOOL isWriting;///<是否正在写入
@property(nonatomic, assign) BOOL firstSampleFlag;///<标记接下来接收到的作为第一帧数据

@end

@implementation VideoWriteManager

- (instancetype)initWithVideoSettings:(NSDictionary *)videoSettings audioSettings:(NSDictionary *)audioSettings fileType:(AVFileType)fileType{
    self = [super init];
    if (self) {
        self.videoSettings = videoSettings;
        self.audioSettings = audioSettings;
        self.fileType = fileType;
        self.firstSampleFlag = YES;
        self.processQueue = dispatch_queue_create("com.yier.videoWriter", DISPATCH_QUEUE_SERIAL);
        
        //如果要修改输出视频的宽高等，可修改videoInput配置中的AVVideoHeightKey，AVVideoWidthKey
        self.videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:self.videoSettings];
        self.audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:self.audioSettings];
        
        //针对实时性进行优化
        self.videoInput.expectsMediaDataInRealTime = YES;
        self.audioInput.expectsMediaDataInRealTime = YES;
        
        //手机默认是头部向左拍摄的，需要旋转调整
        self.videoInput.transform = [self fixTransform:[UIDevice currentDevice].orientation];
        
        //每个AssetWriterInput都期望接收CMSampelBufferRef格式的数据，如果是CVPixelBuffer格式的数据，就需要通过adaptor来格式化后再写入
        NSDictionary *attributes = @{
            (__bridge NSString*)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA),
            (__bridge NSString*)kCVPixelBufferWidthKey:self.videoSettings[AVVideoWidthKey],
            (__bridge NSString*)kCVPixelBufferHeightKey:self.videoSettings[AVVideoHeightKey],
            (__bridge NSString*)kCVPixelFormatOpenGLCompatibility:@(YES),
        };
        self.pixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoInput sourcePixelBufferAttributes:attributes];
        NSURL *outputURL = [self createTemplateFileURL];
        
        NSError *error;
        self.assetWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:self.fileType error:&error];
        if (error) {
            NSLog(@"初始化AssetWriter失败");
        }
        if ([self.assetWriter canAddInput:self.videoInput]) {
            [self.assetWriter addInput:self.videoInput];
        }
        if ([self.assetWriter canAddInput:self.audioInput]) {
            [self.assetWriter addInput:self.audioInput];
        }
    }
    return self;
}

- (void)startWriting{
    dispatch_async(self.processQueue, ^{
        self.isWriting = YES;
    });
}

- (void)stopWriting{
    self.isWriting = NO;
    dispatch_async(self.processQueue, ^{
        __weak typeof(self) WeakSelf = self;
        [self.assetWriter finishWritingWithCompletionHandler:^{
            __strong typeof(self) StrongSelf = WeakSelf;
            if (!StrongSelf) {
                return ;
            }
            if (StrongSelf.assetWriter.status == AVAssetExportSessionStatusExporting) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    !StrongSelf.finishWriteCallback?:StrongSelf.finishWriteCallback(StrongSelf.assetWriter.outputURL);
                });
            }
        }];
    });
}

- (void)processImageData:(CIImage *)image atTime:(CMTime)time{
    if (!self.isWriting) {
        return;
    }
    
    if (self.firstSampleFlag) {
        //收到第一帧视频数据,开始写入
        BOOL result = self.assetWriter.startWriting;
        if (!result) {
            NSLog(@"开启录制失败");
            return;
        }
        [self.assetWriter startSessionAtSourceTime:time];
        self.firstSampleFlag = NO;
    }
    
    CVPixelBufferRef outputRenderBuffer;
    if (!self.pixelBufferAdaptor.pixelBufferPool) {
        return;
    }
    CVReturn result = CVPixelBufferPoolCreatePixelBuffer(nil, self.pixelBufferAdaptor.pixelBufferPool, &outputRenderBuffer);
    if (result != kCVReturnSuccess) {
        return;
    }
    
    [self.ciContext render:image toCVPixelBuffer:outputRenderBuffer bounds:image.extent colorSpace:CGColorSpaceCreateDeviceRGB()];
    if (self.videoInput.isReadyForMoreMediaData) {
        BOOL result = [self.pixelBufferAdaptor appendPixelBuffer:outputRenderBuffer withPresentationTime:time];
        CFRelease(outputRenderBuffer);
        if (!result) {
            NSLog(@"拼接视频数据失败");
        }
    }
}

- (void)processAudioData:(CMSampleBufferRef)buffer{
    if (self.firstSampleFlag) {
        return;
    }
    if (self.audioInput.isReadyForMoreMediaData) {
        BOOL result = [self.audioInput appendSampleBuffer:buffer];
         if (!result) {
            NSLog(@"拼接音频数据失败");
         }
    }
}

- (NSURL *)createTemplateFileURL{
    NSString *path = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),@"writeTemp.mp4"];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
   if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
       [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
   }
    return fileURL;
   }

- (CGAffineTransform)fixTransform:(UIDeviceOrientation)deviceOrientation {
    UIDeviceOrientation orientation = deviceOrientation == UIDeviceOrientationUnknown ? UIDeviceOrientationPortrait : deviceOrientation;
    CGAffineTransform result;
    
    switch (orientation) {
    case UIDeviceOrientationLandscapeRight:
            result = CGAffineTransformMakeRotation(M_PI);
        break;
    case UIDeviceOrientationPortraitUpsideDown:
        result = CGAffineTransformMakeRotation(M_PI / 2 *3);
        break;
    case UIDeviceOrientationPortrait:
    case UIDeviceOrientationFaceUp:
    case UIDeviceOrientationFaceDown:
        result =  CGAffineTransformMakeRotation(M_PI / 2);
        break;
    default:
        result = CGAffineTransformIdentity;
        break;
    }
    return result;
}

#pragma mark - lazy load
- (CIContext *)ciContext{
    if(!_ciContext){
        //因为需要实时处理图像，通过EAGL上下文来生成CIContext对象。此时，渲染的对象被保存在GPU,并且不会被拷贝到CPU内存。
        EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        _ciContext = [CIContext contextWithEAGLContext:context options:@{
            kCIContextWorkingColorSpace:[NSNull null]
        }];
    }
    return _ciContext;
}

@end
