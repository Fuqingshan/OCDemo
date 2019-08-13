//
//  View1.m
//  LLSHitTestView
//
//  Created by yier on 2017/12/20.
//  Copyright © 2017年 liulishuo. All rights reserved.
//

#import "View1.h"

@implementation View1

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    NSLog(@"View1: %p",self);
    UIView * view = [super hitTest:point withEvent:event];
    NSLog(@"View1 return :%p",view);
    return view;
}

@end
