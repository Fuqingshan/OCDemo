//
//  AVFoundationVC7.m
//  AVFoundationDemo
//
//  Created by yier on 2020/2/11.
//  Copyright © 2020 yier. All rights reserved.
//
//转场动画
#import "AVFoundationVC7.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "MBProgressHUD+LKAdditions.h"

typedef NS_ENUM(NSInteger,kTransitionType) {
    kTransitionTypeDissolve,///<溶解效果
    kTransitionTypePush,
    kTransitionTypeCropRectangle,///<向四角擦除←↕→
    kTransitionTypeUpAndDownToMiddleTransform,///<上下到中间合成
    kTransitionTypeMiddleTransform,///<回
};

@interface AVFoundationVC7 ()<AVVideoCompositionValidationHandling>
@property(nonatomic, strong) NSMutableArray<AVAsset *> *videos;
@property(nonatomic, strong) AVMutableComposition *composition;
@property(nonatomic, strong) AVMutableVideoComposition *videoComposition;
@property(nonatomic, strong) CALayer *overLayer;

@property(nonatomic, strong) NSArray *videoTracks;

@property(nonatomic, strong) MBProgressHUD *hud;
@end

@implementation AVFoundationVC7

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)initData{
    //加载bundle中的视频
    for (NSInteger i = 0 ; i< 5; i++) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"AV7_%zd",i+1] withExtension:@"mp4"];
        AVAsset *asset = [AVAsset assetWithURL:url];
        [self.videos addObject:asset];
    }
    //构建视频轨道
    [self buildCompositionVideoTracks];
    //构建音频轨道
    [self buildCompositionAudioTracks];
    //设置视频效果
    [self buildVideoComposition];
    //添加贴纸效果
    [self buildOverLayer];
    [self export];
    
}
#pragma mark - 构建视频轨道
- (void)buildCompositionVideoTracks{
    //使用invalid，系统会自动分配一个有效的trackId
    CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;
     //创建AB两条视频轨道，视频片段交叉插入到轨道中，通过对两条轨道的叠加编辑各种效果。如0-5秒内，A轨道内容alpha逐渐到0，B轨道内容alpha逐渐到1
    AVMutableCompositionTrack *trackA = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:trackID];
    AVMutableCompositionTrack *trackB = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:trackID];
    NSArray *videoTracks = @[trackA,trackB];
    self.videoTracks = videoTracks;
    
    //视频片段插入时间轴时的起始点
    CMTime cursorTime = kCMTimeZero;
    
    //转场动画时间
    CMTime transitionDuration = CMTimeMake(2, 1);
    
    NSInteger index = 0;
    for (AVAsset *asset in self.videos) {
        //交叉循环A，B轨道
        NSInteger trackIndex = index % 2;
        AVMutableCompositionTrack *currentTrack = videoTracks[trackIndex];
        //获取视频资源中的视频轨道
        AVAssetTrack *assetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        //插入提取的视频轨道到 空白(编辑)轨道的指定位置中
        [currentTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack atTime:cursorTime error:nil];
        //光标移动到视频末尾处，以便插入下一段视频
        cursorTime = CMTimeAdd(cursorTime, asset.duration);
        //光标回退转场动画时长的距离，这一段前后视频重叠部分组合成转场动画
        cursorTime = CMTimeSubtract(cursorTime, transitionDuration);
        index++;
    }
}

#pragma mark - 构建音频轨道
- (void)buildCompositionAudioTracks{
    //使用invalid，系统会自动分配一个有效的trackId
    CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;
    AVMutableCompositionTrack *trackAudio = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:trackID];
    
    CMTime cursorTime = kCMTimeZero;
    for (AVAsset *asset in self.videos) {
        //获取视频资源中的音频轨道
        AVAssetTrack *assetTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
        //插入提取的视频轨道到 空白(编辑)轨道的指定位置中
        [trackAudio insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack atTime:cursorTime error:nil];
        //光标移动到视频末尾处，以便插入下一段视频
        cursorTime = CMTimeAdd(cursorTime, asset.duration);
    }
    
}

