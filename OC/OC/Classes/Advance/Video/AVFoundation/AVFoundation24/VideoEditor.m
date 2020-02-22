//
//  VideoEditor.m
//  AVFoundationDemo
//
//  Created by yier on 2020/2/19.
//  Copyright © 2020 yier. All rights reserved.
//

#import "VideoEditor.h"
#import "MBProgressHUD+LKAdditions.h"

#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface VideoEditor()<AVVideoCompositionValidationHandling>
@property(nonatomic, strong) MBProgressHUD *hud;
@end

@implementation VideoEditor

+ (instancetype)shareInstance{
    static VideoEditor *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

- (void)makeBirthdayCardFromVideoAt:(NSURL *)videoURL forName:(NSString *)name view:(UIView *)view completed:(VideoEditCompletedBlock)completedBlock{
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];

    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
    NSError *error;
    [videoCompositionTrack insertTimeRange:videoTrack.timeRange ofTrack:videoTrack atTime:kCMTimeZero error:&error];
    if (error) {
        NSLog(@"some error did happend:%@",error);
        return;
    }
    AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    [audioCompositionTrack insertTimeRange:audioTrack.timeRange ofTrack:audioTrack atTime:kCMTimeZero error:&error];
    if (error) {
           NSLog(@"some error did happend:%@",error);
           return;
       }
    
    videoCompositionTrack.preferredTransform = videoTrack.preferredTransform;
    NSArray *videoInfo = [self orientationFrom:videoTrack.preferredTransform];
    UIImageOrientation orientation = [videoInfo[0] integerValue];
    BOOL isPortrait = [videoInfo[1] boolValue];
    CGSize videoSize = videoTrack.naturalSize;
    if (isPortrait) {
        videoSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
    }
    
    CALayer *videoLayer = [CALayer layer];
    CALayer *outputLayer = [self createOutputLayer:videoSize name:name videoLayer:videoLayer];
    
    //videoCompposition
    AVMutableVideoComposition *videoComposition = [[AVMutableVideoComposition alloc] init];
    videoComposition.renderSize = videoSize;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:outputLayer];
    
    AVMutableVideoCompositionInstruction *instruction = [[AVMutableVideoCompositionInstruction alloc] init];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration);
    
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    [layerInstruction setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
    instruction.layerInstructions = @[layerInstruction];
    videoComposition.instructions = @[instruction];
    
    NSURL *documentDirectory = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *openURL = [documentDirectory URLByAppendingPathComponent:@"tmp"];
    openURL = [openURL URLByAppendingPathExtension:CFBridgingRelease(UTTypeCopyPreferredTagWithClass((CFStringRef)AVFileTypeQuickTimeMovie, kUTTagClassFilenameExtension))];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:openURL.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:openURL error:nil];
    }
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.outputURL = openURL;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.videoComposition = videoComposition;
    
    self.hud =  [MBProgressHUD lk_showRequestHUDWithMessage:@"正在导出..." inView:view];
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hud hideAnimated:YES afterDelay:0];
            [self handleExportSession:exportSession view:view  completed:completedBlock];
        });
    }];
    
    //AVMutableVideoComposition异常调试
    BOOL isValid = [videoComposition isValidForAsset:composition timeRange:CMTimeRangeMake(kCMTimeZero, composition.duration) validationDelegate:self];
    NSLog(@"AVMutableVideoComposition是否可用：%@",isValid?@"可用":@"不可用");
}

- (void)handleExportSession:(AVAssetExportSession *)session view:(UIView *)view completed:(VideoEditCompletedBlock)completedBlock{
    if (session.status == AVAssetExportSessionStatusFailed) {
        NSLog(@"%@",session.error);
        !completedBlock?:completedBlock(nil);
        return;
    }
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied || [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted) {
        NSLog(@"没有权限");
        !completedBlock?:completedBlock(nil);
        return;
    }
    
    self.hud = [MBProgressHUD lk_showRequestHUDWithMessage:@"保存中..." inView:view];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:session.outputURL];
        PHObjectPlaceholder *placeholder = [changeRequest placeholderForCreatedAsset];
        
        PHAssetCollection *collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].firstObject;
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
        
        [request addAssets:@[placeholder]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.hud hideAnimated:YES];
            if (success) {
                NSLog(@"%@",session.outputURL);
                !completedBlock?:completedBlock(session.outputURL);
                [MBProgressHUD lk_showSuccessWithStatus:@"保存成功" hideAfterDelay:1];
            }else{
                !completedBlock?:completedBlock(nil);
                [MBProgressHUD lk_showErrorWithStatus:@"保存失败" hideAfterDelay:1];
            }
        });
    }];
}

