//
//  UIColor+Gradient.m
//  TestBethelCircle
//
//  Created by yier on 2018/5/24.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "UIColor+Gradient.h"

@implementation UIColor (Gradient)

+ (UIColor *)colorWithGradientStyle:(UIGradientStyle)gradientStyle withFrame:(CGRect)frame lineWidth:(CGFloat)lineWidth andColors:(NSArray<UIColor *> *)colors percent:(CGFloat)percent{
    if (colors.count == 0) {
        return nil;
    }
    
    //Create our background gradient layer
    CAGradientLayer *backgroundGradientLayer = [CAGradientLayer layer];
    
    //Set the frame to our object's bounds
    backgroundGradientLayer.frame = frame;
    
    //To simplfy formatting, we'll iterate through our colors array and create a mutable array with their CG counterparts
    NSMutableArray *cgColors = [[NSMutableArray alloc] init];
    for (UIColor *color in colors) {
        [cgColors addObject:(id)[color CGColor]];
    }
    
    switch (gradientStyle) {
        case UIGradientStyleLeftToRight: {
            
            //Set out gradient's colors
            backgroundGradientLayer.colors = cgColors;
            
            //Specify the direction our gradient will take
            [backgroundGradientLayer setStartPoint:CGPointMake(0.0, 0.5)];
            [backgroundGradientLayer setEndPoint:CGPointMake(1.0, 0.5)];
            
            //Convert our CALayer to a UIImage object
            UIGraphicsBeginImageContextWithOptions(backgroundGradientLayer.bounds.size,NO, [UIScreen mainScreen].scale);
            [backgroundGradientLayer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return [UIColor colorWithPatternImage:backgroundColorImage];
        }
            
        case UIGradientStyleArc:{
            UIGraphicsBeginImageContextWithOptions(frame.size,NO, [UIScreen mainScreen].scale);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            UIGraphicsPushContext(ctx);
            
            CGContextSetLineWidth(ctx, lineWidth == 0.0f? 10.0f: lineWidth);
            // 设置线条端点为圆角
            CGContextSetLineCap(ctx, kCGLineCapRound);
            // 设置填充颜色
            CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
            CGContextFillRect(ctx, frame);
            // Normalise the 0-1 ranged inputs to the width of the image
            CGPoint myCentrePoint = CGPointMake(0.5 * frame.size.width  , 0.5 * frame.size.height);
            
            float myRadius = MIN(frame.size.width, frame.size.height) * 0.5 - lineWidth;
            
            // 逆时针画一个圆弧，因为这个与UIKit坐标系相反,因此YES为UIKit坐标系逆时针
            CGContextAddArc(ctx, myCentrePoint.x, myCentrePoint.y, myRadius, - M_PI*1/2 , 2*M_PI *percent-0.5*M_PI, NO);

            // 2. 创建一个渐变色
            // 创建RGB色彩空间，创建这个以后，context里面用的颜色都是用RGB表示
            CGFloat locations[2] = {0.0, 1.0};
            //Default to the RGB Colorspace
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)cgColors, locations);
            
            // ----------以下为重点----------
            // 3. "反选路径"
            // CGContextReplacePathWithStrokedPath
            // 将context中的路径替换成路径的描边版本，使用参数context去计算路径（即创建新的路径是原来路径的描边）。用恰当的颜色填充得到的路径将产生类似绘制原来路径的效果。你可以像使用一般的路径一样使用它。例如，你可以通过调用CGContextClip去剪裁这个路径的描边
            CGContextReplacePathWithStrokedPath(ctx);
            // 剪裁路径
            CGContextClip(ctx);
            
            // 4. 用渐变色填充
            CGContextDrawLinearGradient(ctx, gradient, CGPointMake(frame.size.width,0), CGPointMake(0, frame.size.height ), 0);
            
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
            
            return [UIColor colorWithPatternImage:backgroundColorImage];
        }
        case UIGradientStyleRadial: {
            UIGraphicsBeginImageContextWithOptions(frame.size,NO, [UIScreen mainScreen].scale);
            
            //Specific the spread of the gradient (For now this gradient only takes 2 locations)
            CGFloat locations[2] = {0.0, 1.0};
            
            //Default to the RGB Colorspace
            CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
            CFArrayRef arrayRef = (__bridge CFArrayRef)cgColors;
            
            //Create our Fradient
            CGGradientRef myGradient = CGGradientCreateWithColors(myColorspace, arrayRef, locations);
            
            
            // Normalise the 0-1 ranged inputs to the width of the image
            CGPoint myCentrePoint = CGPointMake(0.5 * frame.size.width, 0.5 * frame.size.height);
            float myRadius = MIN(frame.size.width, frame.size.height) * 0.5;
            
            // Draw our Gradient
            CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, myCentrePoint,
                                         0, myCentrePoint, myRadius,
                                         kCGGradientDrawsAfterEndLocation);
            // Grab it as an Image
            UIImage *backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext();
            
            // Clean up
            CGColorSpaceRelease(myColorspace); // Necessary?
            CGGradientRelease(myGradient); // Necessary?
            UIGraphicsEndImageContext();
            
            return [UIColor colorWithPatternImage:backgroundColorImage];
        }
            
        case UIGradientStyleDiagonal: {
            
            //Set out gradient's colors
            backgroundGradientLayer.colors = cgColors;
            
            //Specify the direction our gradient will take
            [backgroundGradientLayer setStartPoint:CGPointMake(0.0, 1.0)];
            [backgroundGradientLayer setEndPoint:CGPointMake(1.0, 0.0)];
            
            //Convert our CALayer to a UIImage object
            UIGraphicsBeginImageContextWithOptions(backgroundGradientLayer.bounds.size,NO, [UIScreen mainScreen].scale);
            [backgroundGradientLayer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return [UIColor colorWithPatternImage:backgroundColorImage];
        }
            
        case UIGradientStyleTopToBottom:
        default: {
            
            //Set out gradient's colors
            backgroundGradientLayer.colors = cgColors;
            
            //Convert our CALayer to a UIImage object
            UIGraphicsBeginImageContextWithOptions(backgroundGradientLayer.bounds.size,NO, [UIScreen mainScreen].scale);
            [backgroundGradientLayer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return [UIColor colorWithPatternImage:backgroundColorImage];
        }
            
    }
}


@end
