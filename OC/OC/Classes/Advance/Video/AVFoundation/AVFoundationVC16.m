//
//  AVFoundationVC16.m
//  AVFoundationDemo
//
//  Created by yier on 2020/2/13.
//  Copyright © 2020 yier. All rights reserved.
//
//播放、录制以及混合视频
//获取视频某一秒的图片
#import "AVFoundationVC16.h"
#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import "MBProgressHUD+LKAdditions.h"

typedef NS_ENUM(NSInteger,EventType){
    EventTypeSelectPlay = 0,
    EventTypeRecordSave = 1,
    EventTypeMergeVideo = 2,
};

@interface AVFoundationVC16 ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVVideoCompositionValidationHandling>
@property(nonatomic, strong) UIButton *selectAndPlayBtn;
@property(nonatomic, strong) UIButton *recordAndSaveBtn;
@property(nonatomic, strong) UIButton *mergeVideoBtn;

@property(nonatomic, assign) EventType type;

@property(nonatomic, strong) AVAsset *firstAsset;
@property(nonatomic, strong) AVAsset *secondAsset;
@property(nonatomic, strong) AVAsset *audioAsset;
@property(nonatomic, strong) MBProgressHUD *hud;

@end

@implementation AVFoundationVC16

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)initData{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"AVFoundation_testMOV" withExtension:@"mov"];
    UIImage *img = [self getImageWIthVideoURL:url atTime:2];
    NSLog(@"获取第二秒的图片:%@",img);
    
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 600)];
    imgV.image = img;
    imgV.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imgV];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imgV removeFromSuperview];
    });
}

