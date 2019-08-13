//
//  LKPermissionCheck.h
//  App
//
//  Created by yier on 2018/10/18.
//  Copyright © 2018 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKPermissionCheck : NSObject

/**
 是否有通讯录权限
 */
+ (BOOL)hasABAuthorization;

/**
 是否有通知权限
 */
+ (void)hasNotifacationAuthorizationComplete:(void(^)(BOOL auth))completeBlock;

@end

NS_ASSUME_NONNULL_END
