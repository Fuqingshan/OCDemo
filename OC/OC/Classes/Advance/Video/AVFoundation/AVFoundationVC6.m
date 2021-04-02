//
//  AVFoundationVC6.m
//  AVFoundationDemo
//
//  Created by yier on 2020/2/10.
//  Copyright © 2020 yier. All rights reserved.
//

#import "AVFoundationVC6.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTType.h>
#import "AVFoundationVC5.h"
@interface AVFoundationVC6 ()
@property(nonatomic, strong) AVMutableComposition *mutableComposition;
@property(nonatomic, strong) AVMutableCompositionTrack *videoTrack;
@property(nonatomic, strong) AVMutableCompositionTrack *audioTrack;
@end

@implementation AVFoundationVC6

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)initData{
    [self test];
}

- (void)setupUI{
    
}

- (void)createComposition{
    self.mutableComposition = [AVMutableComposition composition];
    
    //kCMPersistentTrackID_Invalid作为首选轨道ID，则会为您自动生成唯一标识符并与轨道相关联
    self.audioTrack = [self.mutableComposition  addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    self.videoTrack = [self.mutableComposition  addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [self videoTrakcs];
    
    //将多个视频片段放置在相同的合成轨道上可能会导致视频片段之间的转换丢帧，特别是在嵌入式设备上。
     AVMutableCompositionTrack *compatibleCompositionTrack = [self.mutableComposition  mutableTrackCompatibleWithTrack:self.videoTrack];;
      if (compatibleCompositionTrack) {
          // Implementation continues.
          
      }
    
    //修改合成视频背景色
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.mutableComposition.duration);
    instruction.backgroundColor = [UIColor redColor].CGColor;
    
    
}
//将两个视频轨道添加到同一个构图轨道
- (void)videoTrakcs{

    AVAsset *asset1 = [AVAsset assetWithURL:[NSURL URLWithString:@"https://free-hls.boxueio.com/z62-asynchronous-values-in-combine.m3u8"]];
    AVAsset *asset2 = [AVAsset assetWithURL:[NSURL URLWithString:@"https://free-hls.boxueio.com/z68-relationship-delete-rules.m3u8"]];
    
    AVAssetTrack *track1 = [asset1 tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVAssetTrack *track2 = [asset2 tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    NSError *erro1;
    NSError *error2;
    [self.videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, track1.timeRange.duration) ofTrack:track1 atTime:kCMTimeZero error:&erro1];
    [self.videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, track2.timeRange.duration) ofTrack:track2 atTime:track2.timeRange.duration error:&error2];
    
}
/*
 单个AVMutableAudioMix对象可以对您单独组成的所有音轨执行自定义音频处理。您可以使用audioMix类方法创建音频混合，并使用AVMutableAudioMixInputParameters类的实例将音频混合与组合中的特定轨道相关联。 可以使用音频混合来改变音轨的音量
*/
- (void)volumeRamp{
    AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];

    // Create the audio mix input parameters object.
    AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:self.audioTrack];

    // Set the volume ramp to slowly fade the audio out over the duration of the composition.
    [mixParameters setVolumeRampFromStartVolume:1.f toEndVolume:0.f timeRange:CMTimeRangeMake(kCMTimeZero, self.mutableComposition.duration)];

    // Attach the input parameters to the audio mix.
    mutableAudioMix.inputParameters = @[mixParameters];
}

/*
 视频合成指令也可用于应用视频合成图层指令。 AVMutableVideoCompositionLayerInstruction对象可以对组合中的某个视频轨道应用变换，变换斜坡，不透明度和不透明度斜坡。 视频合成指令的layerInstructions数组中的图层指令的顺序决定了在构图指令的持续时间内，来自源轨道的视频帧应如何分层和组合。
*/
#pragma mark - 添加水印
- (void)addWatermark{
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];

    UIImage *waterImage = [UIImage imageNamed:@"AppIcon.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:waterImage];
    CALayer *watermarkLayer = imageView.layer;
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, mutableVideoComposition.renderSize.width, mutableVideoComposition.renderSize.height);
    videoLayer.frame = CGRectMake(0, 0, mutableVideoComposition.renderSize.width, mutableVideoComposition.renderSize.height);
    [parentLayer addSublayer:videoLayer];
    watermarkLayer.position = CGPointMake(mutableVideoComposition.renderSize.width/2, mutableVideoComposition.renderSize.height/4);
    [parentLayer addSublayer:watermarkLayer];
    mutableVideoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

