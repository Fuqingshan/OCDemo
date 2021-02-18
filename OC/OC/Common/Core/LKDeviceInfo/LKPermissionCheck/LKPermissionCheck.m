//
//  LKPermissionCheck.m
//  App
//
//  Created by yier on 2018/10/18.
//  Copyright © 2018 yooli. All rights reserved.
//

#import "LKPermissionCheck.h"
#import <Contacts/Contacts.h>
#import <CoreLocation/CLLocationManager.h>
#import <AVFoundation/AVFoundation.h>

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@implementation LKPermissionCheck

#pragma mark - 是否有定位权限
+ (LKAuthorizationStatus)hasLocationAuthorization{
    //设备是否支持
    if (![CLLocationManager locationServicesEnabled]) {
        return LKAuthorizationStatusNotDetermined;
    }
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            return LKAuthorizationStatusNotDetermined;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            return LKAuthorizationStatusShowGuide;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return LKAuthorizationStatusAuthorized;
    }
}


#pragma mark - 是否有通讯录权限
+ (LKAuthorizationStatus)hasABAuthorization{
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (status) {
        case CNAuthorizationStatusNotDetermined:
            return LKAuthorizationStatusNotDetermined;
        case CNAuthorizationStatusRestricted:
        case CNAuthorizationStatusDenied:
            return LKAuthorizationStatusShowGuide;
        case CNAuthorizationStatusAuthorized:
            return LKAuthorizationStatusAuthorized;
    }
}

#pragma mark - 是否有视频权限
+ (LKAuthorizationStatus)hasVideoAuthorization{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
            return LKAuthorizationStatusNotDetermined;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            return LKAuthorizationStatusShowGuide;
        case AVAuthorizationStatusAuthorized:
            return LKAuthorizationStatusAuthorized;
    }
}

#pragma mark - 是否有音频权限
+ (LKAuthorizationStatus)hasAudioAuthorization{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
            return LKAuthorizationStatusNotDetermined;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            return LKAuthorizationStatusShowGuide;
        case AVAuthorizationStatusAuthorized:
            return LKAuthorizationStatusAuthorized;
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

#pragma mark - 请求视频权限
+ (void)requestVideoAuthorization:(dispatch_block_t)successBlock failureBlock:(dispatch_block_t)failureBlock{
    [LKPermissionCheck requestMediaAuthorization:AVMediaTypeVideo successBlock:successBlock failureBlock:failureBlock];
}

#pragma mark - 请求音频权限
+ (void)requestAudioAuthorization:(dispatch_block_t)successBlock failureBlock:(dispatch_block_t)failureBlock{
    [LKPermissionCheck requestMediaAuthorization:AVMediaTypeAudio successBlock:successBlock failureBlock:failureBlock];
}

#pragma mark - 请求视频、音频权限(AVMediaTypeVideo || AVMediaTypeAudio)
+ (void)requestMediaAuthorization:(AVMediaType)type
                     successBlock:(dispatch_block_t)successBlock
                     failureBlock:(dispatch_block_t)failureBlock{
    [AVCaptureDevice requestAccessForMediaType:type completionHandler:^(BOOL granted) {
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            if (granted) {
                !successBlock?:successBlock();
            } else {
                !failureBlock?:failureBlock();
            }
        });
    }];
}

@end
