//
//  HitTestBaseView.m
//  OC
//
//  Created by yier on 2019/4/7.
//  Copyright © 2019 yier. All rights reserved.
//

#import "HitTestBaseView.h"

@implementation HitTestBaseView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    NSLog(@"baseView: %p",self);
    UIView * view = [super hitTest:point withEvent:event];
    NSLog(@"baseView return :%p",view);
    return view;
}

@end
