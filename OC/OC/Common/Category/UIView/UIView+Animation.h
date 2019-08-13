//
//  UIView+Animation.h
//  App
//
//  Created by yier on 2018/5/23.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Animation)
+ (void)springWithView:(UIView *)view
              duration:(NSTimeInterval)duration
                 delay:(NSTimeInterval)delay
            completion:(void (^)(BOOL finished))completion;

+ (void)addRoundedByView:(UIView *)view
                 Corners:(UIRectCorner)corners
               withRadii:(CGSize)radii
                viewRect:(CGRect)rect;
@end