#pragma mark - 效果
- (CALayer *)createOutputLayer:(CGSize)videoSize name:(NSString *)name videoLayer:(CALayer *)videoLayer{
    CALayer *backgroundLayer = [CALayer layer];
    backgroundLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    if (!videoLayer) {
        videoLayer = [CALayer layer];
    }
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);;
    CALayer *overlayLayer = [CALayer layer];
    overlayLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);;
    
    backgroundLayer.backgroundColor = [UIColor orangeColor].CGColor;
    videoLayer.frame = CGRectMake(20, 20, videoSize.width - 40, videoSize.height - 40);
    
    backgroundLayer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"background.jpeg"].CGImage);
    backgroundLayer.contentsGravity = kCAGravityResizeAspectFill;
    [self addConfetti:overlayLayer];
    [self addImage:overlayLayer videoSize:videoSize];

    [self addText:[NSString stringWithFormat:@"Happy Birthday %@",name] toLayer:overlayLayer videoSize:videoSize];

    CALayer *outputLayer = [CALayer layer];
    outputLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [outputLayer addSublayer:backgroundLayer];
    [outputLayer addSublayer:videoLayer];
    [outputLayer addSublayer:overlayLayer];
    
    return outputLayer;
}

//添加粒子效果
- (void)addConfetti:(CALayer *)layer{
    [self snowFlake:layer];
}

- (void)addImage:(CALayer *)layer videoSize:(CGSize)size{
    UIImage *image = [UIImage imageNamed:@"overlay.png"];
    CALayer *imageLayer = [CALayer layer];
    
    CGFloat aspect = image.size.width / image.size.height;
    CGFloat width = size.width;
    CGFloat height = width/aspect;
    
    imageLayer.frame = CGRectMake(0, -height * 0.15, width, height);
    
    imageLayer.contents = (__bridge id _Nullable)(image.CGImage);
    [layer addSublayer:imageLayer];
}

- (void)addText:(NSString *)string toLayer:(CALayer *)layer videoSize:(CGSize)size{
    NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:string attributes:@{
        NSFontAttributeName:[UIFont systemFontOfSize:60],
        NSForegroundColorAttributeName:[UIColor greenColor],
        NSStrokeColorAttributeName:[UIColor whiteColor],
        NSStrokeWidthAttributeName: @(-3)
    }];
    
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = attributeText;
    textLayer.shouldRasterize = YES;
    textLayer.rasterizationScale = [UIScreen mainScreen].scale;
    textLayer.backgroundColor = [UIColor clearColor].CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    //换行
    textLayer.wrapped = YES;
    //内容不清晰
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    
    textLayer.frame = CGRectMake(0, size.height * 0.66, size.width, 150);
    [textLayer displayIfNeeded];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @0.8;
    scaleAnimation.toValue = @1.2;
    scaleAnimation.duration = 0.5;
    scaleAnimation.repeatCount = MAXFLOAT;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
   
    scaleAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
    scaleAnimation.removedOnCompletion = NO;
    [textLayer addAnimation:scaleAnimation forKey:@"scale"];
    [layer addSublayer:textLayer];
}

