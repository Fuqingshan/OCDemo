//
//  CustomButton.m
//  CustomBtn
//
//  Created by rimi on 14-1-20.
//  Copyright (c) 2014年 yangkai. All rights reserved.
//

#import "CustomButton.h"
#import "UIImage+Custom.h"
@implementation CustomButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!CGRectContainsPoint([self bounds], point))
        return nil;
    else
    {
        UIImage *displayedImage = [self imageForState:[self state]];
        if (displayedImage == nil) // No image found, try for background image
            displayedImage = [self backgroundImageForState:[self state]];
        if (displayedImage == nil) // No image could be found, fall back to
            return self;
        
        BOOL isTransparent = [displayedImage isPointTransparent:point];
        if (isTransparent)
            return nil;
        
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
