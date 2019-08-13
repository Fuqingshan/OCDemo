//
//  UIImage+SubmitBtn.h
//  Testaaa
//
//  Created by yier on 2018/8/8.
//  Copyright © 2018 yier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SubmitBtn)


/**
 根据尺寸返回对应的提交按钮的未模糊的背景图

 @param frame 尺寸
 */
+ (UIImage *)submitImageWithFrame:(CGRect)frame;

@end
