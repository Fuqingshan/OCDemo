//
//  NetworkErrorView.m
//  App
//
//  Created by xiaoping on 2018/6/27.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "NetworkErrorView.h"

@implementation NetworkErrorView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.imageView = [[UIImageView alloc] initWithImage:[self wifiImg]];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
        
        self.textLabel = [UILabel new];
        self.textLabel.text = @"呀，网络出小差了~";
        self.textLabel.font = PingFangSCRegular(15);;
        self.textLabel.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textLabel];
        
        UIColor *btnColor = [UIColor colorWithRed:252/255.0 green:137/255.0 blue:54/255.0 alpha:1/1.0];
        self.button = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.button setTitleColor:btnColor forState:UIControlStateNormal];
        [self.button setTitle:@"重新加载" forState:UIControlStateNormal];
        self.button.titleLabel.font = PingFangSCMedium(16.0);
        self.button.layer.borderColor = btnColor.CGColor;
        self.button.layer.borderWidth = 1;
        self.button.layer.cornerRadius = 4;
        [self addSubview:self.button];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(71);
            make.centerX.equalTo(self);
            make.width.height.offset(100);
        }];
        
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView).offset(96);
            make.left.right.offset(0);
            make.height.offset(22);
        }];
        
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textLabel.mas_bottom).offset(46);
            make.width.offset(166);
            make.height.offset(40);
            make.centerX.equalTo(self);
        }];
    }
    return self;
}

- (UIImage *)wifiImg{
    NSString *base64 = @"data:image/png;base64,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";
    UIImage *img = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:base64 options:NSDataBase64DecodingIgnoreUnknownCharacters]];
    return img;
}

@end
