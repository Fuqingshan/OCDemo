//
//  UploadGarageBandViewController.m
//  OC
//
//  Created by yier on 2021/4/6.
//  Copyright © 2021 yier. All rights reserved.
//

//这只是个分享到库乐队的样式，如果要做的好看点，可以参考"手机铃声制作"app的UI
#import "UploadGarageBandViewController.h"

#import "ExtAudioConverter.h"
#import "OCAudioPlayer.h"
#import "MBProgressHUD+LKAdditions.h"

#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface GarageBandManager: NSObject
/**
 库乐队的一个基础文件
 */
@property (nonatomic, copy) NSString* bandfolder;
/**
 生成好的库乐队band文件所在文件夹
 */
@property (nonatomic, copy) NSString* bandfolderDirectory;

@end

@implementation GarageBandManager

+ (instancetype)shareInstance{
    static GarageBandManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configGarageBandDirectory];
    }
    return self;
}

- (void)configGarageBandDirectory
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    
    self.bandfolder = [path stringByAppendingPathComponent:@"bandfolder"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.bandfolder]) {
        NSError *err;
        BOOL success = [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"bandfolder.band" ofType:nil] toPath:self.bandfolder error:&err];
        if (!success) {
            NSLog(@"创建存储garageband文件失败:%@", err);
            return;
        }
    }
    
    self.bandfolderDirectory = [path stringByAppendingPathComponent:@"bandfolderDirectory"];
   
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.bandfolderDirectory isDirectory:&isDirectory])
    {
        NSError *err;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:self.bandfolderDirectory withIntermediateDirectories:YES attributes:nil error:&err];
        if (!success) {
            NSLog(@"创建存储garageband转换文件的文件夹失败:%@", err);
            return;
        }
    }
}

@end

@interface UploadGarageBandViewController ()
@property (weak, nonatomic) IBOutlet UITextField *beginTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTextField;
@property (weak, nonatomic) IBOutlet UIButton *exportBtn;

@property(nonatomic, strong) MBProgressHUD *hud;

@property(nonatomic, copy) NSString *filePath;
@property(nonatomic, strong) AVAsset *audioAsset;
@property(nonatomic, assign) CGFloat maxTime;
@property(nonatomic, assign) CMTimeScale scale;

@property(nonatomic, assign) CMTime beginTime;
@property(nonatomic, assign) CMTime endTime;


@property (nonatomic, strong) OCAudioPlayer *audioPlay;//自定义播放

@end

@implementation UploadGarageBandViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)initData{
    self.maxTime = CMTimeGetSeconds(self.audioAsset.duration);
    self.scale = self.audioAsset.duration.timescale;
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillResignActiveNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        //跳转离开或后台的时候自动收回分享的activity
        if ([[OCRouter shareInstance].selectedViewController.presentedViewController isKindOfClass:[UIActivityViewController class]]) {
            [[OCRouter shareInstance].selectedViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)setupUI{
    self.beginTextField.placeholder = [NSString stringWithFormat:@"起点长度不能小于0"];
    self.endTextField.placeholder = [NSString stringWithFormat:@"最大长度为：%f",self.maxTime];
    
    @weakify(self);
    [[[self.beginTextField.rac_textSignal throttle:0.25] filter:^BOOL(NSString * _Nullable value) {
        @strongify(self);
            return  value.floatValue >= 0 && value.floatValue <= self.maxTime;
    }] subscribeNext:^(NSString * _Nullable x) {
        @strongify(self);
        self.beginTime = CMTimeMakeWithSeconds(x.floatValue, self.scale);
    }];
    
    [[[self.endTextField.rac_textSignal throttle:0.25] filter:^BOOL(NSString * _Nullable value) {
        @strongify(self);
        CGFloat beginT = CMTimeGetSeconds(self.beginTime);
        BOOL check = value.floatValue >= beginT && value.floatValue <= self.maxTime;
        if (!check) {
            self.endTextField.text = @"";
            return NO;
        }
        return  YES;
    }] subscribeNext:^(NSString * _Nullable x) {
        @strongify(self);
        self.endTime = CMTimeMakeWithSeconds(x.floatValue, self.scale);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:NO];
}

- (IBAction)exportEvent:(id)sender {
    [self.view endEditing:NO];
    if (![self checkInstallGarageBand]) {
        [self showAlertViewWithMessage:@"制作铃声需要您先安装库乐队app" pushSetting:NO];
        return;
    }
    [self cropAudio];
}

- (BOOL)checkInstallGarageBand{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"garageband://"]]) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - 先裁剪，后转换格式
- (void)cropAudio{
    //1、创建AVmutableComposition ，这个将会hold AVMutableCompositionTrack
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *audioAssetTrack = [self.audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    NSError *error;
    CMTimeRange range = CMTimeRangeMake(self.beginTime, self.endTime);

    // 这块是裁剪,rangtime .前面的是开始时间,后面是裁剪多长
    [audioTrack insertTimeRange:range
                                       ofTrack:audioAssetTrack
                                        atTime:kCMTimeZero
                                         error:&error];
    if (error) {
        NSLog(@"裁剪音频出错了：%@",error);
        return;
    }
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateIntervalFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    //2种设置导出路径都可以，第二种注意要用fileURLWithPath
    NSURL *documentDirectory = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *outputURL = [documentDirectory URLByAppendingPathComponent:[self fileName]];
    
    outputURL = [outputURL URLByAppendingPathExtension:CFBridgingRelease(UTTypeCopyPreferredTagWithClass((CFStringRef)AVFileTypeAppleM4A, kUTTagClassFilenameExtension))];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputURL.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    }
    
    //5、Create Exporter
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:mixComposition presetName:AVAssetExportPresetAppleM4A];
    exportSession.outputURL = outputURL;
    //选择一个格式导出，exporter.supportedFileTypes也可以用来判断支持哪些导出格式
    exportSession.outputFileType = AVFileTypeAppleM4A;
    // 网络优化？,默认为no
    exportSession.shouldOptimizeForNetworkUse = YES;
    // 文件大小限制
    //    exportSession.fileLengthLimit = 1024 * 1024 * 1024;
    // 导出时间限制
    exportSession.timeRange = CMTimeRangeMake(CMTimeMake(0, 0), CMTimeMakeWithSeconds(2, NSEC_PER_SEC));
    // 时间距算法
    exportSession.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmSpectral;
    
    // 默认为no ， 设置为yes 的时候，质量更高,
    exportSession.canPerformMultiplePassesOverSourceMediaData = YES;
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
    
}

