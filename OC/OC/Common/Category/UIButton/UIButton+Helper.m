//
//  UIButton+Helper.m
//  App
//
//  Created by chenfei on 03/11/2016.
//  Copyright © 2016 yier. All rights reserved.
//

#import "UIButton+Helper.h"

@implementation UIButton (Helper)

+ (instancetype)underlineButtonWithTitle:(NSString *)title
                                    font:(UIFont *)font
                             normalColor:(UIColor *)normalColor
                        highlightedColor:(UIColor *)highlightedColor
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;

    NSRange titleRange = { 0, [title length] };

    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title];
    [attrTitle addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:titleRange];
    [attrTitle addAttribute:NSForegroundColorAttributeName value:normalColor range:titleRange];
    [attrTitle addAttribute:NSFontAttributeName value:font range:titleRange];
    [button setAttributedTitle:attrTitle forState:UIControlStateNormal];

    NSMutableAttributedString *attrTitleH = [[NSMutableAttributedString alloc] initWithString:title];
    [attrTitleH addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:titleRange];
    [attrTitleH addAttribute:NSForegroundColorAttributeName value:highlightedColor range:titleRange];
    [attrTitleH addAttribute:NSFontAttributeName value:font range:titleRange];
    [button setAttributedTitle:attrTitleH forState:UIControlStateHighlighted];

    return button;
}

+ (instancetype)borderButtonWithTitle:(NSString *)title
                                 font:(UIFont *)font
                          normalColor:(UIColor *)normalColor
                     highlightedColor:(UIColor *)highlightedColor
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    button.layer.borderColor = normalColor.CGColor;
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 2;
    button.titleFont = font;
    button.normalTitleColor = normalColor;
    button.highlightedTitleColor = highlightedColor;
    button.normalTitle = title;
    [button addTarget:button action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:button action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:button action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpOutside];
    [button addTarget:button action:@selector(touchUp:) forControlEvents:UIControlEventTouchDragOutside];
    return button;
}

+ (instancetype)buttonWithTitle:(NSString *)title
                           font:(UIFont *)font
                    normalColor:(UIColor *)normalColor
               highlightedColor:(UIColor *)highlightedColor
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    button.titleFont = font;
    button.normalTitleColor = normalColor;
    button.highlightedTitleColor = highlightedColor;
    button.normalTitle = title;
    return button;
}

+ (instancetype)imageTitleButtonWithImage:(UIImage *)image
                                    title:(NSString *)title
                                     font:(UIFont *)font
                              normalColor:(UIColor *)normalColor
                         highlightedColor:(UIColor *)highlightedColor
                                  spacing:(CGFloat)spacing
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    button.titleFont = font;
    button.normalTitleColor = normalColor;
    button.highlightedTitleColor = highlightedColor;
    button.normalTitle = title;
    button.normalImage = image;
    [button moveImageByDx:-spacing/2 dy:0];
    [button moveTitleByDx:spacing/2 dy:0];
    return button;
}

+ (instancetype)imageTitleButtonWithImageRight:(UIImage *)image
                                         title:(NSString *)title
                                          font:(UIFont *)font
                                   normalColor:(UIColor *)normalColor
                              highlightedColor:(UIColor *)highlightedColor
                                       spacing:(CGFloat)spacing
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.exclusiveTouch = YES;
    button.titleFont = font;
    button.normalTitleColor = normalColor;
    button.highlightedTitleColor = highlightedColor;
    button.normalTitle = title;
    button.normalImage = image;
    
    [button moveImageByDx:button.titleLabel.bounds.size.width+65 dy:0];
    [button moveTitleByDx:-image.size.width dy:0];
    return button;
}

+ (instancetype)buttonWithImage:(UIImage *)image
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    button.normalImage = image;
    return button;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];

    if (enabled)
        self.layer.borderColor = self.normalTitleColor.CGColor;
    else
        self.layer.borderColor = self.disabledTitleColor.CGColor;
}

- (void)touchDown:(UIButton *)sender
{
    sender.layer.borderColor = sender.highlightedTitleColor.CGColor;
}

- (void)touchUp:(UIButton *)sender
{
    sender.layer.borderColor = sender.normalTitleColor.CGColor;
}

#pragma mark -

- (void)addTarget:(id)target action:(SEL)action
{
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)setNormalBackgroundImage:(UIImage *)image
{
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

- (UIImage *)normalBackgroundImage
{
    return [self backgroundImageForState:UIControlStateNormal];
}

- (void)setHighlightedBackgroundImage:(UIImage *)highlightedBackgroundImage
{
    [self setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
}

- (UIImage *)highlightedBackgroundImage
{
    return [self backgroundImageForState:UIControlStateHighlighted];
}

- (void)setDisabledBackgroundImage:(UIImage *)disabledBackgroundImage
{
    [self setBackgroundImage:disabledBackgroundImage forState:UIControlStateDisabled];
}

- (UIImage *)disabledBackgroundImage
{
    return [self backgroundImageForState:UIControlStateDisabled];
}

- (void)setNormalImage:(UIImage *)image
{
    [self setImage:image forState:UIControlStateNormal];
}

- (UIImage *)normalImage
{
    return [self imageForState:UIControlStateNormal];
}

- (void)setSelectedImage:(UIImage *)selectedImage
{
    [self setImage:selectedImage forState:UIControlStateSelected];
}

- (UIImage *)selectedImage
{
    return [self imageForState:UIControlStateNormal];
}

- (void)setHighlightedImage:(UIImage *)image
{
    [self setImage:image forState:UIControlStateHighlighted];
}

- (UIImage *)highlightedImage
{
    return [self imageForState:UIControlStateHighlighted];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    self.titleLabel.font = titleFont;
}

- (UIFont *)titleFont
{
    return self.titleLabel.font;
}

- (void)setNormalTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
}

- (NSString *)normalTitle
{
    return [self titleForState:UIControlStateNormal];
}

- (void)setNormalTitleColor:(UIColor *)color
{
    [self setTitleColor:color forState:UIControlStateNormal];
}

- (UIColor *)normalTitleColor
{
    return [self titleColorForState:UIControlStateNormal];
}

- (void)setHighlightedTitleColor:(UIColor *)highlightedTitleColor
{
    [self setTitleColor:highlightedTitleColor forState:UIControlStateHighlighted];
}

- (UIColor *)highlightedTitleColor
{
    return [self titleColorForState:UIControlStateHighlighted];
}

- (UIColor *)disabledTitleColor
{
    return [self titleColorForState:UIControlStateDisabled];
}

- (void)setDisabledTitleColor:(UIColor *)disabledTitleColor
{
    [self setTitleColor:disabledTitleColor forState:UIControlStateDisabled];
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor
{
    [self setTitleColor:selectedTitleColor forState:UIControlStateSelected];
}

- (UIColor *)selectedTitleColor
{
    return [self titleColorForState:UIControlStateSelected];
}

- (void)moveTitleByDx:(CGFloat)dx dy:(CGFloat)dy
{
    self.titleEdgeInsets = UIEdgeInsetsMake(dy, dx, -dy, -dx);
}

- (void)moveImageByDx:(CGFloat)dx dy:(CGFloat)dy
{
    self.imageEdgeInsets = UIEdgeInsetsMake(dy, dx, -dy, -dx);
}

- (void)setGradientBorderLine {
    self.normalBackgroundImage = [UIImage imageNamed:@"button_line"];
}

@end