#pragma mark - 设置视频效果，设置videoComposition来描述A、B轨道该如何显示
- (void)buildVideoComposition{
    //创建默认配置的videoComposition
    self.videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:self.composition];
    [self filterTransitionInstructions:self.videoComposition];
}

#pragma mark - 过滤出转场动画指定
- (void)filterTransitionInstructions:(AVMutableVideoComposition *)videoComposition{
    NSArray<AVMutableVideoCompositionInstruction *> *instructions = (NSArray<AVMutableVideoCompositionInstruction *> *)videoComposition.instructions;
    NSInteger index = 0;
    for (AVMutableVideoCompositionInstruction *instruct in instructions) {
        //非转场动画区域只有单轨道(另一个的空的)，只有两个轨道重叠的情况是我们要处理的转场区域
        if (instruct.layerInstructions.count <= 1) {
            index++;
            continue;
        }
         //需要判断转场动画是从A轨道到B轨道，还是B-A
        AVMutableVideoCompositionLayerInstruction *fromLayerInstruction;
        AVMutableVideoCompositionLayerInstruction *toLayerInstruction;
        //获取前一段画面的轨道id
        CMPersistentTrackID beforeTrackId = [instructions[index - 1] layerInstructions].firstObject.trackID;
        //跟前一段画面同一轨道的为转场起点，另一轨道为终点
        CMPersistentTrackID tempTrackId = instruct.layerInstructions.firstObject.trackID;
        BOOL isBegin = NO;
        if (beforeTrackId == tempTrackId) {
            fromLayerInstruction = (AVMutableVideoCompositionLayerInstruction *)instruct.layerInstructions[0];
            toLayerInstruction = (AVMutableVideoCompositionLayerInstruction *)instruct.layerInstructions[1];
            isBegin = YES;
        }else{
            fromLayerInstruction = (AVMutableVideoCompositionLayerInstruction *)instruct.layerInstructions[1];
            toLayerInstruction = (AVMutableVideoCompositionLayerInstruction *)instruct.layerInstructions[0];
            isBegin = NO;
        }
        [self setupTransition:instruct fromLayer:fromLayerInstruction toLayer:toLayerInstruction type:kTransitionTypeMiddleTransform isBegin:isBegin];
        index++;
    }
}

