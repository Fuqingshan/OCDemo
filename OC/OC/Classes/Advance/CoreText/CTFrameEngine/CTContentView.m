//
//  CTContentView.m
//  CoreTextDemo
//
//  Created by yier on 2020/1/8.
//  Copyright © 2020 yier. All rights reserved.
//

#import "CTContentView.h"
#import <CoreText/CoreText.h>
#import "CoreTextUtils.h"

@interface CTContentView()<UIGestureRecognizerDelegate>
@property(nonatomic, strong) UITapGestureRecognizer *tapG;
@end

@implementation CTContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupEvent];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupEvent];
    }
    return self;
}

- (void)setupEvent{
    self.tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    self.tapG.delegate = self;
    [self addGestureRecognizer:self.tapG];
    self.userInteractionEnabled = YES;
}

- (void)tap:(UITapGestureRecognizer *)g{
    CGPoint point = [g locationInView:self];
    for (CoreTextImageData *imageData in self.data.imageArray) {
        //翻转坐标系，因为imageData中的坐标系是CoreText的坐标系
        CGRect imageRect = [self translateRect:imageData.imagePosition];
        if (CGRectContainsPoint(imageRect, point)) {
                //这里处理点击之后的逻辑
                NSLog(@"在范围内");
                break;
            }
    }
    
    CoreTextLinkData *linkData = [CoreTextUtils touchLinkInView:self atPoint:point data:self.data];
    //检测点击位置point是否在rect之内
    if (linkData) {
        NSLog(@"hint link");
    }
}

- (CGRect)translateRect:(CGRect)imageRect{
   CGPoint imagePosition = imageRect.origin;
   imagePosition.y = self.bounds.size.height - imageRect.origin.y - imageRect.size.height;
   CGRect rect = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height);
    
    return rect;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //底层框架左下角是起始点，UIKit左上角是起始点，这儿设置的翻转，注释掉可以看到正常的样子
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    if (self.data) {
        CTFrameDraw(self.data.ctFrame, context);
        for (CoreTextImageData *imgData in self.data.imageArray) {
            UIImage *img = [UIImage imageNamed:imgData.name];
            [img drawInRect:imgData.imagePosition];
            //图片上下颠倒
//            CGContextDrawImage(context, imgData.imagePosition,img.CGImage);
             //图片上下颠倒并拼接填充
//            CGContextDrawTiledImage(context, imgData.imagePosition, img.CGImage);
        }
    }
    CGContextRestoreGState(context);
}

@end
