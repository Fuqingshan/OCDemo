//
//  UIImage+Helper.h
//  App
//
//  Created by chenfei on 03/12/2016.
//  Copyright © 2016 yier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helper)

- (UIImage *)imageByAddTopRightDotWithColor:(UIColor *)color;

+ (UIImage *)lk_imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)lk_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius;

- (UIImage*)blurredImage;
@end
