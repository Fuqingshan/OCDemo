//
//  UILabel+Helper.h
//  iOSUtils
//
//  Created by chenfei on 27/10/2016.
//  Copyright © 2016 yier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Helper)

+ (instancetype)labelWithFont:(UIFont *)font
                    textColor:(UIColor *)textColor;

+ (instancetype)labelWithFont:(UIFont *)font
                    textColor:(UIColor *)textColor
                textAlignment:(NSTextAlignment)textAlignment;

/**
 行间距，内部会自动把text=nil,attributedText=text

 @param text text
 @param space 间距
 */
- (void)lk_setLineSpacingWithText:(NSString *)text space:(CGFloat)space;

// 另一种风格
@property(nonatomic, readonly) UILabel *(^setFrame)(CGRect frame);
@property(nonatomic, readonly) UILabel *(^setBgColor)(UIColor *bgColor);
@property(nonatomic, readonly) UILabel *(^setTextAlignment)(NSTextAlignment textAlignment);
@property(nonatomic, readonly) UILabel *(^setLineBreakMode)(NSLineBreakMode lineBreakMode);
@property(nonatomic, readonly) UILabel *(^setFont)(UIFont *font);
@property(nonatomic, readonly) UILabel *(^setTextColor)(UIColor *textColor);
@property(nonatomic, readonly) UILabel *(^setText)(NSString *text);
@property(nonatomic, readonly) UILabel *(^setAttributedText)(NSAttributedString *attributedText);

@end
