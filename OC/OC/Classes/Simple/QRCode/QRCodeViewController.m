//
//  QRCodeViewController.m
//  OC
//
//  Created by yier on 2019/3/20.
//  Copyright © 2019 yier. All rights reserved.
//

#import "QRCodeViewController.h"
#import "JImagePickerManager.h"
#import "NSTimer+Addition.h"

@import AVFoundation;
@interface QRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>
{
    int num;
    BOOL upOrdown;
}
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, retain) UIImageView * line;

@property (nonatomic,strong)NSTimer * timer;
@property (nonatomic,assign)BOOL isReading;
@property (weak, nonatomic) IBOutlet UIButton *getImageBtn;
@property (weak, nonatomic) IBOutlet UIButton *openTorchBtn;
@property (weak, nonatomic) IBOutlet UILabel *openTorchLabel;
@property (weak, nonatomic) IBOutlet UIButton *createQRCodeBtn;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *blackView;
@property (weak, nonatomic) IBOutlet UIView *QRBGView;

@property (nonatomic, assign) CGFloat maxZoomFactor;// 最大缩放比例
@property (nonatomic, assign) CGFloat minZoomFactor;// 最小缩放比例
@property (nonatomic, assign) CGFloat currentZoomFactor;// 当前缩放比例
@end

@implementation QRCodeViewController

- (void)dealloc{
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [self.timer pauseTimer];
    [_session stopRunning];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.timer resumeTimer];
    self.isReading = YES;
    [_session startRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"二维码");
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [self showErrorAlert];
        return;
    }
    [self.view layoutIfNeeded];
    [self initCamera];
    [self layout];
    [self initTimer];
}

- (void)showErrorAlert{
    UIAlertAction * actionCancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }];
    
    UIAlertAction * actionGo = [UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    
    UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"未检测到相机开启，请前往设置中打开此应用的相机权限!" preferredStyle:UIAlertControllerStyleAlert];
    [alertC addAction:actionCancle];
    [alertC addAction:actionGo];
    [self presentViewController:alertC animated:YES completion:^{
        
    }];
}

- (void)initData{

}

- (void)initTimer{
    @weakify(self);
    self.timer = [NSTimer timerWithTimeInterval:0.02 block:^(NSTimer * _Nonnull timer) {
        @strongify(self);
        [self animation];
    } repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [self.timer pauseTimer];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isReading = NO;
    });
}

