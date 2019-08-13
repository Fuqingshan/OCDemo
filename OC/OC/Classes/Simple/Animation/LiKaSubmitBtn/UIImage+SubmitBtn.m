//
//  UIImage+SubmitBtn.m
//  Testaaa
//
//  Created by yier on 2018/8/8.
//  Copyright © 2018 yier. All rights reserved.
//

#import "UIImage+SubmitBtn.h"

@implementation UIImage (SubmitBtn)

+ (UIImage *)submitImageWithFrame:(CGRect)frame{
    if (CGRectEqualToRect(frame, CGRectZero)) {
        return nil;
    }
    
    //Create our background gradient layer
    CAGradientLayer *backgroundGradientLayer = [CAGradientLayer layer];
    backgroundGradientLayer.frame = frame;
    
    UIColor* gradientColor = [UIColor colorWithRed: 0.988 green: 0.722 blue: 0.282 alpha: 1];
    UIColor* gradientColor2 = [UIColor colorWithRed: 1 green: 0.349 blue: 0.216 alpha: 1];
    
    NSArray *colors = @[gradientColor,gradientColor2];
    NSMutableArray *cgColors = [[NSMutableArray alloc] init];
    for (UIColor *color in colors) {
        [cgColors addObject:(id)[color CGColor]];
    }
    
    UIGraphicsBeginImageContextWithOptions(frame.size,NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    
    // 设置填充颜色
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextFillRect(ctx, frame);

    // 2. 创建一个渐变色
    // 创建RGB色彩空间，创建这个以后，context里面用的颜色都是用RGB表示
    CGFloat locations[2] = {0.0, 1.0};
    //Default to the RGB Colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)cgColors, locations);
    
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, frame.size.width, frame.size.height) cornerRadius: 4];
    [path addClip];
    
    // 3. 用渐变色填充
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0,frame.size.height/2.0f), CGPointMake(frame.size.width, frame.size.height/2.0f ), kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    // 释放渐变色
    CGGradientRelease(gradient);
    // 释放色彩空间
    CGColorSpaceRelease(colorSpace);
    colorSpace = NULL;
    UIGraphicsPopContext();
    
    // Grab it as an Image
    UIImage *backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSData *data = UIImagePNGRepresentation(backgroundColorImage);
    [[NSFileManager defaultManager] createFileAtPath:@"/Users/yier/Desktop/TestBethelCircle/1.png" contents:data attributes:[NSDictionary dictionary]];
    
    return backgroundColorImage;
}

@end