- (void)exportFinished:(AVAssetExportSession *)session{
    if (session.status != AVAssetExportSessionStatusCompleted) {
        NSLog(@"失败：%@",session.error);
        return;
    }
    
    NSString *bandPath = [GarageBandManager shareInstance].bandfolder;
    NSString *shareBandPath = [[GarageBandManager shareInstance].bandfolderDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.band",[self fileName]]];
    //copy一份garageBand
    [[NSFileManager defaultManager] copyItemAtPath:bandPath toPath:shareBandPath error:NULL];

    //拼接输出文件，这儿必须是ringtone.aiff，不然导出到铃声的时候会报错，测试了一下，不要Media也可以
    NSString *outputPath = [shareBandPath stringByAppendingPathComponent:@"Media/ringtone"];
    
    //拼接格式
    outputPath = [outputPath stringByAppendingPathExtension:CFBridgingRelease(UTTypeCopyPreferredTagWithClass((CFStringRef)AVFileTypeAIFF, kUTTagClassFilenameExtension))];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
    }
    
    BOOL result = [self convertAudio:session.outputURL.path toAIFF:outputPath];
    if (!result) {
        [MBProgressHUD lk_showErrorWithStatus:@"转换失败！" hideAfterDelay:1];
        return;
    }

    //确认一次转换文件
    BOOL aiffConvert = [[NSFileManager defaultManager] fileExistsAtPath:outputPath];
    if (!aiffConvert) {
        [MBProgressHUD lk_showErrorWithStatus:@"转换之后的文件不存在！" hideAfterDelay:1];
        return;
    }
    
    //这儿导出来之后可以试听一下
//    [self.audioPlay playAudio:outputPath];
    [self shareAudioWithPath:shareBandPath];
}

#pragma mark - share
- (void)shareAudioWithPath:(NSString *)outputPath{
    NSURL *shareUrl = [NSURL fileURLWithPath:outputPath];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareUrl] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeAirDrop];
    
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        
        NSLog(@"activityType: %@,\ncompleted: %d,\nreturnedItems:%@,\nactivityError:%@",activityType,completed,returnedItems,activityError);
    };
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - mp3 转 aiff
- (BOOL)convertAudio:(NSString *)inputFile  toAIFF:(NSString *)outputFile{
    ExtAudioConverter* converter = [[ExtAudioConverter alloc] init];
    converter.inputFile = inputFile;
    converter.outputFile = outputFile;
    converter.outputFileType = kAudioFileAIFFType;
    BOOL result =  [converter convert];
    
    return result;
}

- (void)showAlertViewWithMessage:(NSString *)message pushSetting:(BOOL)push
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
    
    if (push) {
        [alertVC addAction:ensureAction];
    }
    [alertVC addAction:cancelAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - lazy load
- (AVAsset *)audioAsset{
    if(!_audioAsset){
        NSURL *url = [NSURL fileURLWithPath:self.filePath];
        _audioAsset = [AVAsset assetWithURL:url];
    }
    return _audioAsset;
}

- (OCAudioPlayer *)audioPlay{
    if(!_audioPlay){
        _audioPlay = [[OCAudioPlayer alloc] init];
    }
    return _audioPlay;
}

- (NSString *)filePath{
    if(!_filePath){
        _filePath = [[NSBundle mainBundle] pathForResource:@"百战成诗" ofType:@"mp3"];
    }
    return _filePath;
}

- (NSString *)fileName{
    NSString *fileName = [[self.filePath lastPathComponent] stringByDeletingPathExtension];
    return  fileName;;
}

@end
    
