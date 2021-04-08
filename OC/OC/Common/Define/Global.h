//
//  Global.h
//  OC
//
//  Created by yier on 2019/2/12.
//  Copyright © 2019 yier. All rights reserved.
//

#ifndef dispatch_queue_async_safe
#define dispatch_queue_async_safe(queue, block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {\
block();\
} else {\
dispatch_async(queue, block);\
}
#endif

#define  AdjustsScrollViewInsets(vc,scrollView) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
if ([UIScrollView instancesRespondToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]) {\
[scrollView   performSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:") withObject:@(2)];\
} else {\
vc.automaticallyAdjustsScrollViewInsets = NO;\
}\
_Pragma("clang diagnostic pop") \
} while (0)

#define kMainApplicationWidth    ([UIScreen mainScreen].applicationFrame).size.width    //应用程序的宽度
#define kMainApplicationHeight   ([UIScreen mainScreen].applicationFrame).size.height   //应用程序的高度
#define kMainScreenWidth         ([UIScreen mainScreen].bounds).size.width              //屏幕的宽度
#define kMainScreenHeight        ([UIScreen mainScreen].bounds).size.height             //屏幕的高度
#define kStatusBarHeight         ([UIApplication sharedApplication].statusBarFrame.size.height)//状态栏高度
#define kTabbarHeight            ([OCRouter shareInstance].rootViewController.tabbarVC.tabBar.frame.size.height) //底部tabbar的高度
#define kHomeIndicatorHeight       (kTabbarHeight - 49.0f)  //底部homeIndicator的高度

typedef void(^VOIDBlockWithModel)(id model);
typedef void(^VOIDBlockWithTwoModel)(id model1,id model2);

#import "UIFont+Safe.h"

#define PingFangSCRegular(point) [UIFont lk_fontWithName:@"PingFangSC-Regular" size:point]///<常规
#define PingFangSCMedium(point) [UIFont lk_fontWithName:@"PingFangSC-Medium" size:point]///<中黑
#define PingFangSCSemibold(point) [UIFont lk_fontWithName:@"PingFangSC-Semibold" size:point]///<中粗

#define RTMPURL @"rtmp://192.168.199.154:1935/rtmplive/room"//本地推流地址,ip为当前电脑ip


#define kPlayerViewTag 'ZFPT'