#pragma mark - 首先，请确保composition和资源的首选变换相同。 返回视频的方向（纵向还是横向）。 如果方向是纵向，则在检查视频尺寸时需要反转宽度和高度。 否则，您可以使用原始尺寸
/*
 为了把二维图形的变化统一在一个坐标系里，引入了齐次坐标的概念，即把一个图形用一个三维矩阵表示，其中第三列总是(0,0,1)，用来作为坐标系的标准。所以所有的变化都由前两列完成
 运算原理：原坐标设为（X,Y,1）;

                      |a    b    0|

 [X，Y,  1]      |c    d    0|     =     [aX + cY + tx  bX + dY + ty  1] ;

                      |tx    ty  1|
 
 第一种：设a=d=1, b=c=0.

 [aX + cY + tx   bX + dY + ty  1] = [X  + tx  Y + ty  1];

 可见，这个时候，坐标是按照向量（tx，ty）进行平移，其实这也就是函数

 CGAffineTransform CGAffineMakeTranslation(CGFloat tx,CGFloat ty)的计算原理。

 第二种：设b=c=tx=ty=0.

 [aX + cY + tx   bX + dY + ty  1] = [aX    dY   1];

 可见，这个时候，坐标X按照a进行缩放，Y按照d进行缩放，a，d就是X，Y的比例系数，其实这也就是函数

 CGAffineTransform CGAffineTransformMakeScale(CGFloat sx, CGFloat sy)的计算原理。a对应于sx，d对应于sy。

 第三种：设tx=ty=0，a=cosɵ，b=sinɵ，c=-sinɵ，d=cosɵ。

 [aX + cY + tx   bX + dY + ty  1] = [Xcosɵ - Ysinɵ    Xsinɵ + Ycosɵ  1] ;

 可见，这个时候，ɵ就是旋转的角度，逆时针为正，顺时针为负。其实这也就是函数

 CGAffineTransform CGAffineTransformMakeRotation(CGFloat angle)的计算原理。angle即ɵ的弧度表示。
 
 UIImageOrientation中的CW是顺时针方向旋转；CCW是反时针方向旋转
 */
- (NSArray *)orientationFrom:(CGAffineTransform)transform {
    BOOL isPortrait = NO;
    UIImageOrientation assetOrientation = UIImageOrientationUp;
    //假设up为[1,2,1]，其中X=1，Y=2
    //情况1：[0X + -Y + tx , X + ty, 1] ，tx、ty作为移动忽略 ->  [-Y, X, 1]
  if(transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0){
      assetOrientation = UIImageOrientationRight;//向右旋转90度恢复
      isPortrait = YES;
    //情况2：[Y,X,1]
  } else if (transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0) {
      assetOrientation = UIImageOrientationLeft;
      isPortrait = YES;
      //情况3：[X,Y,1];
  } else if(transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0) {
      assetOrientation = UIImageOrientationUp;
      //情况4：[-X,-Y,1]
  } else if(transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0) {
      assetOrientation = UIImageOrientationDown;
  }
  
    return @[@(assetOrientation), @(isPortrait)];
}

#pragma mark -  雪花动画,视频的坐标系需要翻转之后使用，因此发射角度也要变化
- (void)snowFlake:(CALayer *)layer{
    //粒子发射器
    CAEmitterLayer *snowEmitter = [CAEmitterLayer layer];
    //粒子发射的位置
    snowEmitter.emitterPosition = CGPointMake(layer.frame.size.width / 2, layer.frame.size.height + 5);
    //发射源的大小
    snowEmitter.emitterSize        = CGSizeMake(layer.frame.size.width, 0.0);;
    //发射模式
    snowEmitter.emitterMode        = kCAEmitterLayerOutline;
    //发射源的形状
    snowEmitter.emitterShape    = kCAEmitterLayerLine;
    
    //创建雪花粒子
    CAEmitterCell *snowflake = [CAEmitterCell emitterCell];
    //粒子的名称
    snowflake.name = @"snow";
    //粒子参数的速度乘数因子。越大出现的越快
    snowflake.birthRate        = 7.0;
    //存活时间
    snowflake.lifetime        = 12.0;
    //粒子速度
    snowflake.velocity        = 100;                // falling down slowly
    //粒子速度范围
    snowflake.velocityRange = 10;
    //粒子y方向的加速度分量
    snowflake.yAcceleration = 2;
    //指定经度,经度角代表了在x-y轴平面坐标系中与x轴之间的夹角，默认0:默认向下，M_PI_2向右，M_PI向上
    snowflake.emissionLongitude =  0;
    //指定纬度,纬度角代表了在x-z轴平面坐标系中与x轴之间的夹角，默认0:
    snowflake.emissionLatitude = 0;
    //周围发射角度
    snowflake.emissionRange = M_PI_2;        // some variation in angle
    //子旋转角度范围
    snowflake.spinRange        = M_PI_4;        // slow spin
    //粒子图片
    snowflake.contents        = (id) [[UIImage imageNamed:@"flake"] CGImage];
    //粒子颜色
    snowflake.color            = [[UIColor redColor] CGColor];
    //自旋转速度
    snowflake.spin = 4;
    //粒子透明度在生命周期内的改变速度
    snowflake.alphaSpeed = 2;
    
    //设置阴影
    snowEmitter.shadowOpacity = 1.0;
    snowEmitter.shadowRadius  = 0.0;
    snowEmitter.shadowOffset  = CGSizeMake(0.0, 1.0);
    snowEmitter.shadowColor   = [[UIColor whiteColor] CGColor];
    
    // 将粒子添加到粒子发射器上
    snowEmitter.emitterCells = [NSArray arrayWithObject:snowflake];
    [layer insertSublayer:snowEmitter atIndex:0];
}
//翻转坐标系
- (CGRect)translateRect:(CGRect)imageRect bounds:(CGRect)bounds{
   CGPoint imagePosition = imageRect.origin;
   imagePosition.y = bounds.size.height - imageRect.origin.y - imageRect.size.height;
   CGRect rect = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height);
    
    return rect;
}