- (void)setupUI{
    self.selectAndPlayBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 200, 30)];
    self.selectAndPlayBtn.backgroundColor = [UIColor blackColor];
    [self.selectAndPlayBtn setTitle:@"select and play" forState:UIControlStateNormal];
    [self.selectAndPlayBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.selectAndPlayBtn addTarget:self action:@selector(selectAndPlayEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.selectAndPlayBtn];
    
    self.recordAndSaveBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 200, 30)];
    self.recordAndSaveBtn.backgroundColor = [UIColor blackColor];
    [self.recordAndSaveBtn setTitle:@"record and save" forState:UIControlStateNormal];
    [self.recordAndSaveBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.recordAndSaveBtn addTarget:self action:@selector(recordAndSaveEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recordAndSaveBtn];
    
    self.mergeVideoBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 700, 200, 30)];
    self.mergeVideoBtn.backgroundColor = [UIColor blackColor];
    [self.mergeVideoBtn setTitle:@"merge video" forState:UIControlStateNormal];
    [self.mergeVideoBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.mergeVideoBtn addTarget:self action:@selector(mergeVideoEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mergeVideoBtn];
    
    for (int i = 0; i< 3; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 400 + i * 50, 200, 30)];
        btn.backgroundColor = [UIColor blackColor];
        if (i == 0) {
            [btn setTitle:@"choose asset1" forState:UIControlStateNormal];
        }else if (i == 1){
            [btn setTitle:@"choose asset2" forState:UIControlStateNormal];
        }else{
            [btn setTitle:@"choose audio" forState:UIControlStateNormal];
        }
        btn.tag = 'choo' + i;
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(chooseEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

#pragma mark - Evet
- (void)selectAndPlayEvent{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.navigationBar.tintColor = [UIColor orangeColor];
    picker.mediaTypes = @[(__bridge NSString *)kUTTypeMovie];
    picker.delegate = self;

    self.type = EventTypeSelectPlay;
    [self presentViewController:picker animated:YES completion:^{
         
    }];
}

- (void)recordAndSaveEvent{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = @[(__bridge NSString *)kUTTypeMovie];
    picker.navigationBar.tintColor = [UIColor orangeColor];
    picker.delegate = self;

    self.type = EventTypeRecordSave;
    [self presentViewController:picker animated:YES completion:^{
         
    }];
}

- (void)mergeVideoEvent{
    
    self.type = EventTypeMergeVideo;
    //1、创建AVmutableComposition ，这个将会hold AVMutableCompositionTrack
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    //2、创建两个视频轨道
    //注意：在使用AVAssetExportSession合并音视频时一定是先添加视频再添加音频。
    //注意：一般一个视频是包含一个视频轨道和一个音频轨道的，视频是h264，音频是aac
    //注意：时间标准一般以视频为准
    AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *firstVideoAssetTrack = [self.firstAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVAssetTrack *firstAudioAssetTrack = [self.firstAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    AVAssetTrack *secondAssetTrack = [self.secondAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVAssetTrack *audioAssetTrack = [self.audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    CMTime offsetTime = kCMTimeZero;
    
    NSError *error;
    [firstTrack insertTimeRange:firstVideoAssetTrack.timeRange ofTrack:firstVideoAssetTrack atTime:offsetTime error:&error];
    /*
    // 这块是裁剪,rangtime .前面的是开始时间,后面是裁剪多长 (我这裁剪的是从第二秒开始裁剪，裁剪2.55秒时长.)
    [firstTrack insertTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(2.0f, 30), CMTimeMakeWithSeconds(2.55f, 30))
                                       ofTrack:firstVideoAssetTrack
                                        atTime:kCMTimeZero
                                         error:&error];
     */
    if (error) {
        NSLog(@"Failed to load first track");
        return;
    }
    
    offsetTime = CMTimeAdd(offsetTime, firstAudioAssetTrack.timeRange.duration);
    AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [secondTrack insertTimeRange:secondAssetTrack.timeRange ofTrack:secondAssetTrack atTime:offsetTime error:&error];
    if (error) {
        NSLog(@"Failed to load second track");
        return;
    }
    
    // audio track
    AVMutableCompositionTrack *firstAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
      [firstAudioTrack insertTimeRange:firstAudioAssetTrack.timeRange ofTrack:firstAudioAssetTrack atTime:kCMTimeZero error:&error];
      if (error) {
          NSLog(@"Failed to load firstAudio track");
          return;
      }
    
   AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
   [audioTrack insertTimeRange:audioAssetTrack.timeRange ofTrack:audioAssetTrack atTime:offsetTime error:&error];
   if (error) {
       NSLog(@"Failed to load audio track");
       return;
   }
    /**
     AVMutableVideoComposition: 用来生成video的组合指令，包含多段instruction。可以决定最终视频的尺寸，裁剪需要在这里进行 视频效果集合(转场、水印等)
     AVMutableVideoCompositionInstruction: 一个指令，决定一个timeRange内每个轨道的状态，包含多个layerInstruction
     AVMutableVideoCompositionLayerInstruction: 视频显示layer层效果 需要添加到AVMutableVideoCompositionInstruction
     */
    
    //3、AVMutableVideoCompositionInstruction
    AVMutableVideoComposition *mainComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:mixComposition];
    
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(offsetTime, secondAssetTrack.timeRange.duration));
    mainComposition.frameDuration = CMTimeMake(1, 30);
    CGSize size = [UIScreen mainScreen].bounds.size;
    mainComposition.renderSize = CGSizeMake(size.width, size.height);
    
    AVMutableVideoCompositionLayerInstruction *firstInstruction = [self videoCompositionInstruction:firstTrack asset:self.firstAsset];
    AVMutableVideoCompositionLayerInstruction *secondInstruction = [self videoCompositionInstruction:secondTrack asset:self.secondAsset];
    //转场动画
    //第一个视频播放完成时设置为透明
    CMTimeRange transformDuration = CMTimeRangeMake(firstVideoAssetTrack.timeRange.duration, CMTimeMake(2, 1));
    [firstInstruction setOpacityRampFromStartOpacity:1 toEndOpacity:0 timeRange:transformDuration];
    [secondInstruction setOpacityRampFromStartOpacity:0 toEndOpacity:1 timeRange:transformDuration];
    
    //这两个视频本身尺寸有差距，做动画看着很怪异
//    CGFloat videoWidth = mainComposition.renderSize.width;
//    [firstInstruction setTransformRampFromStartTransform:CGAffineTransformIdentity toEndTransform:CGAffineTransformMakeTranslation(-videoWidth, 0) timeRange:transformDuration];
//    [secondInstruction setTransformRampFromStartTransform:CGAffineTransformMakeTranslation(videoWidth, 0) toEndTransform:CGAffineTransformIdentity timeRange:transformDuration];
    
    mainInstruction.layerInstructions = @[firstInstruction,secondInstruction];
    
    mainComposition.instructions = @[mainInstruction];

    
    //4、get path
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateIntervalFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    //2种设置导出路径都可以，第二种注意要用fileURLWithPath
    NSURL *documentDirectory = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *outputURL = [documentDirectory URLByAppendingPathComponent:[dateFormatter stringFromDate:[NSDate date]]];
    outputURL = [outputURL URLByAppendingPathExtension:CFBridgingRelease(UTTypeCopyPreferredTagWithClass((CFStringRef)AVFileTypeQuickTimeMovie, kUTTagClassFilenameExtension))];
    
//    NSString *outputPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"av1.mov"];
//    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputURL.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    }
    
    //5、Create Exporter
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    //选择一个格式导出，exporter.supportedFileTypes也可以用来判断支持哪些导出格式
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    // 网络优化？,默认为no
    exportSession.shouldOptimizeForNetworkUse = YES;
    // 视频处理 AVVideoComposition AVMutableVideoComposition
    exportSession.videoComposition = mainComposition;
    
    // 文件大小限制
    //    exportSession.fileLengthLimit = 1024 * 1024 * 1024;
    // 时间限制
    exportSession.timeRange = CMTimeRangeMake(CMTimeMake(0, 0), CMTimeMake(1, 1));
    
    // AVMetadataItem 元数据
    exportSession.metadata = nil;
    // AVMetadataItemFilter 过滤器
    exportSession.metadataItemFilter = nil;
    // AVAudioMix 音频处理
    exportSession.audioMix = nil;
    // 时间距算法
    exportSession.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmSpectral;
    
    // AVVideoCompositing 协议和相关类，让你可以自定义视频的合成排版
    NSLog(@"customVideoCompositor:%@", exportSession.customVideoCompositor);
    
    // 默认为no ， 设置为yes 的时候，质量更高,
    exportSession.canPerformMultiplePassesOverSourceMediaData = NO;
    // 缓存地址， canPerformMultiplePassesOverSourceMediaData为yes需要用到
    exportSession.directoryForTemporaryFiles = nil;
    
    //兼容性判断
//    [self judge:mixComposition exportSession:exportSession];

    self.hud = [MBProgressHUD lk_showRequestHUDWithMessage:@"导出中..." inView:self.view];
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hud hideAnimated:YES];
            [self exportFinished:exportSession];
        });
    }];
    
    
    // 取消
    //    [exportSession cancelExport];
       
   // 最大时间
   CMTimeShow(exportSession.maxDuration);
   // AVAssetExportSessionStatusFailed or AVAssetExportSessionStatusCancelled.    exportSession.error;
   
   // 进度
   NSLog(@"进度：%lf", exportSession.progress);
   // 状态 AVAssetExportSessionStatus
   NSLog(@"状态：%ld", exportSession.status);
    
    //AVMutableVideoComposition异常调试
    BOOL isValid = [mainComposition isValidForAsset:mixComposition timeRange:CMTimeRangeMake(kCMTimeZero, mixComposition.duration) validationDelegate:self];
    NSLog(@"AVMutableVideoComposition是否可用：%@",isValid?@"可用":@"不可用");
}

