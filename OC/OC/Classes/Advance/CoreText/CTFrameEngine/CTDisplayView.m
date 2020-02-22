//
//  CTDisplayView.m
//  CoreTextDemo
//
//  Created by yier on 2020/1/8.
//  Copyright © 2020 yier. All rights reserved.
//

#import "CTDisplayView.h"
#import <CoreText/CoreText.h>

@implementation CTDisplayView

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //底层框架左下角是起始点，UIKit左上角是起始点，这儿设置的翻转，注释掉可以看到正常的样子
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    
    //测试不同绘制区域带来的变化
    CGMutablePathRef path = CGPathCreateMutable();
    NSAttributedString *attString;
    BOOL isStyle1 = NO;
    if (isStyle1) {
        CGPathAddRect(path, NULL, self.bounds);
          attString = [[NSAttributedString alloc] initWithString:@"Hello World!"];
    }else{
        CGPathAddEllipseInRect(path, NULL, self.bounds);
        attString = [[NSAttributedString alloc] initWithString:@"Hello World!"
                     @"创建绘制的区域，CoreText本身支持各种文字排版的区域,"
                     @"我们这里简单的将整个UIView作为排版的区域。"
                     @"为了加深理解l，建议读者将isStyle1状态切换，"
                     @"测试b设置不同的绘制区域带来的界面变化。"];
    }
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attString length]), path, NULL);
    
    CTFrameDraw(frame, context);
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

@end
