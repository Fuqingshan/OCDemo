//
//  LKPermissionCheck.m
//  App
//
//  Created by yier on 2018/10/18.
//  Copyright © 2018 yier. All rights reserved.
//

#import "LKPermissionCheck.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@implementation LKPermissionCheck

#pragma mark - 是否有通讯录权限
+ (BOOL)hasABAuthorization{
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (status) {
        case CNAuthorizationStatusNotDetermined:
        case CNAuthorizationStatusRestricted:
        case CNAuthorizationStatusDenied:
            return NO;
        case CNAuthorizationStatusAuthorized:
            return YES;
    }
}

#pragma mark - 是否有通知权限
+ (void)hasNotifacationAuthorizationComplete:(void(^)(BOOL auth))completeBlock{
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            //如果授权状态是notDetermined，那其他所有的setting都是0（notSupported）
            //如果授权状态是deny，那所有其他的setting都是1（disabled）
            //如果授权状态是authorized，其他设置的值才有意义
            dispatch_async(dispatch_get_main_queue(), ^{
                if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                    !completeBlock?:completeBlock(YES);
                } else {
                    !completeBlock?:completeBlock(NO);
                }
            });
        }];
    }else{
        //YES if the app is registered for remote notifications and received its device token or NO if registration has not occurred, has failed, or has been denied by the user.
        BOOL auth = [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
        !completeBlock?:completeBlock(auth);
    }
}

@end
