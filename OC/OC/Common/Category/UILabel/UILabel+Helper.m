//
//  UILabel+Helper.m
//  iOSUtils
//
//  Created by chenfei on 27/10/2016.
//  Copyright © 2016 yier. All rights reserved.
//

#import "UILabel+Helper.h"

@implementation UILabel (Helper)

+ (instancetype)labelWithFont:(UIFont *)font
                    textColor:(UIColor *)textColor
{
    return [self labelWithFont:font textColor:textColor textAlignment:NSTextAlignmentLeft];
}

+ (instancetype)labelWithFont:(UIFont *)font
                    textColor:(UIColor *)textColor
                textAlignment:(NSTextAlignment)textAlignment
{
    UILabel *label = [[self alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.font = font;
    label.textColor = textColor;
    label.textAlignment = textAlignment;
    label.numberOfLines = 0;
    return label;
}

#pragma mark -

- (UILabel *(^)(CGRect))setFrame
{
    return ^(CGRect frame) {
        self.frame = frame;
        return self;
    };
}

- (UILabel *(^)(UIColor *))setBgColor
{
    return ^(UIColor *bgColor) {
        self.backgroundColor = bgColor;
        return self;
    };
}

- (UILabel *(^)(NSTextAlignment))setTextAlignment
{
    return ^(NSTextAlignment textAlignment) {
        self.textAlignment = textAlignment;
        return self;
    };
}

- (UILabel *(^)(NSLineBreakMode))setLineBreakMode
{
    return ^(NSLineBreakMode lineBreakMode) {
        self.lineBreakMode = lineBreakMode;
        return self;
    };
}

- (UILabel *(^)(UIFont *))setFont
{
    return ^(UIFont *font) {
        self.font = font;
        return self;
    };
}

- (UILabel *(^)(UIColor *))setTextColor
{
    return ^(UIColor *textColor) {
        self.textColor = textColor;
        return self;
    };
}

- (UILabel *(^)(NSString *))setText
{
    return ^(NSString *text) {
        self.text = text;
        return self;
    };
}

- (UILabel *(^)(NSAttributedString *))setAttributedText
{
    return ^(NSAttributedString *attributedText) {
        self.attributedText = attributedText;
        return self;
    };
}

- (void)lk_setLineSpacingWithText:(NSString *)text space:(CGFloat)space {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:space];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    self.text = nil;
    self.attributedText = attributedString;
}

@end
