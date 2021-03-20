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
    //相当于在按钮周围增加了50的点击范围
    CGRect rect = CGRectMake(self.bounds.origin.x - 50, self.bounds.origin.y -50, self.bounds.size.width + 100, self.bounds.size.height + 100);
   
    UIView * view = [super hitTest:point withEvent:event];
    //如果在范围内，否则看父视图上平级的有没有能响应的视图
    return CGRectContainsPoint(rect, point)?self:view;
}

@end
