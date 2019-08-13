//
//  LKDeviceNetInfo.h
//  App
//
//  Created by yier on 2018/6/15.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCarrier.h>
#import "LKWifiInfo.h"

@interface LKDeviceNetInfo : NSObject

+ (LKWifiInfo *)wifi;

/**
 蜂窝网络IP
 @return ip地址
 */
+ (NSString *)getIPAddress:(BOOL)preferIPv4;

+ (CTCarrier *)carrier;

+ (NSString *)networkType;

/**
 * 打印设备网络信息
 */
+ (void)printLKDeviceNetInfo;

@end
