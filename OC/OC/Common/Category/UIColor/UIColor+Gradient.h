//
//  UIColor+Gradient.h
//  TestBethelCircle
//
//  Created by yier on 2018/5/24.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, UIGradientStyle) {
    /**
     *  Returns a gradual blend between colors originating at the leftmost point of an object's frame, and ending at the rightmost point of the object's frame.
     *
     *  @since 1.0
     */
    UIGradientStyleLeftToRight,
    /**
     *  Returns a gradual blend between colors originating at the center of an object's frame, and ending at all edges of the object's frame. NOTE: Supports a Maximum of 2 Colors.
     *
     *  @since 1.0
     */
    UIGradientStyleRadial,
    /**
     *  Returns a gradual blend between colors originating at the topmost point of an object's frame, and ending at the bottommost point of the object's frame.
     *
     *  @since 1.0
     */
    UIGradientStyleTopToBottom,
    UIGradientStyleDiagonal,
    UIGradientStyleArc,
};

@interface UIColor (Gradient)
/**
 设置渐变色
 
 @param gradientStyle 样式
 @param frame 渐变的view
 @param lineWidth UIGradientStyleArc 线的宽度,其他样式用不到
 @param colors 颜色渐变 必须
 @param percent 百分比
 */
+ (UIColor *)colorWithGradientStyle:(UIGradientStyle)gradientStyle withFrame:(CGRect)frame lineWidth:(CGFloat)lineWidth andColors:(NSArray<UIColor *> *)colors percent:(CGFloat )percent;
@end
