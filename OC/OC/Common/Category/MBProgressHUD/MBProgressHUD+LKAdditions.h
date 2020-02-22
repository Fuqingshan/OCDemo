//
//  MBProgressHUD+SCAdditions.h
//
//  MBProgressHUD+LKAdditions.h
//  App
//
//  Created by yier on 2018/8/23.
//  Copyright © 2018 yier. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (LKAdditions)

/**
 持续存在的菊花，需要手动dismiss，如果加到window上，记得dismiss。
 如果需要弹出的HUD支持交互，使用返回的instance.userInteractionEnabled = NO
 
 @param message 内容,没有则只展示菊花
 @param view 用来展示的view
 @return MBProgressHUD instance
 */
+ (instancetype)lk_showRequestHUDWithMessage:(NSString *)message inView:(UIView *)view;

/**
 只展示内容，没有对应的图标。
 如果需要弹出的HUD支持交互，使用返回的instance.userInteractionEnabled = NO

 @param title 标题
 @param message 内容
 @param delay 延迟几秒之后消失
 @return MBProgressHUD instance
 */
+ (instancetype)lk_showHUDWithTitle:(NSString *)title
                            message:(NSString *)message
                     hideAfterDelay:(NSTimeInterval)delay;

/**
 感叹号❗️。
 如果需要弹出的HUD支持交互，使用返回的instance.userInteractionEnabled = NO

 @param message 内容
 @param delay 延迟几秒之后消失
 @return MBProgressHUD instance
 */
+ (instancetype)lk_showInfoWithStatus:(NSString *)message hideAfterDelay:(NSTimeInterval)delay;

/**
 成功。
 如果需要弹出的HUD支持交互，使用返回的instance.userInteractionEnabled = NO

 @param message 内容
 @param delay 延迟几秒之后消失
 @return MBProgressHUD instance
 */
+ (instancetype)lk_showSuccessWithStatus:(NSString *)message hideAfterDelay:(NSTimeInterval)delay;

/**
 异常。
 如果需要弹出的HUD支持交互，使用返回的instance.userInteractionEnabled = NO

 @param message 内容
 @param delay 延迟几秒之后消失
 @return MBProgressHUD instance
 */
+ (instancetype)lk_showErrorWithStatus:(NSString *)message hideAfterDelay:(NSTimeInterval)delay;

/**
 dismiss all, 这个方法会dismiss KeyWindow 上全部的MBProgressHUD
 
 要dismiss 某一个视图上的HUD用：
 + (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated;
 
 dismiss 某一个用：
 - (void)hideAnimated:(BOOL)animated
 - (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay
 */
+ (void)lk_dismiss;
@end
