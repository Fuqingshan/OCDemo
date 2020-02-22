//
//  AVFoundationVC1.m
//  AVFoundationDemo
//
//  Created by yier on 2020/2/8.
//  Copyright © 2020 yier. All rights reserved.
//

#import "AVFoundationVC1.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AVFoundationVC1 ()<AVCaptureFileOutputRecordingDelegate>

@property(nonatomic, strong) AVCaptureSession *captureSessiton;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutput;
@property(nonatomic, strong) AVCaptureConnection *captureConnection;

@property(nonatomic, strong) AVCaptureDevice *captureVideoDevice;
@property(nonatomic, strong) AVCaptureDeviceInput *captureVideoDevoceInput;

@property(nonatomic, strong) AVCaptureDevice *captureAudioDevice;
@property(nonatomic, strong) AVCaptureDeviceInput *captureAudioDeviceInput;

@property(nonatomic, strong) UIButton *beginButton;
@property(nonatomic, strong) UILabel *timeLabel;
@property(nonatomic, strong) UIButton *replayButton;
@property(nonatomic, strong) UIButton *saveButton;

@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, assign) NSInteger timerInteger;

@property(nonatomic, strong) NSURL *videoURL;
@property(nonatomic, assign) BOOL canSave;

@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) AVPlayerItem *playItem;//一个媒体资源管理对象，管理者视频的一些基本信息和状态，一个AVPlayerItem对应着一个视频资源
@property(nonatomic, strong) AVPlayerLayer *playerLayer;
@property(nonatomic, assign) BOOL isPlaying;

@end

@implementation AVFoundationVC1

- (void)dealloc{
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.captureSessiton startRunning];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if ([self.captureSessiton isRunning]) {
        [self.captureSessiton stopRunning];
    }
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.timerInteger = 0;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //获取授权状态
    [self getAuthorizeStatus];
    [self setupUI];
}

//用户权限
- (void)getAuthorizeStatus{
    //判断照相机和，麦克风权限
    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        NSString *errorStr = @"应用相机权限受限,请在设置中启用";
        NSLog(@"%@", errorStr);
        [self showAlertViewWithMessage:errorStr];
        return;
    }
    
    mediaType = AVMediaTypeAudio;//读取媒体类型
    authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        NSString *errorStr = @"麦克风权限受限,请在设置中启用";
        NSLog(@"%@", errorStr);
        [self showAlertViewWithMessage:errorStr];
        return;
    }
    
    [self beginVideoConfiguration];
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