#pragma mark - setupUI
- (void)initCamera
{
    //初始化相机设备
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 添加主题区域更改监视，比如旋转手机就会触发
    // 当AVCaptureDevice的subjectAreaChangeMonitoringEnabled属性为YES时才会发送此通知
    @weakify(self);
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.device] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        CGPoint point = self.bgView.center;
        //对拍照设备操作前，先进行锁定，防止其他线程访问
        NSError *error = nil;
        
        if ([self.device lockForConfiguration:&error]){
            [self.session beginConfiguration];
            
            // 获取聚焦点
            CGPoint focusPoint = [self.preview captureDevicePointOfInterestForPoint:point];
            
            // 设置聚焦点，必须先设置聚焦点再设置聚焦模式
            if ([self.device isFocusPointOfInterestSupported]) {
                self.device.focusPointOfInterest = focusPoint;
            }
            
            // 设置聚焦模式
            if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                self.device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                self.bgView.transform = CGAffineTransformMakeScale(1.1, 1.1);
            }completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.bgView.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    [self.session commitConfiguration];
                    [self.device unlockForConfiguration];
                }];
            }];
        }
    }];
    
    // 更改subjectAreaChangeMonitoringEnabled属性时需加锁处理
    [self.device lockForConfiguration:nil];
    self.device.subjectAreaChangeMonitoringEnabled = YES;
    [self.device unlockForConfiguration];
    
    //初始化输入
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    //初始化输出
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 初始化session
    self.session = [[AVCaptureSession alloc]init];
    // 对于识别率的精度 就是屏幕有波浪一样
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    // 改成了 降低采集频率
    //    [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    if ([self.session canAddInput:self.input]){
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.output]){
        [self.session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    /**
     *  判断是否可以扫描，如果不可以扫描，提示用户开启相机授权。
     */
    if (![self.output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showErrorAlert];
        });
    }else{
        self.output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];//设置扫描类型;
    }
    //设置扫描区域
    [self.output setRectOfInterest:CGRectMake(0, 0, self.bgView.frame.size.width, self.bgView.frame.size.height)];//设置扫描区域
    

    // 创建摄像设备输出流，用于识别光线强弱
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    // 添加摄像设备输出流到会话对象
    if ([self.session canAddOutput:videoDataOutput]) {
        [self.session addOutput:videoDataOutput];
    }
    
    //图形输出
    self.photoOutput = [[AVCapturePhotoOutput  alloc] init];
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecTypeJPEG}];
    self.photoOutput.photoSettingsForSceneMonitoring = settings;
    if ([self.session canAddOutput:self.photoOutput]) {
        [self.session addOutput:self.photoOutput];
    }
    
    //初始化一个显示扫描界面的layer
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(0, 0, self.bgView.frame.size.width,self.bgView.frame.size.height);
    [self.bgView.layer insertSublayer:self.preview atIndex:0];
    
    // 给预览父视图添加缩放手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] init];
    [self.bgView addGestureRecognizer:pinch];
    
    [[pinch rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        @strongify(self);
        if (![self.session isRunning] ){
            return;
        }
        
        //当UIGestureRecognizerStateChanged时，根据手势改变当前的zoomFactor
        if (pinch.state == UIGestureRecognizerStateBegan) {
            self.currentZoomFactor = self.device.videoZoomFactor;
        } else if (pinch.state == UIGestureRecognizerStateChanged) {
            CGFloat currentZoomFactor = self.currentZoomFactor * pinch.scale;
            if (currentZoomFactor < self.maxZoomFactor && currentZoomFactor > self.minZoomFactor) {
                //改变videoZoomFactor需要加锁
                if ([self.device lockForConfiguration:nil]) {
                    self.device.videoZoomFactor = currentZoomFactor;
                    [self.device unlockForConfiguration];
                }
            }
        }
    }];
}

- (void)layout
{
    upOrdown = NO;
    num =0;
    self.line = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.QRBGView.frame), CGRectGetMinY(self.QRBGView.frame)+2*num-30, CGRectGetWidth(self.QRBGView.frame), 2)];
    self.line.image = [UIImage imageNamed:@"QRCode_line.png"];
    [self.view addSubview:_line];
    
}
/**
 *  扫描动画
 */
-(void)animation
{
    if (upOrdown == NO) {
        num ++;
        self.line.frame = CGRectMake(CGRectGetMinX(self.QRBGView.frame), CGRectGetMinY(self.QRBGView.frame)+2*num-30, CGRectGetWidth(self.QRBGView.frame), 2);
        if (2*num == CGRectGetHeight(self.QRBGView.frame)) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        self.line.frame = CGRectMake(CGRectGetMinX(self.QRBGView.frame), CGRectGetMinY(self.QRBGView.frame)+2*num-30, CGRectGetWidth(self.QRBGView.frame), 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
      fromConnection:(AVCaptureConnection *)connection
{
    if (self.isReading == NO) {
        self.isReading = YES;
        
        NSString *stringValue;
        
        if (metadataObjects != nil && [metadataObjects count] > 0)
        {
            AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
            stringValue = metadataObject.stringValue;
            NSLog(@"stringValue:%@",stringValue);
            if ([self isNumber:stringValue]) {
                
                UIAlertAction * action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.isReading = NO;
                    });
                }];
                
                UIAlertController * alertC = [UIAlertController
                                              alertControllerWithTitle:@"提示" message:
                                              [NSString stringWithFormat:@"%@\n是条形码",stringValue]
                                              preferredStyle:UIAlertControllerStyleAlert];
                [alertC addAction:action];
                
                [self presentViewController:alertC animated:YES completion:^{
                    
                }];
            }
            else if ([self isOCURL:stringValue])
            {
                [self.navigationController popViewControllerAnimated:YES];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [OCRouter openInnerURL:[NSURL URLWithString:nilToEmptyString(stringValue)]];
                });
            }
            else
            {
                UIAlertAction * action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.isReading = NO;
                    });
                }];
                
                UIAlertController * alertC = [UIAlertController
                                              alertControllerWithTitle:@"提示" message:
                                              [NSString stringWithFormat:@"url:%@\n不是平台的url，不跳转",stringValue]
                                              preferredStyle:UIAlertControllerStyleAlert];
                [alertC addAction:action];
                
                [self presentViewController:alertC animated:YES completion:^{
                    
                }];
            }
            
        }
    }
}