#pragma mark - 烟花动画
- (void)firework:(CALayer *)layer {
    // Cells spawn in the bottom, moving up
   
    //分为3种粒子，子弹粒子，爆炸粒子，散开粒子
    CAEmitterLayer *fireworksEmitter = [CAEmitterLayer layer];
    CGRect viewBounds = layer.bounds;
    fireworksEmitter.emitterPosition = CGPointMake(viewBounds.size.width/2.0, viewBounds.size.height);
    fireworksEmitter.emitterSize    = CGSizeMake(viewBounds.size.width/2.0, 0.0);
    fireworksEmitter.emitterMode    = kCAEmitterLayerOutline;
    fireworksEmitter.emitterShape    = kCAEmitterLayerLine;
    fireworksEmitter.renderMode        = kCAEmitterLayerAdditive;
    fireworksEmitter.seed = (arc4random()%100)+1;
    
    // Create the rocket
    CAEmitterCell* rocket = [CAEmitterCell emitterCell];
    
    rocket.birthRate        = 1.0;
    rocket.emissionRange    = 0.25 * M_PI;  // some variation in angle
    rocket.velocity            = 380;
    rocket.velocityRange    = 100;
    rocket.yAcceleration    = 75;
    rocket.lifetime            = 1.02;    // we cannot set the birthrate < 1.0 for the burst
    
    //小圆球图片
    rocket.contents            = (id) [[UIImage imageNamed:@"ring"] CGImage];
    rocket.scale            = 0.2;
    rocket.color            = [[UIColor redColor] CGColor];
    rocket.greenRange        = 1.0;        // different colors
    rocket.redRange            = 1.0;
    rocket.blueRange        = 1.0;
    rocket.spinRange        = M_PI;        // slow spin
    
    
    
    // the burst object cannot be seen, but will spawn the sparks
    // we change the color here, since the sparks inherit its value
    CAEmitterCell* burst = [CAEmitterCell emitterCell];
    
    burst.birthRate            = 1.0;        // at the end of travel
    burst.velocity            = 0;        //速度为0
    burst.scale                = 2.5;      //大小
    burst.redSpeed            =-1.5;        // shifting
    burst.blueSpeed            =+1.5;        // shifting
    burst.greenSpeed        =+1.0;        // shifting
    burst.lifetime            = 0.35;     //存在时间
    
    // and finally, the sparks
    CAEmitterCell* spark = [CAEmitterCell emitterCell];
    
    spark.birthRate            = 400;
    spark.velocity            = 125;
    spark.emissionRange        = 2* M_PI;    // 360 度
    spark.yAcceleration        = 75;        // gravity
    spark.lifetime            = 3;
    //星星图片
    spark.contents            = (id) [[UIImage imageNamed:@"starOutline"] CGImage];
    spark.scaleSpeed        =-0.2;
    spark.greenSpeed        =-0.1;
    spark.redSpeed            = 0.4;
    spark.blueSpeed            =-0.1;
    spark.alphaSpeed        =-0.25;
    spark.spin                = 2* M_PI;
    spark.spinRange            = 2* M_PI;
    
    // 3种粒子组合，可以根据顺序，依次烟花弹－烟花弹粒子爆炸－爆炸散开粒子
    fireworksEmitter.emitterCells    = [NSArray arrayWithObject:rocket];
    rocket.emitterCells                = [NSArray arrayWithObject:burst];
    burst.emitterCells                = [NSArray arrayWithObject:spark];
    [layer addSublayer:fireworksEmitter];
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

@end
