//
//  LKPermissionCheck.h
//  App
//
//  Created by yier on 2018/10/18.
//  Copyright © 2018 yooli. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM( NSInteger,LKAuthorizationStatus){
    LKAuthorizationStatusNotDetermined,///<没有询问过用户授权
    LKAuthorizationStatusShowGuide,///<询问过用户，被拒绝了或者用户没有权限授权，受到父母监控,可弹窗引导用户授权
    LKAuthorizationStatusAuthorized,///<可以正常使用
};

@interface LKPermissionCheck : NSObject

/**
 是否有定位权限,设备不支持也当成未决定
 */
+ (LKAuthorizationStatus)hasLocationAuthorization;

/**
 是否有通讯录权限
 */
+ (LKAuthorizationStatus)hasABAuthorization;

/**
 是否有视频权限
 */
+ (LKAuthorizationStatus)hasVideoAuthorization;

/**
 是否有音频权限
 */
+ (LKAuthorizationStatus)hasAudioAuthorization;

/**
 是否有通知权限
 */
+ (void)hasNotifacationAuthorizationComplete:(void(^)(BOOL auth))completeBlock;

#pragma mark - 请求权限

/**
 请求视频权限
 */
+ (void)requestVideoAuthorization:(dispatch_block_t)successBlock failureBlock:(dispatch_block_t)failureBlock;

/**
 请求音频权限
 */
+ (void)requestAudioAuthorization:(dispatch_block_t)successBlock failureBlock:(dispatch_block_t)failureBlock;

@end
