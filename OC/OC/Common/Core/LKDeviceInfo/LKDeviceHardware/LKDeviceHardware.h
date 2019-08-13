//
//  LKDeviceHardware.h
//  App
//
//  Created by yier on 2018/6/19.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKDeviceHardware : NSObject


/**
 cpu类型
 */
+ (NSString *) cpuType;

/**
 cpu子类型
 */
+ (NSString *) cpuSubType;

/**
 总内存
 @return 单位G
 */
+ (NSString *) totalMemory;

/**
可用内存
 @return 单位G
 */
+ (NSString *) freeMemory;

/**
 手机总空间
 @return 单位G
 */
+ (NSString *) totalDiskSpaceInBytes;

/**
 手机剩余空间
 @return 单位G
 */
+ (NSString *) freeDiskSpaceInBytes;

/**
 * 打印设备硬件信息
 */
+ (void)printLKDeviceNetInfo;
@end
