//
//  UIView+Animation.m
//  App
//
//  Created by yier on 2018/5/23.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)
+ (void)springWithView:(UIView *)view
              duration:(NSTimeInterval)duration
                 delay:(NSTimeInterval)delay
            completion:(void (^)(BOOL finished))completion{
    [UIView animateKeyframesWithDuration:duration
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionBeginFromCurrentState |UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0
                                                          relativeDuration:1/3.f
                                                                animations:^{
                                                                    view.transform = CGAffineTransformMakeScale(1.05, 1.05);
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:1/3.f
                                                          relativeDuration:2/3.f
                                                                animations:^{
                                                                    view.transform = CGAffineTransformMakeScale(0.95, 0.95);
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:2/3.f
                                                          relativeDuration:3/3.f
                                                                animations:^{
                                                                    view.transform = CGAffineTransformIdentity;;
                                                                }];
                              } completion:completion];
    
}

+ (void)addRoundedByView:(UIView *)view
                 Corners:(UIRectCorner)corners
               withRadii:(CGSize)radii
                viewRect:(CGRect)rect{
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    view.layer.mask = shape;
}

@end
