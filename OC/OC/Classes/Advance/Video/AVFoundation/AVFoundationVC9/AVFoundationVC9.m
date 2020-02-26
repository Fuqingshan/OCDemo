//
//  AVFoundationVC9.m
//  OC
//
//  Created by yier on 2020/2/25.
//  Copyright © 2020 yier. All rights reserved.
//
//视频采集+滤镜
#import "AVFoundationVC9.h"
#import "CaptureManager.h"
#import "VideoWriteManager.h"
#import "CapturePreview.h"

#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface AVFoundationVC9 ()
@property(nonatomic, strong) CapturePreview *preview;
@property(nonatomic, strong) UIButton *changeFilterButton;
@property(nonatomic, strong) UIButton *captureButton;

@property(nonatomic, strong) CaptureManager *captureManager;
@property(nonatomic, strong) VideoWriteManager *videoWriteManager;

@property(nonatomic, strong) NSArray *filters;
@property(nonatomic, assign) BOOL isRecording;
@property(nonatomic, strong) NSString *currentFilter;

@end

@implementation AVFoundationVC9

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)initData{
    self.filters = @ [@"CIPhotoEffectChrome",
                       @"CIPhotoEffectFade",
                        @"CIPhotoEffectInstant",
                         @"CIPhotoEffectMono",
                          @"CIPhotoEffectNoir",
                           @"CIPhotoEffectProcess",
                      @"CIPhotoEffectTransfer"];
    self.currentFilter = @"CIPhotoEffectTonal";
    [self setupCaptureManager];
}


- (void)setupUI{
    
    self.preview = [[CapturePreview alloc] initWithFrame:self.view.bounds];
    self.preview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.preview];
    
    self.changeFilterButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 120, 30)];
    [self.changeFilterButton setTitle:@"变更滤镜" forState:UIControlStateNormal];
    [self.changeFilterButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.changeFilterButton addTarget:self action:@selector(changeFilter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.changeFilterButton];
    
    self.captureButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 700, 120, 30)];
    [self.captureButton setTitle:@"开始录制" forState:UIControlStateNormal];
    [self.captureButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.captureButton addTarget:self action:@selector(didClickCapture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.captureButton];
}

- (void)setupCaptureManager{
    __weak typeof(self) weakSelf = self;
    [self.captureManager setupSession:^(BOOL isSuccess, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
                  return ;
              }
        if (isSuccess) {
            [strongSelf.captureManager startSession];
        }
    }];
    
    
    self.captureManager.videoDataCallback = ^(CMSampleBufferRef buffer) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(buffer);
        if (!imageBuffer) {
            return ;
        }
        
        //1. 处理图像数据，输出结果为CIImage,作为后续展示和写入的基础数据
        CIImage *ciImage = [CIImage imageWithCVImageBuffer:imageBuffer];
        
        //加滤镜
        CIFilter *filter = [CIFilter filterWithName:strongSelf.currentFilter];
        [filter setValue:ciImage forKey:kCIInputImageKey];
        CIImage *finalImage= filter.outputImage;
        if (!finalImage) {
            return;
        }
        //2. 用户界面展示
        UIImage *image = [UIImage imageWithCIImage:finalImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.preview.ciImage = image;
        });
        
        //3. 保存写入文件
        [strongSelf.videoWriteManager processImageData:finalImage atTime:CMSampleBufferGetPresentationTimeStamp(buffer)];
    };
    
    self.captureManager.audioDataCallback = ^(CMSampleBufferRef buffer) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.videoWriteManager processAudioData:buffer];
    };
}

- (void)changeFilter{
    self.currentFilter = [self.filters randomObject];
}

- (void)didClickCapture{
    //未开始录制，开始录制
   if (!self.isRecording) {
       //连续拍摄多段时，每次都需要重新生成一个实例。之前的writer会因为已经完成写入，无法再次使用
       [self setupMoiveWriter];
       [self.videoWriteManager  startWriting];
       self.isRecording = YES;
       self.captureButton.selected = YES;
   }else {
       //录制中，停止录制
       [self.videoWriteManager stopWriting];
       self.isRecording = NO;
        self.captureButton.selected = NO;
   }
}

- (void)setupMoiveWriter{
      //输出视频的参数设置，如果要自定义视频分辨率，在此设置。否则可使用相应格式的推荐参数
    NSDictionary *videoSetings = [self.captureManager recommendedVideoSettingsForAssetWriter:AVFileTypeMPEG4];
    NSDictionary *audioSetings = [self.captureManager recommendedAudioSettingsForAssetWriter:AVFileTypeMPEG4];
    if (!videoSetings || !audioSetings) {
        return;
    }
    self.videoWriteManager = [[VideoWriteManager alloc] initWithVideoSettings:videoSetings audioSettings:audioSetings fileType:AVFileTypeMPEG4];
    
    //录制成功回调
    __weak typeof(self) weakSelf = self;
    self.videoWriteManager.finishWriteCallback = ^(NSURL *url) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
                  return ;
              }
        [strongSelf saveToAlbum:url complete:^{
            NSLog(@"保存成功");
        } failure:^{
            NSLog(@"保存失败");
        }];
        
    };
}

- (void)saveToAlbum:(NSURL *)url complete:(dispatch_block_t)complete failure:(dispatch_block_t)failure{
    if (!url) {
        failure();
        return;
    }
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            complete();
        }else{
            failure();
        }
    }];
}

#pragma mark - lazy load
- (CaptureManager *)captureManager{
    if(!_captureManager){
        _captureManager = [[CaptureManager alloc] init];
    }
    return _captureManager;
}

@end