//UI界面初始化
- (void)setupUI{
    self.title = @"视频录制播放";
    
    //开始录制按钮
       UIButton *beginButton = [UIButton buttonWithType:UIButtonTypeCustom];
       beginButton.backgroundColor = [UIColor clearColor];
       [beginButton setTitle:@"开始录制" forState:UIControlStateNormal];
       beginButton.layer.borderColor = [UIColor blueColor].CGColor;
       beginButton.layer.borderWidth = 1.0;
       [beginButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
       [beginButton addTarget:self action:@selector(beginButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
       [self.view addSubview:beginButton];
       self.beginButton = beginButton;
       
       [beginButton sizeToFit];
       [beginButton mas_makeConstraints:^(MASConstraintMaker *make) {
           make.bottom.equalTo(self.view).offset(-30.0);
           make.centerX.equalTo(self.view);
       }];
       
       //计时标志
       UILabel *timeLabel = [[UILabel alloc] init];
       timeLabel.text = @"0";
       timeLabel.textAlignment = NSTextAlignmentCenter;
       timeLabel.backgroundColor = [UIColor clearColor];
       timeLabel.textColor = [UIColor redColor];
       timeLabel.font = [UIFont boldSystemFontOfSize:20.0];
       [self.view addSubview:timeLabel];
       self.timeLabel = timeLabel;
       
       [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           make.centerX.equalTo(self.view);
           make.bottom.equalTo(self.beginButton.mas_top).offset(-15.0);
           make.height.equalTo(@25);
           make.width.equalTo(@120);
       }];
       
       //重播按钮
       UIButton *replayButton = [UIButton buttonWithType:UIButtonTypeCustom];
       replayButton.backgroundColor = [UIColor clearColor];
       [replayButton setTitle:@"预览播放" forState:UIControlStateNormal];
       replayButton.layer.borderColor = [UIColor blueColor].CGColor;
       replayButton.layer.borderWidth = 1.0;
       [replayButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
       [replayButton addTarget:self action:@selector(replayButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
       replayButton.hidden = YES;
       [self.view addSubview:replayButton];
       self.replayButton = replayButton;
       
       [replayButton sizeToFit];
       [replayButton mas_makeConstraints:^(MASConstraintMaker *make) {
           make.right.equalTo(self.beginButton.mas_left).offset(-30.0);
           make.centerY.equalTo(self.beginButton);
       }];
       
       //保存按钮
       UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
       saveButton.backgroundColor = [UIColor clearColor];
       [saveButton setTitle:@"保存" forState:UIControlStateNormal];
       saveButton.layer.borderColor = [UIColor blueColor].CGColor;
       saveButton.layer.borderWidth = 1.0;
       [saveButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
       [saveButton addTarget:self action:@selector(saveButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
       [self.view addSubview:saveButton];
       self.saveButton = saveButton;
       
       [saveButton sizeToFit];
       [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(self.beginButton.mas_right).offset(30.0);
           make.centerY.equalTo(self.beginButton);
       }];
}

- (void)loadTimer
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

#pragma mark - private function

- (void)beginVideoConfiguration{
    //开启上下文
    [self addSession];
    
    [self.captureSessiton beginConfiguration];
    
    //开始视频配置
    [self addVideo];
    
    //开始配置音频
    [self addAudio];
    
    //开始配置预览图层
    [self addPreviewLayer];
    
    [self.captureSessiton commitConfiguration];
    
    //开始会话，不等于录制
    [self.captureSessiton startRunning];
}

- (void)addSession{
    self.captureSessiton = [[AVCaptureSession alloc] init];
    
    if ([self.captureSessiton canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        self.captureSessiton.sessionPreset = AVCaptureSessionPresetHigh;
    }else{
        self.captureSessiton.sessionPreset = AVCaptureSessionPreset1280x720;
    }
}

- (void)addVideo{
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    for (AVCaptureDevice *device in discoverySession.devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if (device.position == AVCaptureDevicePositionBack) {
                self.captureVideoDevice = device;
            }
        }
    }

    //添加输入设备
    [self addVideoInput];
    
    //添加输出设备
    [self addVideoOutput];
}

- (void)addAudio{
    NSError *error;
    
    self.captureAudioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    self.captureAudioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureAudioDevice error:&error];
    if (error) {
        return;
    }
    
    if ([self.captureSessiton canAddInput:self.captureAudioDeviceInput]) {
        [self.captureSessiton addInput:self.captureAudioDeviceInput];
    }
}

- (void)addPreviewLayer{
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSessiton];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    self.previewLayer.frame = self.view.frame;
    [self.view.layer addSublayer:self.previewLayer];
}

- (void)addVideoInput{
    NSError *error;
    self.captureVideoDevoceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureVideoDevice error:&error];
    if (error) {
        return;
    }
    if ([self.captureSessiton canAddInput:self.captureVideoDevoceInput]) {
        [self.captureSessiton addInput:self.captureVideoDevoceInput];
    }
}

- (void)addVideoOutput{
    self.captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.captureSessiton canAddOutput:self.captureMovieFileOutput]) {
        [self.captureSessiton addOutput:self.captureMovieFileOutput];
    }
    //设置链接管理对象
    self.captureConnection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //视频旋转方向设置
    self.captureConnection.videoScaleAndCropFactor = self.captureConnection.videoMaxScaleAndCropFactor;
    
    //视频稳定设置
    if ([self.captureConnection isVideoStabilizationSupported]) {
        self.captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
}

//视频保存
- (void)saveVideo:(NSURL *)outputFileURL{
    //判断是否有相册权限
    PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];
    if (authorStatus == PHAuthorizationStatusRestricted || authorStatus == PHAuthorizationStatusDenied) {
        NSString *errorStr = @"没有使用相册权限，请在设置中打开";
        [self showAlertViewWithMessage:errorStr];
        return;
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
         PHAssetChangeRequest *changeAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
        PHObjectPlaceholder *assetPlaceholder = [changeAssetRequest placeholderForCreatedAsset];

        PHAssetCollection *collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        PHAssetCollectionChangeRequest *changeCollectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
        [changeCollectionRequest addAssets:@[assetPlaceholder]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                      NSLog(@"保存视频失败:%@",error);
                      [self.saveButton setTitle:@"保存失败" forState:UIControlStateNormal];
                      [self.saveButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                      self.replayButton.hidden = YES;
                  }else{
                      NSLog(@"保存视频到相册成功");
                      [self.saveButton setTitle:@"保存成功" forState:UIControlStateNormal];
                      [self.saveButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
                      self.replayButton.hidden = NO;
                  }
        });
    
    }];
}

- (NSURL *)outPutFileURL{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),@"output.mov"]];
}

//创建预览视图
- (void)createPlayView{
    NSLog(@"%@",self.videoURL);
    [self.previewLayer removeFromSuperlayer];
    self.playItem = [AVPlayerItem playerItemWithURL:self.videoURL];
    self.player = [AVPlayer playerWithPlayerItem:self.playItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.view.frame;
    
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//视频填充模式
    CALayer *layer = self.view.layer;
    layer.masksToBounds = YES;
    
    [layer addSublayer:self.playerLayer];
}

#pragma mark - Action && Notifacation

//开始录制按钮
- (void)beginButtonDidClick:(UIButton *)buton{
    buton.enabled = NO;
    NSLog(@"开始录制按钮");
    
    [self loadTimer];
    [self.captureMovieFileOutput startRecordingToOutputFileURL:[self outPutFileURL] recordingDelegate:self];
}

//重播按钮
- (void)replayButtonDidClick{
    NSLog(@"重新播放按钮");
    
    if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
        return;
    }
        
    [self createPlayView];
    [self.view bringSubviewToFront:self.saveButton];
    [self.view bringSubviewToFront:self.replayButton];
    [self.view bringSubviewToFront:self.beginButton];

    [self.player play];
}

//保存按钮
- (void)saveButtonDidClick{
    NSLog(@"保存按钮");
    
    self.saveButton.enabled = NO;
    if (self.timer) {
        [self.timer invalidate];
    }
    
    self.canSave = YES;
    [self.captureSessiton stopRunning];
    [self.captureMovieFileOutput stopRecording];
}

//定时器
- (void)timerRun{
    NSInteger seconds = self.timerInteger % 60;
    NSInteger minutes = (self.timerInteger / 60) % 60;
    NSInteger hours = self.timerInteger / 3600;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hours,minutes,seconds];
    self.timerInteger++;
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

//开始录制调用的代理方法
- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    NSLog(@"---开始录制---");
}

//录制结束调用的代理方法
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error{
    NSLog(@"---录制结束---%@-%@",outputFileURL,output.outputFileURL);
    if (outputFileURL.absoluteString.length == 0 && output.outputFileURL.absoluteString.length == 0) {
        return;
    }
    
    if (self.canSave) {
        self.videoURL = outputFileURL;
        self.canSave = NO;
        [self saveVideo:self.videoURL];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
