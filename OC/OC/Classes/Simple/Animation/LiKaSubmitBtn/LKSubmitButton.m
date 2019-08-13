//
//  LKSubmitButton.m
//  Testaaa
//
//  Created by yier on 2018/8/8.
//  Copyright © 2018 yier. All rights reserved.
//

#import "LKSubmitButton.h"
#import "UIImage+SubmitBtn.h"

@interface LKSubmitButton()
@property (nonatomic, strong) UIImageView *submitImg;
@property (nonatomic, strong) UIImageView *shadowImg;
@property (nonatomic, strong) UILabel *submitLabel;
@end

@implementation LKSubmitButton

- (instancetype)initWithFrame:(CGRect)frame
{
    CGFloat defaultHeight = frame.size.height;
    CGFloat reallyHeight = [self calculateReallyHeightByFrame:frame];
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, reallyHeight)];
    if (self) {
        CGRect submitImgFrame = CGRectMake(0, 0, frame.size.width, defaultHeight);
        self.submitImg = [[UIImageView alloc] initWithFrame:submitImgFrame];
        [self addSubview:self.submitImg];
        
        self.shadowImg = [[UIImageView alloc] initWithFrame:CGRectMake(-20,0, frame.size.width + 20.0f * 2, reallyHeight)];
        self.shadowImg.contentMode = UIViewContentModeScaleAspectFill;
        self.shadowImg.layer.masksToBounds = YES;
        self.shadowImg.alpha = 0.8;
        [self addSubview:self.shadowImg];
        
        self.submitLabel = [[UILabel alloc] initWithFrame:self.submitImg.frame];
        self.submitLabel.textAlignment = NSTextAlignmentCenter;
        self.submitLabel.textColor = [UIColor whiteColor];
        self.submitLabel.text = @"完成";
        [self addSubview:self.submitLabel];
        
        @autoreleasepool{
            __block UIImage *submitImg = [UIImage submitImageWithFrame:submitImgFrame];
            self.submitImg.image = submitImg;
            dispatch_async(dispatch_queue_create(0, 0), ^{
                submitImg = [self gaussiBlurByImage:submitImg radius:17];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.shadowImg.image = submitImg;
                });
            });
        }
    }
    return self;
}

#pragma mark - 计算出submitButton的真实高度
- (CGFloat)calculateReallyHeightByFrame:(CGRect)frame{
    CGFloat reallyHeight = frame.size.height;
    //高斯模糊的阴影模块左右间隔25，上面开始距离11
//    reallyHeight = (frame.size.width - 25 *2)/frame.size.width * frame.size.height + 11.0f;
    reallyHeight =  frame.size.height + 15.0f;

    return reallyHeight;
}

#pragma mark - 滤镜增加模糊
- (UIImage *)gaussiBlurByImage:(UIImage *)img radius:(CGFloat)number{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [[CIImage alloc] initWithImage:img];
    // create gaussian blur filter
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:number] forKey:@"inputRadius"];
    // blur image
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return image;
}

@end