#pragma mark - 设置转场动画
- (void)setupTransition:(AVMutableVideoCompositionInstruction *)instruction
              fromLayer:(AVMutableVideoCompositionLayerInstruction *)fromLayer
                toLayer:(AVMutableVideoCompositionLayerInstruction *) toLayer
                   type:(kTransitionType)type
                isBegin:(BOOL)isBegin{
    CGAffineTransform identityTransform = CGAffineTransformIdentity;
    CMTimeRange timeRange = instruction.timeRange;
    CGFloat videoWidth = self.videoComposition.renderSize.width;
    //instruction.layerInstructions设置时，把需要做效果的layer放在数组的前面
    switch (type) {
        case kTransitionTypeDissolve:
        {
           [fromLayer setOpacityRampFromStartOpacity:1 toEndOpacity:0 timeRange:timeRange];
            //重新赋值
            instruction.layerInstructions = @[fromLayer,toLayer];
        }
            break;
        case kTransitionTypePush:
        {
            CGAffineTransform fromEndTranform = CGAffineTransformMakeTranslation(-videoWidth, 0);
           CGAffineTransform toStartTranform = CGAffineTransformMakeTranslation(videoWidth, 0);
           [fromLayer setTransformRampFromStartTransform:identityTransform toEndTransform:fromEndTranform timeRange:timeRange];
           [toLayer setTransformRampFromStartTransform:toStartTranform toEndTransform:identityTransform timeRange:timeRange];
            //重新赋值
            instruction.layerInstructions = @[fromLayer,toLayer];
        }
            break;
        case kTransitionTypeCropRectangle:
        {
            AVMutableCompositionTrack *compositionVideoTrack = isBegin? self.videoTracks[0] : self.videoTracks[1];
            CGFloat videoWidth = compositionVideoTrack.naturalSize.width;
            CGFloat videoHeight = compositionVideoTrack.naturalSize.height;
            
            AVMutableVideoCompositionLayerInstruction *fromLayerRightup = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
            AVMutableVideoCompositionLayerInstruction *fromLayerLeftup = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
            AVMutableVideoCompositionLayerInstruction *fromLayerLeftDown = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
            
            //右下
            CGRect startRect = CGRectMake(videoWidth/2.0, videoHeight/2.0, videoWidth/2.0, videoHeight/2.0);
            CGRect endRect = CGRectMake(videoWidth, videoHeight, 0.0f, 0.0f);
            //通过裁剪实现擦除
            [fromLayer setCropRectangleRampFromStartCropRectangle:startRect toEndCropRectangle:endRect timeRange:timeRange];
            //右上
           startRect = CGRectMake(videoWidth/2.0, 0, videoWidth/2.0, videoHeight/2.0);
           endRect = CGRectMake(videoWidth, 0.0f, 0.0f, 0.0f);
           //通过裁剪实现擦除
           [fromLayerRightup setCropRectangleRampFromStartCropRectangle:startRect toEndCropRectangle:endRect timeRange:timeRange];
           //左上
           startRect = CGRectMake(0, 0, videoWidth/2.0, videoHeight/2.0);
           endRect = CGRectZero;
           //通过裁剪实现擦除
           [fromLayerLeftup setCropRectangleRampFromStartCropRectangle:startRect toEndCropRectangle:endRect timeRange:timeRange];
           //左上
           startRect = CGRectMake(0, videoHeight/2.0, videoWidth/2.0, videoHeight/2.0);
           endRect = CGRectMake(0, videoHeight, 0.0f, 0.0f);
           //通过裁剪实现擦除
           [fromLayerLeftDown setCropRectangleRampFromStartCropRectangle:startRect toEndCropRectangle:endRect timeRange:timeRange];
            
            //比如这儿就把做四角的重叠部分的第一个layer放前面
            instruction.layerInstructions = @[fromLayer,fromLayerRightup,fromLayerLeftup,fromLayerLeftDown,toLayer];
        }
            break;
        case kTransitionTypeUpAndDownToMiddleTransform:
        {
            
            [fromLayer setOpacityRampFromStartOpacity:1.0 toEndOpacity:0.0 timeRange:timeRange];
            //isBegin，如果是起点，则1是下一个视频源
            AVMutableCompositionTrack *nextcompositionVideoTrack = isBegin? self.videoTracks[1]: self.videoTracks[0];
            CGFloat videoWidth = nextcompositionVideoTrack.naturalSize.width;
            CGFloat videoHeight = nextcompositionVideoTrack.naturalSize.height;
                       
           AVMutableVideoCompositionLayerInstruction *toLayerUp = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:nextcompositionVideoTrack];
           AVMutableVideoCompositionLayerInstruction *toLayerDown = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:nextcompositionVideoTrack];
           
           [toLayerUp setCropRectangle:CGRectMake(0, 0, videoWidth, videoHeight/2.0) atTime:kCMTimeZero];
           [toLayerUp setTransformRampFromStartTransform:CGAffineTransformMakeTranslation(0, -videoHeight/2.0) toEndTransform:CGAffineTransformIdentity timeRange:timeRange];
           
           [toLayerDown setCropRectangle:CGRectMake(0.0, videoHeight/2.0, videoWidth, videoHeight/2.0) atTime:kCMTimeZero];
           [toLayerDown setTransformRampFromStartTransform:CGAffineTransformMakeTranslation(0, videoHeight/2.0) toEndTransform:CGAffineTransformIdentity timeRange:timeRange];
           
            //这儿把下一个视频的layer 放前面
            instruction.layerInstructions = @[toLayerUp,toLayerDown,fromLayer];
        }
            break;
        case kTransitionTypeMiddleTransform:
        {
            
            CGFloat videoHeight = self.videoComposition.renderSize.height;

            CGAffineTransform scaleT = CGAffineTransformMakeScale(0.001, 0.001);
            CGAffineTransform transform = CGAffineTransformTranslate(scaleT, videoWidth*500,videoHeight*500);
            [fromLayer setTransformRampFromStartTransform:CGAffineTransformIdentity toEndTransform:transform timeRange:timeRange];

            instruction.layerInstructions = @[fromLayer,toLayer];
        }
            break;
    }

}

