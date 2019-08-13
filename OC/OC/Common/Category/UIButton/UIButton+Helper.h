//
//  UIButton+Helper.h
//  App
//
//  Created by chenfei on 03/11/2016.
//  Copyright © 2016 yier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Helper)

+ (instancetype)underlineButtonWithTitle:(NSString *)title
                                    font:(UIFont *)font
                             normalColor:(UIColor *)normalColor
                        highlightedColor:(UIColor *)highlightedColor;

+ (instancetype)borderButtonWithTitle:(NSString *)title
                                 font:(UIFont *)font
                          normalColor:(UIColor *)normalColor
                     highlightedColor:(UIColor *)highlightedColor;

+ (instancetype)buttonWithTitle:(NSString *)title
                           font:(UIFont *)font
                    normalColor:(UIColor *)normalColor
               highlightedColor:(UIColor *)highlightedColor;

+ (instancetype)imageTitleButtonWithImage:(UIImage *)image
                                    title:(NSString *)title
                                     font:(UIFont *)font
                              normalColor:(UIColor *)normalColor
                         highlightedColor:(UIColor *)highlightedColor
                                  spacing:(CGFloat)spacing;
+ (instancetype)imageTitleButtonWithImageRight:(UIImage *)image
                                         title:(NSString *)title
                                          font:(UIFont *)font
                                   normalColor:(UIColor *)normalColor
                              highlightedColor:(UIColor *)highlightedColor
                                       spacing:(CGFloat)spacing;


+ (instancetype)buttonWithImage:(UIImage *)image;

- (void)addTarget:(id)target action:(SEL)action;

@property(nonatomic, strong) UIImage *normalBackgroundImage;
@property(nonatomic, strong) UIImage *highlightedBackgroundImage;
@property(nonatomic, strong) UIImage *disabledBackgroundImage;
@property(nonatomic, strong) UIImage *normalImage;
@property(nonatomic, strong) UIImage *highlightedImage;
@property(nonatomic, strong) UIImage *selectedImage;
@property(nonatomic, strong) UIFont *titleFont;
@property(nonatomic, strong) NSString *normalTitle;
@property(nonatomic, strong) UIColor *normalTitleColor;
@property(nonatomic, strong) UIColor *highlightedTitleColor;
@property(nonatomic, strong) UIColor *disabledTitleColor;
@property(nonatomic, strong) UIColor *selectedTitleColor;

/**
 * 移动titleLabel
 *
 * @param dx 正值向右，负值向左
 * @param dy 正值向下，负值向上
 */
- (void)moveTitleByDx:(CGFloat)dx dy:(CGFloat)dy;

///设置渐变边框
- (void)setGradientBorderLine;

/**
 * 移动imageView
 *
 * @param dx 正值向右，负值向左
 * @param dy 正值向下，负值向上
 */
- (void)moveImageByDx:(CGFloat)dx dy:(CGFloat)dy;

@end
