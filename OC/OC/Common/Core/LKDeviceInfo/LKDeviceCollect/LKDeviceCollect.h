//
//  LKDeviceCollect.h
//  App
//
//  Created by yier on 2018/6/15.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKDeviceCollect : NSObject

+ (NSString *)bundleID;

+ (NSString*)deviceModelName;//设备名称 e.g. "iPhone6s"

+ (NSString *)deviceName;//设备命名 e.g. "My iPhone"

+ (NSString *)systemName;//系统类型os e.g. "ios"

+ (NSString *)systemVersion;//e.g. "10.3"

+ (NSString *)model;//设备型号 e.g. @"iPhone", @"iPod touch"

+ (NSString *)localizedModel;

/**
 电池电量
 
 @return 0-100 百分比
 */
+ (int)batteryLevel;
//是否正在充电
+ (BOOL)isInCharge;
/**
 获取当前屏幕亮度
 
 @return 0-100 百分比
 */
+ (int)brightness;

/**
 设备是否越狱
 
 @return 越狱:yes,非越狱:no
 */
+ (BOOL)isJailBreak;

//是否为模拟器
+ (BOOL)isEmulator;

/**
 *得到本机现在用的语言
 * en-CN 或en  英文  zh-Hans-CN或zh-Hans  简体中文   zh-Hant-CN或zh-Hant  繁体中文    ja-CN或ja  日本  ......
 */
+ (NSString*)preferredLanguage;

//-------------------系统时间

/**
 开机时间
 */
+ (int64_t)bootTime;

/**
 从开机到现在的活动时间
 */
+ (int64_t)activeTime;

/**
 系统当前时间
 */
+ (int64_t)currentTime;

+ (NSString *)timeZone;

//-------------------唯一标识
/**
 广告标识符
 
 在 iOS13 及以前，系统会默认为用户开启允许追踪设置，我们可以简单的通过代码来获取到用户的 IDFA 标识符。

 AVCaptureDeviceInputvideoInput=[[AVCaptureDeviceInput alloc]initWithDevice:videoCaptureDevice error:nil];AVCaptureSessionsession=[[AVCaptureSession alloc]init];if([session canAddInput:videoInput]){[session addInput:videoInput];}[session startRunning];

  但是在 iOS14 中，这个判断用户是否允许被追踪的方法已经废弃。
 
 首先需要在 Info.plist 中配置" NSUserTrackingUsageDescription " 及描述文案，接着使用 AppTrackingTransparency 框架中的 ATTrackingManager 中的 requestTrackingAuthorizationWithCompletionHandler 请求用户权限，在用户授权后再去访问 IDFA 才能够获取到正确信息。
 */
+ (NSString *)idfa;

/**
 Vindor标示符
 */
+ (NSString *)idfv;

/**
 openudid
 */
+ (NSString *)openudid;//

/**
 uuid
 */
+ (NSString *)uuid;



/**
 * 打印设备信息
 */
+ (void)printDeviceCollect;

@end