- (void)judge:(AVAsset *)asset exportSession:(AVAssetExportSession *)exportSession{
    // 所有的 presetName
    NSLog(@"所有的presetName：%@", [AVAssetExportSession allExportPresets]);

     // 可以使用的 presetName
    NSLog(@"可以使用presetName：%@", [AVAssetExportSession exportPresetsCompatibleWithAsset:asset]);

    // 判断兼容性,用户判断AVAssetExportSession是否能够成功输出转换的视音频文件
    [AVAssetExportSession determineCompatibilityOfExportPreset:AVAssetExportPresetHighestQuality withAsset:asset outputFileType:AVFileTypeQuickTimeMovie completionHandler:^(BOOL compatible) {
        NSLog(@"兼容性：%d", compatible);
     }];

    // 确定可以使用的文件类型
    [exportSession determineCompatibleFileTypesWithCompletionHandler:^(NSArray* _Nonnull compatibleFileTypes) {
        NSLog(@"可以使用的文件类型：%@", compatibleFileTypes);
    }];
}

- (void)chooseEvent:(UIButton *)btn{
    long i = btn.tag - 'choo';
    if (i == 0) {
        //asset1
        [self loadAssetOne];
        
    }else if(i == 1){
        //asset2
        [self loadAssetTwo];
    }else{
        //audio
        [self loadAudio];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if (![mediaType isEqualToString:(__bridge NSString *)kUTTypeMovie]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    NSURL *videoURL = (NSURL *)info[UIImagePickerControllerMediaURL];
    if(!videoURL){
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    switch (self.type) {
        case EventTypeSelectPlay:
        {
            [picker dismissViewControllerAnimated:YES completion:^{
                AVPlayer *player = [AVPlayer playerWithURL:videoURL];
                AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
                vc.player = player;
                [self presentViewController:vc animated:YES completion:^{
                    if ([vc isReadyForDisplay]) {
                        [player play];
                    }
                }];
            }];
        }
            break;
        case EventTypeRecordSave:
            {
                [picker dismissViewControllerAnimated:YES completion:^{
                    UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                }];
            }
            break;
        case EventTypeMergeVideo:
            {
                
            }
            break;
    }
    

}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *title = !error?@"success":@"error";
    NSString *message = !error?@"save success":@"video failed to save";
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
  
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - UINavigationControllerDelegate

#pragma mark - MergeAndExport
/*保存的逆时针旋转了90度，再转回来setPreferredTransform

 AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
  AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
 AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videosPathArray[i]]];
 AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
                                                                         preferredTrackID:kCMPersistentTrackID_Invalid];
 [videoTrack setPreferredTransform:assetVideoTrack.preferredTransform];
 */
- (void)exportFinished:(AVAssetExportSession *)session{
    
    /*AVFoundationErrorDomain
     路径错误，输入或者输出路径改为新地址(-11822):"Cannot Open","The operation couldn’t be completed. (OSStatus error -12413.)", NSLocalizedFailureReason=This media format is not supported.
     路径重复，输出路径已经存在文件，删除输出路径下文件或者修改输出文件路径(-11823):@"Cannot save","Try saving again., NSLocalizedDescription=Cannot Save, NSUnderlyingError=0x1d464a7d0 {Error Domain=NSOSStatusErrorDomain Code=-12101 "(null)"
     -11841：You attempted to perform a video composition operation that is not supported.（导出时，exportSession.videoComposition非常重要，出错了就会报这个 \
     常见的是AVMutableVideoCompositionInstruction的timeRange出错，可以设置AVVideoCompositionValidationHandling调试）
     */
    if (session.status != AVAssetExportSessionStatusCompleted) {
        NSLog(@"失败：%@",session.error);
        return;
    }
    
    //判断是否有相册权限
    PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];
    if (authorStatus == PHAuthorizationStatusRestricted || authorStatus == PHAuthorizationStatusDenied) {
        NSString *errorStr = @"没有使用相册权限，请在设置中打开";
        [self showAlertViewWithMessage:errorStr];
        return;
    }
    
    self.hud = [MBProgressHUD lk_showRequestHUDWithMessage:@"写入中..." inView:self.view];
     [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *changeAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:session.outputURL];
           PHObjectPlaceholder *assetPlaceholder = [changeAssetRequest placeholderForCreatedAsset];

           PHAssetCollection *collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
           PHAssetCollectionChangeRequest *changeCollectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
           [changeCollectionRequest addAssets:@[assetPlaceholder]];
       } completionHandler:^(BOOL success, NSError * _Nullable error) {
           dispatch_async(dispatch_get_main_queue(), ^{
               [self.hud hideAnimated:YES];
               if (!success) {
                     NSLog(@"保存视频失败:%@",error);
                 }else{
                     NSLog(@"保存视频到相册成功");
                 }
           });
       }];
}