#pragma mark - 添加贴纸效果
- (void)buildOverLayer{
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 40, 40);
    layer.opacity = 0;
    layer.backgroundColor = [UIColor yellowColor].CGColor;
    
    CAKeyframeAnimation *fadeInFadeOutAni = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    fadeInFadeOutAni.values = @[@0.0,@1.0,@1.0,@0.0];
    fadeInFadeOutAni.keyTimes = @[@0.0,@0.25,@0.75,@1];
   //动画时间与时间轴时间绑定
    fadeInFadeOutAni.beginTime = CMTimeGetSeconds(CMTimeMakeWithSeconds(3, 1));
    fadeInFadeOutAni.duration = CMTimeGetSeconds(CMTimeMakeWithSeconds(5, 1));
    fadeInFadeOutAni.removedOnCompletion = NO;
   
    [layer addAnimation:fadeInFadeOutAni forKey:nil];
    self.overLayer = layer;
}

#pragma mark - 导出合成视频
- (void)export{
    if (self.overLayer) {
        CALayer *videoLayer = [CALayer layer];
        videoLayer.frame = CGRectMake(0, 0, 1280, 720);
        CALayer *animateLayer = [CALayer layer];
        animateLayer.frame = CGRectMake(0, 0, 1280, 720);
        //videoLayer必须在animateLayer层级中
        [animateLayer addSublayer:videoLayer];
        [animateLayer addSublayer:self.overLayer];
        //该层及其子层的几何形状是否垂直翻转
        animateLayer.geometryFlipped = YES;
        AVVideoCompositionCoreAnimationTool *animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:animateLayer];
        self.videoComposition.animationTool = animationTool;
    }
    
    NSString *outputPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"composition.mp4"];
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputURL.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    }
    
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:self.composition.copy presetName:AVAssetExportPreset640x480];

    session.outputURL = outputURL;
    session.outputFileType = AVFileTypeMPEG4;
    session.shouldOptimizeForNetworkUse = YES;
    session.videoComposition = self.videoComposition;
    self.hud = [MBProgressHUD lk_showRequestHUDWithMessage:@"导出中..." inView:self.view];
     [session exportAsynchronouslyWithCompletionHandler:^{
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.hud hideAnimated:YES];
             [self exportFinished:session];
         });
     }];
    
    BOOL isValid = [self.videoComposition isValidForAsset:self.composition timeRange:CMTimeRangeMake(kCMTimeZero, self.composition.duration) validationDelegate:self];
    NSLog(@"AVMutableVideoComposition是否可用：%@",isValid?@"可用":@"不可用");
}

- (void)exportFinished:(AVAssetExportSession *)session{

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

- (void)setupUI{
    
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

#pragma mark - lazy load
- (AVMutableComposition *)composition{
    if(!_composition){
        _composition = [AVMutableComposition composition];
    }
    return _composition;
}

- (NSMutableArray *)videos{
    if(!_videos){
        _videos = [[NSMutableArray alloc] init];
    }
    return _videos;
}

@end
