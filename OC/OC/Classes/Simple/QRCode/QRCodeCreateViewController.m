//
//  QRCodeCreateViewController.m
//  OC
//
//  Created by yier on 2019/3/21.
//  Copyright © 2019 yier. All rights reserved.
//

#import "QRCodeCreateViewController.h"
#import "JImagePickerManager.h"

@interface QRCodeCreateViewController ()
@property (weak, nonatomic) IBOutlet UIButton *insertBtn;
@property (weak, nonatomic) IBOutlet UIButton *createBtn;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImageView;

@end

@implementation QRCodeCreateViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = @"创建二维码";
}

- (void)initData{
    
}

- (IBAction)createEvent:(UIButton *)sender {
    [self.urlTextField resignFirstResponder];
    
    if ([self.urlTextField.text isEqualToString:@""]) {
        return;
    }
    
    // 1.创建生成二维码的滤镜
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    /*
     //1.创建滤镜的参数的获得方式
     
     NSArray *array = [CIFilter filterNamesInCategories:@[kCICategoryBuiltIn]];
     
     NSLog(@"%@",array);
     //2.设置滤镜参数的KeyPath获得方式
     
     NSLog(@"%@",[filter inputKeys]);
     */
    
    // 2.把数据输入给滤镜
    
    NSString *url = self.urlTextField.text;
    
    NSData *data = [url dataUsingEncoding:NSUTF8StringEncoding];
    
    //需要把NSString 转为 NSData
    
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    // 2.1 设置二维码的纠错率 key: inputCorrectionLevel
    // 纠错率等级: L, M, Q, H
    [filter setValue:@"L" forKey:@"inputCorrectionLevel"];
    
    // 3.获得滤镜生成的二维码
    
    CIImage *image = [filter outputImage];
    // 4.为图片设置image
    
    self.QRCodeImageView.image =[self createNonInterpolatedUIImageFormCIImage:image withSize:self.QRCodeImageView.bounds.size];
    
}

- (IBAction)insertBtn:(UIButton *)sender {
    [JImagePickerManager chooseImageFromViewController:self allowEditting:YES imageMaxSizeLength:kMainScreenWidth completionHandle:^(UIImage *image, NSDictionary *pickingMediainfo) {
        self.QRCodeImageView.image = [self addImageWithQRCodeImage:self.QRCodeImageView.image withHeadImage:image];
    }];
}

#pragma mark - 二维码添加图片

- (UIImage *)addImageWithQRCodeImage:(UIImage *)image withHeadImage:(UIImage *)headImage{
    
    //1.开启上下文
    
    UIGraphicsBeginImageContext(image.size);
    
    //2.绘制二维码图
    
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    //3.插入图片 - 插入图片的大小不能超过二维码的20%
    
    CGFloat imageW = image.size.width * 0.2;
    
    CGFloat imageH = image.size.height * 0.2;
    
    CGFloat imageX = (image.size.width - imageW) * 0.5;
    
    CGFloat imageY = (image.size.height - imageH) * 0.5;;
    
    
    [headImage drawInRect:CGRectMake(imageX, imageY, imageW, imageH)];
    
    //4.取出图片
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //5.关闭上下文
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

// 放大生成的二维码
- (UIImage *)scaleImage:(CIImage *)ciImage{
    // 创建放大的系数
    CGAffineTransform  tranform = CGAffineTransformMakeScale(20, 20);
    
    // 根据放大系数放大的图片
    CIImage * newImage = [ciImage imageByApplyingTransform:tranform];
    
    // 返回生成好的图片
    return [UIImage imageWithCIImage:newImage];
}


/**
 *  根据CIImage生成指定大小的UIImage
 *
 *  @param image CIImage
 *  @param size  图片宽度
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGSize) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size.width/CGRectGetWidth(extent), size.height/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark-> 长按识别二维码

-(IBAction)dealLongPress:(UIGestureRecognizer*)gesture{
    
    if(gesture.state==UIGestureRecognizerStateBegan){
        
        UIImageView*tempImageView=(UIImageView*)gesture.view;
        if (tempImageView.image.CGImage || tempImageView.image.CIImage) {
            //根据url找到CIImage
            CIImage * image = [[CIImage alloc]init];
            image = tempImageView.image.CGImage != nil ?
            [CIImage imageWithCGImage:tempImageView.image.CGImage]
            :
            tempImageView.image.CIImage;
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
    }else if (gesture.state==UIGestureRecognizerStateEnded){
        
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.urlTextField resignFirstResponder];
}

@end