- (void)showAlertViewWithMessage:(NSString *)message
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ensureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertVC addAction:ensureAction];
    [alertVC addAction:cancelAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)loadAssetOne{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"AVFoundation_testMOV" withExtension:@"mov"];
    self.firstAsset = [AVAsset assetWithURL:url];
    NSLog(@"first load");
}

- (void)loadAssetTwo{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"AVFoundation_hourse" withExtension:@"mp4"];
    self.secondAsset = [AVAsset assetWithURL:url];
    NSLog(@"second load");
}

- (void)loadAudio{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"AVFoundation_waiting" withExtension:@"mp3"];
    self.audioAsset = [AVAsset assetWithURL:url];
    NSLog(@"audio load");
}

#pragma mark - create Instruction
- (AVMutableVideoCompositionLayerInstruction *)videoCompositionInstruction:(AVCompositionTrack *)track asset:(AVAsset *)asset{
    AVMutableVideoCompositionLayerInstruction *instruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:track];
    AVAssetTrack *assetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    CGAffineTransform transform =  assetTrack.preferredTransform;
    NSArray *assetInfo = [self orientationFromTransform:transform];
    UIImageOrientation assetOrientation = [assetInfo.firstObject integerValue];
    BOOL isPortrait = [assetInfo[1] boolValue];
    
    /*视频正面朝上所需的仿射变换
     如果视频是纵向的，则需要重新计算比例因子，因为默认计算适用于横向视频。然后，您需要做的就是应用方向旋转和缩放变换。
     如果视频是横向视图，则应用缩放和变换的步骤类似。有一个额外的检查，因为视频可以在landscape left或landscape right中生成。因为有“两个landscape”，宽高比会进行匹配，但视频可能会旋转180度。额外检查.Down的视频方向将处理此种情况
     */
    CGFloat scaleToFitRatio = [UIScreen mainScreen].bounds.size.width / assetTrack.naturalSize.width;
    if (isPortrait) {
        scaleToFitRatio = [UIScreen mainScreen].bounds.size.width / assetTrack.naturalSize.height;
        CGAffineTransform scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio);
        [instruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor) atTime:kCMTimeZero];
    }else{
        CGAffineTransform scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio);
        CGAffineTransform concat = CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor);
        concat = CGAffineTransformConcat(concat, CGAffineTransformMakeTranslation(0, [UIScreen mainScreen].bounds.size.width / 2));
        if (assetOrientation == UIImageOrientationDown) {
            CGAffineTransform fixUpsideDown = CGAffineTransformMakeRotation(M_PI);
            CGRect windowBounds = [UIScreen mainScreen].bounds;
            CGFloat yFix = assetTrack.naturalSize.height + windowBounds.size.height;
            CGAffineTransform centerFix = CGAffineTransformMakeTranslation(assetTrack.naturalSize.width, yFix);
            concat = CGAffineTransformConcat(CGAffineTransformConcat(fixUpsideDown, centerFix), scaleFactor);
        }
        [instruction setTransform:concat atTime:kCMTimeZero];
    }
    
    return instruction;
}

