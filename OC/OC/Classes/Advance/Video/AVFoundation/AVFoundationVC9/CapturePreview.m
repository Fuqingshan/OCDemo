//
//  CapturePreview.m
//  OC
//
//  Created by yier on 2020/2/26.
//  Copyright © 2020 yier. All rights reserved.
//
//录制视频的预览界面
#import "CapturePreview.h"

@implementation CapturePreview

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.transform = CGAffineTransformMakeRotation(M_PI/2);
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)setCiImage:(UIImage *)ciImage{
    _ciImage = ciImage;
    self.imageView.image = ciImage;
}

@end
