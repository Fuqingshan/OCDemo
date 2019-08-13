//
//  HitButton.m
//  AAA
//
//  Created by yier on 2018/4/4.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "HitButton.h"

@implementation HitButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect rect = CGRectMake(self.bounds.origin.x - 50, self.bounds.origin.y -50, self.bounds.size.width + 100, self.bounds.size.height + 100);
    if (CGRectEqualToRect(rect, self.bounds)) {
        return [super hitTest:point withEvent:event];
    }
    
    return CGRectContainsPoint(rect, point)?self:nil;
}

@end