- (NSArray *)orientationFromTransform:(CGAffineTransform)transform {
    UIImageOrientation assetOrientation = UIImageOrientationUp;
    BOOL isPortrait = NO;
    if (transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0.0) {
        assetOrientation = UIImageOrientationRight;
        isPortrait = YES;
    }else if (transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0) {
        assetOrientation = UIImageOrientationLeft;
        isPortrait = YES;
    } else if (transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0) {
        assetOrientation = UIImageOrientationUp;
    } else if (transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0) {
        assetOrientation = UIImageOrientationDown;
    }
    
    return @[@(assetOrientation),@(isPortrait)];
}

#pragma mark - AVVideoCompositionValidationHandling
- (BOOL)videoComposition:(AVVideoComposition *)videoComposition shouldContinueValidatingAfterFindingInvalidValueForKey:(NSString *)key
{
    NSLog(@"%s===%@",__func__,key);
    return YES;
}

- (BOOL)videoComposition:(AVVideoComposition *)videoComposition shouldContinueValidatingAfterFindingEmptyTimeRange:(CMTimeRange)timeRange
{
    NSLog(@"%s===%@",__func__,CFBridgingRelease(CMTimeRangeCopyDescription(kCFAllocatorDefault, timeRange)));
    return YES;
}

- (BOOL)videoComposition:(AVVideoComposition *)videoComposition shouldContinueValidatingAfterFindingInvalidTimeRangeInInstruction:(id<AVVideoCompositionInstruction>)videoCompositionInstruction
{
    NSLog(@"%s===%@",__func__,videoCompositionInstruction);
    return YES;
}

- (BOOL)videoComposition:(AVVideoComposition *)videoComposition shouldContinueValidatingAfterFindingInvalidTrackIDInInstruction:(id<AVVideoCompositionInstruction>)videoCompositionInstruction layerInstruction:(AVVideoCompositionLayerInstruction *)layerInstruction asset:(AVAsset *)asset
{
    NSLog(@"%s===%@===%@",__func__,layerInstruction,asset);
    return YES;
}

#pragma mark - 获取视频某一帧的图片
- (UIImage *)getImageWIthVideoURL:(NSURL *)videoURL atTime:(NSTimeInterval)second{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    //设置容忍度，如果不设置，那么在获取某一帧的时候，系统会在某一个范围内查找，如果有缓存或者索引内的关键帧，它会优先返回，优化性能。
    assetImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    assetImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    
    //获取视频帧率
    CGFloat fps =  [asset tracksWithMediaType:AVMediaTypeVideo].firstObject.nominalFrameRate;
    CMTime resultTime = CMTimeMakeWithSeconds(second, fps);
    
    NSError *error;
    CMTime actualTime;
    CGImageRef image = [assetImageGenerator copyCGImageAtTime:resultTime actualTime:&actualTime error:&error];
    
    NSLog(@"这是真实的时间:");
    CMTimeShow(actualTime);
    
    if (!image){
        NSLog(@"thumbnailImageGenerationError %@", error);
        return nil;
    }
    
    UIImage *thumbnailImage = [UIImage imageWithCGImage:image];
    CFRelease(image);
    
    return thumbnailImage;
}

//获取视频总时长
- (NSInteger )getVideoAllTimeWith:(NSURL *)url
{
    NSDictionary *opts = @{
        AVURLAssetPreferPreciseDurationAndTimingKey:@(NO)
    };
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];  // 初始化视频媒体文件
    NSInteger second = floor(urlAsset.duration.value / urlAsset.duration.timescale); // 获取视频总时长,单位秒

    return second;
}

@end