//判断是否是数字
- (BOOL)isNumber:(NSString *)string
{
    NSString *webSiteRegex = @"^[0-9]*$";
    
    NSPredicate *site = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",webSiteRegex];
    
    return [site evaluateWithObject:string];
}

//判断是否是路由
- (BOOL)isOCURL:(NSString *)stringValue
{
    return [stringValue hasPrefix:@"sumup://"];
}

#pragma mark - ButtonEvent

- (IBAction)getImageEvent:(UIButton *)sender {
    [JImagePickerManager chooseImageFromViewController:self allowEditting:YES imageMaxSizeLength:[UIScreen mainScreen].bounds.size.width completionHandle:^(UIImage *image, NSDictionary *pickingMediainfo) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //1.获取选择的图片
            [self readQRCodeFromImageWithFile:image];
        });
        
    }];
}

- (void)readQRCodeFromImageWithFile:(UIImage *)img
{
    //根据url找到CIImage
    CIImage * image = [CIImage imageWithCGImage:img.CGImage];
    if (image) {
        //创建CIDetector
        CIDetector * qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:[CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}] options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
        NSArray * features = [qrDetector featuresInImage:image];
        if (features.count > 0) {
            NSString * urlStr = @"";
            for (int i = 0;i<features.count;i++) {
                CIFeature * feature  = features[i];
                
                if (![feature isKindOfClass:[CIQRCodeFeature class]]) {
                    continue;
                }
                CIQRCodeFeature * QRFeature = (CIQRCodeFeature *)feature;
                NSString * QRStr = QRFeature.messageString;
                urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"\n%@",QRStr]];
                
                if (i == features.count -1) {
                    UIAlertAction * action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"内容" message:urlStr preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:action];
                    [self presentViewController:alert animated:YES completion:^{
                        
                    }];
                }
            }
        }
        
    }
}

- (IBAction)openTorchEvent:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.openTorchLabel.text = sender.selected?@"关灯":@"开灯";
    
    NSError *error = nil;
    
    [_device lockForConfiguration:&error];
    
    if (error == nil) {
        AVCaptureTorchMode mode = _device.torchMode;
        
        _device.torchMode = mode == AVCaptureTorchModeOn ? AVCaptureTorchModeOff : AVCaptureTorchModeOn;
    }
    
    [_device unlockForConfiguration];
}

- (IBAction)createQRCodeEvent:(UIButton *)sender {
    [OCRouter openInnerURL:[NSURL URLWithString:@"sumup://simple/QRCode/QRCodeCreate"]];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer fromConnection:(nonnull AVCaptureConnection *)connection {
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    CGFloat brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    //一般为-7到2波动，暗->亮
//    NSLog(@"====%f",brightnessValue);
}

#pragma mark - lazy load
- (CGFloat)maxZoomFactor {
    CGFloat max = 1;
    if (@available(iOS 11.0, *)) {
        max = self.device.maxAvailableVideoZoomFactor;
    } else {
        max = self.device.activeFormat.videoMaxZoomFactor;
    }
    
    // 对最大缩放比例再次做限制
    if (max > 5) {
        max = 5;
    }
    
    return max;
}

- (CGFloat)minZoomFactor {
    CGFloat min = 1;
    if (@available(iOS 11.0, *)) {
        min = self.device.minAvailableVideoZoomFactor;
    }
    
    return min;
}

@end
