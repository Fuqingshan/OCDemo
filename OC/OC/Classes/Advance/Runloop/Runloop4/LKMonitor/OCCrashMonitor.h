//
//  OCCrashMonitor.h
//  App
//
//  Created by yier on 2019/9/30.
//  Copyright © 2019 yooli. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const OCAppOnException;///<app即将崩溃的通知，可用crashAfterDelay保活处理关键数据存储等操作

@interface OCCrashMonitor : NSObject

+ (void)registerExceptionHandler;

/// 设置崩溃后保活时间，切勿直接使用，调用之后会一直执行runloop，因此处理事件要写在这个之前
/// @param delay 崩溃后保活时间
/*
 [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:OCAppOnException object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
     [MBProgressHUD OC_showInfoWithStatus:[NSString stringWithFormat:@"app将要崩溃了"] hideAfterDelay:2];
     [OCCrashMonitor crashAfterDelay:5];
 }];
 */
+ (void)crashAfterDelay:(NSTimeInterval)delay;

@end