/**如何组合两个视频资产轨道和音频资产轨道来创建单个视频文件
 
 1、创建一个AVMutableComposition对象并添加多个AVMutableCompositionTrack对象
 2、将AVAssetTrack对象的时间范围添加到兼容的组合轨道
 3、检查视频资产轨道的preferredTransform属性以确定视频的方向
 4、使用AVMutableVideoCompositionLayerInstruction对象将变换应用到合成中的视频轨道
 5、为视频构图的renderSize和frameDuration属性设置适当的值
 6、导出到视频文件时，使用组合与视频合成;将视频文件保存到相机胶卷
 */
- (void)test{
    //1、要从单独的资源组合轨道，您可以使用AVMutableComposition对象。 创建构图并添加一个音频和一个视频轨
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //这儿资源可以从相册导入或者bundle中导入，HLS不行
    AVAsset *firstVideoAsset = [AVAsset assetWithURL:[[NSBundle mainBundle] URLForResource:@"AVFoundation_hourse" withExtension:@"mp4"]];
    AVAsset *secondVideoAsset = [AVAsset assetWithURL:[[NSBundle mainBundle] URLForResource:@"AVFoundation_testMOV" withExtension:@"mov"]];
    AVAsset *audioAsset = [AVAsset assetWithURL:[[NSBundle mainBundle] URLForResource:@"AVFoundation_waiting" withExtension:@"mp3"]];
    
    //2、一个空的组合对你来说没有用。 将两个视频资产轨道和音频资产轨道添加到组合。
    //这假设您有两个资产包含至少一个视频轨道，每个资产包含至少一个音轨。 可以从相机胶卷中检索视频，并且可以从音乐库或视频本身检索音轨
    AVAssetTrack *firstVideoAssetTrack = [[firstVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVAssetTrack *secondVideoAssetTrack = [[secondVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration) ofTrack:firstVideoAssetTrack atTime:kCMTimeZero error:nil];
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondVideoAssetTrack.timeRange.duration) ofTrack:secondVideoAssetTrack atTime:firstVideoAssetTrack.timeRange.duration error:nil];
    
    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssetTrack.timeRange.duration)) ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    
    //3、将视频和音轨添加到组合中后，您需要确保两个视频轨道的方向正确。 默认情况下，所有视频轨道都假定为横向模式。 如果您的视频轨道以纵向模式拍摄，导出时视频将无法正确定向。 同样，如果您尝试将以纵向模式拍摄的视频与横向模式下的视频拍摄相结合，导出会话将无法完成。
    BOOL isFirstVideoPortrait = NO;
    CGAffineTransform firstTransform = firstVideoAssetTrack.preferredTransform;
    // Check the first video track's preferred transform to determine if it was recorded in portrait mode.
    if (firstTransform.a == 0 && firstTransform.d == 0 && (firstTransform.b == 1.0 || firstTransform.b == -1.0) && (firstTransform.c == 1.0 || firstTransform.c == -1.0)) {
        isFirstVideoPortrait = YES;
    }
    BOOL isSecondVideoPortrait = NO;
    CGAffineTransform secondTransform = secondVideoAssetTrack.preferredTransform;
    // Check the second video track's preferred transform to determine if it was recorded in portrait mode.
    if (secondTransform.a == 0 && secondTransform.d == 0 && (secondTransform.b == 1.0 || secondTransform.b == -1.0) && (secondTransform.c == 1.0 || secondTransform.c == -1.0)) {
        isSecondVideoPortrait = YES;
    }
    if ((isFirstVideoPortrait && !isSecondVideoPortrait) || (!isFirstVideoPortrait && isSecondVideoPortrait)) {
        UIAlertView *incompatibleVideoOrientationAlert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Cannot combine a video shot in portrait mode with a video shot in landscape mode." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [incompatibleVideoOrientationAlert show];
        return;
    }
    
    //4、一旦您知道视频片段具有兼容的方向，您可以对每个视频片段应用必要的图层指令，并将这些图层指令添加到视频构图。
    //所有AVAssetTrack对象都有一个preferredTransform属性，其中包含该资产轨道的方向信息。
    AVMutableVideoCompositionInstruction *firstVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];

    // Set the time range of the first instruction to span the duration of the first video track.
    firstVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration);
    AVMutableVideoCompositionInstruction * secondVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];

    // Set the time range of the second instruction to span the duration of the second video track.
    secondVideoCompositionInstruction.timeRange = CMTimeRangeMake(firstVideoAssetTrack.timeRange.duration, CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssetTrack.timeRange.duration));
    AVMutableVideoCompositionLayerInstruction *firstVideoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];

    // Set the transform of the first layer instruction to the preferred transform of the first video track.
    [firstVideoLayerInstruction setTransform:firstTransform atTime:kCMTimeZero];
    AVMutableVideoCompositionLayerInstruction *secondVideoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];

    // Set the transform of the second layer instruction to the preferred transform of the second video track.
    [secondVideoLayerInstruction setTransform:secondTransform atTime:firstVideoAssetTrack.timeRange.duration];
    firstVideoCompositionInstruction.layerInstructions = @[firstVideoLayerInstruction];
    secondVideoCompositionInstruction.layerInstructions = @[secondVideoLayerInstruction];
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.instructions = @[firstVideoCompositionInstruction, secondVideoCompositionInstruction];
        
    //5、要完成视频方向修复，您必须相应地调整renderSize属性。 您还应为frameDuration属性选择合适的值，例如1/30秒（或每秒30帧）。 默认情况下，renderScale属性设置为1.0，适用于此组合。
     CGSize naturalSizeFirst, naturalSizeSecond;
     // If the first video asset was shot in portrait mode, then so was the second one if we made it here.
     if (isFirstVideoPortrait) {
     // Invert the width and height for the video tracks to ensure that they display properly.
         naturalSizeFirst = CGSizeMake(firstVideoAssetTrack.naturalSize.height, firstVideoAssetTrack.naturalSize.width);
         naturalSizeSecond = CGSizeMake(secondVideoAssetTrack.naturalSize.height, secondVideoAssetTrack.naturalSize.width);
     }else {
     // If the videos weren't shot in portrait mode, we can just use their natural sizes.
         naturalSizeFirst = firstVideoAssetTrack.naturalSize;
         naturalSizeSecond = secondVideoAssetTrack.naturalSize;
     }
     float renderWidth, renderHeight;
     // Set the renderWidth and renderHeight to the max of the two videos widths and heights.
     if (naturalSizeFirst.width > naturalSizeSecond.width) {
         renderWidth = naturalSizeFirst.width;
     }else {
         renderWidth = naturalSizeSecond.width;
     }
     if (naturalSizeFirst.height > naturalSizeSecond.height) {
         renderHeight = naturalSizeFirst.height;
     }else {
         renderHeight = naturalSizeSecond.height;
     }
     mutableVideoComposition.renderSize = CGSizeMake(renderWidth, renderHeight);
     // Set the frame duration to an appropriate value (i.e. 30 frames per second for video).
     mutableVideoComposition.frameDuration = CMTimeMake(1,30);
    
    //6、此过程的最后一步包括将整个组合导出到单个视频文件中，并将该视频保存到相机卷。 您可以使用AVAssetExportSession对象来创建新的视频文件，并将其传递给输出文件所需的URL。 然后，您可以使用ALAssetsLibrary类将生成的视频文件保存到相机胶卷,这儿测试时到处失败了，直接弄到第5个vc播放测试
    // Create a static date formatter so we only have to initialize it once.
    static NSDateFormatter *kDateFormatter;
    if (!kDateFormatter) {
        kDateFormatter = [[NSDateFormatter alloc] init];
        kDateFormatter.dateStyle = NSDateFormatterShortStyle;
        kDateFormatter.timeStyle = NSDateFormatterShortStyle;
    }

    // Create the export session with the composition and set the preset to the highest quality.
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];

    // Set the desired output URL for the file created by the export process.
    NSURL *outputURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    outputURL = [outputURL URLByAppendingPathComponent:[kDateFormatter stringFromDate:[NSDate date]]];
    outputURL = [outputURL URLByAppendingPathExtension:CFBridgingRelease(UTTypeCopyPreferredTagWithClass((CFStringRef)AVFileTypeQuickTimeMovie, kUTTagClassFilenameExtension))];
    exporter.outputURL = outputURL;
    // Set the output file type to be a QuickTime movie.
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mutableVideoComposition;

    // Asynchronously export the composition to a video file and save this file to the camera roll once export completes.
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exporter.status == AVAssetExportSessionStatusCompleted) {
                ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
                if ([assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:exporter.outputURL]) {
                    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:exporter.outputURL completionBlock:^(NSURL *assetURL, NSError *error) {
                        if (!error) {
                            NSLog(@"导入成功");
                        }else{
                            NSLog(@"导入失败");
                        }
                    }];
                }
            }else if (exporter.status == AVAssetExportSessionStatusFailed){
                NSLog(@"导入失败：%@",exporter.error);
            }
            [self pushAVFoundation5:exporter.asset];
        });
    }];
}

- (void)pushAVFoundation5:(AVAsset *)asset{
    AVFoundationVC5 *vc = [[AVFoundationVC5 alloc] init];
    vc.defaultAsset = asset;
     [self.navigationController pushViewController:vc animated:YES];
}

@end
