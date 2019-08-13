//
//  UIColor+Hex.h
//  GNum
//
//  Created by niko on 15/4/29.
//  Copyright (c) 2015年 globalroam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)lk_alphaColorWithHexString:(NSString *)alphaColor;

+ (UIColor *)lk_colorWithHexString:(NSString *)color;

//从十六进制字符串获取颜色，
// color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)lk_colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end
