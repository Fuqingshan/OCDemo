//
//  UIView+CustomAnimation.m
//  WeiXinBarCodeImitate
//
//  Created by chenHS on 16/12/26.
//  Copyright © 2016年 nice. All rights reserved.
//

#import "UIView+CustomAnimation.h"

@implementation UIView (CustomAnimation)
//创建条形码
+ (void)generateCodeWithImageView:(UIImageView*)imageView code:(NSString*)code codestyle:(NSInteger)style{
    // @"CICode128BarcodeGenerator"  条形码 style == 0
    // @"CIAztecCodeGenerator"       二维码 style == 1
    NSString *filtername = @"CICode128BarcodeGenerator";
    if (style == 1) {
        filtername = @"CIAztecCodeGenerator";
    }
    
    if (style == 0) {
        CIFilter *filter = [CIFilter filterWithName:filtername];
        [filter setDefaults];
        
        NSData *data = [code dataUsingEncoding:NSUTF8StringEncoding];
        [filter setValue:data forKey:@"inputMessage"];
        
        CIImage *outputImage = [filter outputImage];
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgImage = [context createCGImage:outputImage
                                           fromRect:[outputImage extent]];
        UIImage *image = [UIImage imageWithCGImage:cgImage
                                             scale:1.
                                       orientation:UIImageOrientationUp];
        
        // Resize without interpolating
        CGFloat scaleRate = imageView.frame.size.width / image.size.width;
        UIImage *resized = [UIView resizeImage:image
                                   withQuality:kCGInterpolationNone
                                          rate:scaleRate];
        
        imageView.image = resized;
        
        CGImageRelease(cgImage);
    } else {
        NSArray *filters = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
        NSLog(@"%@",filters);
        //二维码过滤器
        CIFilter *qrImageFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        //设置过滤器默认属性 (老油条)
        [qrImageFilter setDefaults];
        //将字符串转换成 NSdata (虽然二维码本质上是 字符串,但是这里需要转换,不转换就崩溃)
        NSData *qrImageData = [code dataUsingEncoding:NSUTF8StringEncoding];
        //我们可以打印,看过滤器的 输入属性.这样我们才知道给谁赋值
//        NSLog(@"%@",qrImageFilter.inputKeys);
        /*
         inputMessage,        //二维码输入信息
         inputCorrectionLevel //二维码错误的等级,就是容错率
         */
        //设置过滤器的 输入值  ,KVC赋值
        [qrImageFilter setValue:qrImageData forKey:@"inputMessage"];
        //取出图片
        CIImage *qrImage = [qrImageFilter outputImage];
        //但是图片 发现有的小 (27,27),我们需要放大..我们进去CIImage 内部看属性
        qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(20, 20)];
        //转成 UI的 类型
        UIImage *qrUIImage = [UIImage imageWithCIImage:qrImage];
        //----------------给 二维码 中间增加一个 自定义图片----------------
        //开启绘图,获取图形上下文  (上下文的大小,就是二维码的大小)
        UIGraphicsBeginImageContext(qrUIImage.size);
        //把二维码图片画上去. (这里是以,图形上下文,左上角为 (0,0)点)
        [qrUIImage drawInRect:CGRectMake(0, 0, qrUIImage.size.width, qrUIImage.size.height)];
        //再把小图片画上去
        UIImage *sImage = [UIImage imageNamed:@"yinlian"];

        CGFloat sImageW = 100;
        CGFloat sImageH = 100*15/24 ;
        CGFloat sImageX = (qrUIImage.size.width - sImageW) * 0.5;
        CGFloat sImgaeY = (qrUIImage.size.height - sImageH) * 0.5;
        
        [sImage drawInRect:CGRectMake(sImageX, sImgaeY, sImageW, sImageH)];
        //获取当前画得的这张图片
        UIImage *finalyImage = UIGraphicsGetImageFromCurrentImageContext();
        //关闭图形上下文
        UIGraphicsEndImageContext();
        //设置图片
        imageView.image = finalyImage;
    }
    
}
+ (UIImage *)resizeImage:(UIImage *)image
             withQuality:(CGInterpolationQuality)quality
                    rate:(CGFloat)rate {
    UIImage *resized = nil;
    CGFloat width    = image.size.width * rate;
    CGFloat height   = image.size.height * rate;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resized;
}

//对条形码添加空格处理
+ (void)insertBlankWithLabel:(UILabel *)label{
    NSMutableString * str =[NSMutableString stringWithString:label.text?:@""] ;
    NSInteger num = str.length;
    NSInteger  insertNum = num/4;
    NSInteger  remainder =num%4;
    if (remainder<=3) {
        insertNum = insertNum -1;
    }
    for ( int i = 0; i <insertNum; i++) {
        [ str insertString:@" " atIndex:(i+1)*4+i];
    }
    label.text = str;
    
}
//截图
+ (UIImage * )getImageWithView:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions( view.frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  theImage;
}

//条形码放大旋转/恢复
+ (void)imageViewAnimationWithIsShowView:(UIView*)view  andIsShow:(BOOL)isShow codestyle:(NSInteger)style{
    //  条形码 style == 0
    //  二维码 style == 1
    CGPoint oldCenter = view.center;
    CGPoint newCenter = CGPointMake(mainScreenWidth/2, mainScreenHeight/2);
    if (style == 0) {
        newCenter = CGPointMake(mainScreenWidth/2-40, mainScreenHeight/2);
    }
    CABasicAnimation* rotationAnimation1;
    rotationAnimation1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    if (style == 0) {
        //旋转
        rotationAnimation1.fromValue = [NSNumber numberWithFloat:isShow?0 : M_PI_2];
        rotationAnimation1.toValue = [NSNumber numberWithFloat:isShow? M_PI_2 :0 ];
    } else
    {
        rotationAnimation1.fromValue = [NSNumber numberWithFloat:isShow?0 : 0];
        rotationAnimation1.toValue = [NSNumber numberWithFloat:isShow? 0 :0 ];
    }
    
    // 缩放/恢复
    
    CABasicAnimation* rotationAnimation2= [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    rotationAnimation2.fromValue = [NSNumber numberWithFloat:isShow? 1.0:1.8];
    rotationAnimation2.toValue = [NSNumber numberWithFloat:isShow? 1.8:1.0];
     
    
    
    CABasicAnimation *rotationAnimation3 =
    [CABasicAnimation animationWithKeyPath:@"position"];
    
    //中心位移
   rotationAnimation3.fromValue = [NSValue valueWithCGPoint:isShow?oldCenter:newCenter ];
   rotationAnimation3.toValue = [NSValue valueWithCGPoint: isShow?newCenter:oldCenter ]; // 終点
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    // 动画选项设定
    group.duration = 0.3;
    group.repeatCount = 1;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.animations = [NSArray arrayWithObjects:rotationAnimation1,rotationAnimation2,rotationAnimation3,nil];
    [view.layer addAnimation:group forKey:@"move-rotate-layer"];
    
}
 
@end
