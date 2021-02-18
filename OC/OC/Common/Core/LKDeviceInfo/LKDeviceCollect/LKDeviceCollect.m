//
//  LKDeviceCollect.m
//  App
//
//  Created by yier on 2018/6/15.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "LKDeviceCollect.h"
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <sys/utsname.h>
#import <sys/param.h>
#import <SAMKeychain/SAMKeychain.h>
#import <CommonCrypto/CommonDigest.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])

@implementation LKDeviceCollect

+ (NSString *)bundleID {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
}


#pragma mark -- 设备信息

// 需要#import <sys/utsname.h>
+ (NSString*)deviceModelName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"国行、日版、港行iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"港行、国行iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"美版、台版iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"美版、台版iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone_X";
    if ([deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone_X";
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceModel isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    
    if ([deviceModel isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2";
    if ([deviceModel isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4";
    
    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceModel;
}

+ (NSString *)deviceName {
    return [UIDevice currentDevice].name;
}

+ (NSString *)systemName {
    return [UIDevice currentDevice].systemName;
    
}

+ (NSString *)systemVersion {
    return [UIDevice currentDevice].systemVersion;
}

+ (NSString *)model {
    return [UIDevice currentDevice].model;
}

+ (NSString *)localizedModel {
    return [UIDevice currentDevice].localizedModel;
}

//电池电量
+ (int)batteryLevel{
    if (![[UIDevice currentDevice] isBatteryMonitoringEnabled]) {
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    }
    int level = (int)([UIDevice currentDevice].batteryLevel * 100);
    if (level <0 ) return -1;
    return level;
    
}

//是否正在充电
+ (BOOL)isInCharge{
    if (![[UIDevice currentDevice] isBatteryMonitoringEnabled]) {
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    }
    switch ([UIDevice currentDevice].batteryState) {
        case UIDeviceBatteryStateCharging://充电状态
            return YES;
            break;
        case UIDeviceBatteryStateFull://充满状态（连接充电器充满状态）
            return YES;
            break;
        default:
            return NO;
            break;
    }
}
/**
 获取当前屏幕亮度
 */
+ (int)brightness{
    return (int)([UIScreen mainScreen].brightness * 100);
}

#pragma mark -- 越狱判断
const char* jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt"
};

char* printEnv(void)
{
    char *env = getenv("DYLD_INSERT_LIBRARIES");
//    NSLog(@"%s", env);
    return env;
}

+ (BOOL)isJailBreak
{
    //判定常见的越狱文件
    for (int i=0; i<ARRAY_SIZE(jailbreak_tool_pathes); i++) {
        NSString * path = [NSString stringWithUTF8String:jailbreak_tool_pathes[i]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//            NSLog(@"判定常见的越狱文件(%@):The device is jail broken!",path);
            return YES;
        }
    }
    //判定是否存在cydia这个应用。
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
//        NSLog(@"判定是否存在cydia这个应用:The device is jail broken!");
        return YES;
    }
    NSString * USER_APP_PATH = @"/User/Applications/";
    //读取系统所有应用的名称
    if ([[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH]) {
//        NSLog(@"读取系统所有应用的名称:The device is jail broken!");
        NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:USER_APP_PATH error:nil];
        NSLog(@"applist = %@", applist);
        return YES;
    }
    //读取环境变量 这个DYLD_INSERT_LIBRARIES环境变量，在非越狱的机器上应该是空，越狱的机器上基本都会有
    if (printEnv()) {
//        NSLog(@"读取环境变量:The device is jail broken!");
        return YES;
    }
    return NO;
}

//是否为模拟器
+ (BOOL)isEmulator{
#if TARGET_IPHONE_SIMULATOR//模拟器
    return YES;
#elif TARGET_OS_IPHONE//真机
    return NO;
#endif
    return YES;
}

/**
 *得到本机现在用的语言
 * en-CN 或en  英文  zh-Hans-CN或zh-Hans  简体中文   zh-Hant-CN或zh-Hant  繁体中文    ja-CN或ja  日本  ......
 */
+ (NSString*)preferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    return preferredLang;
}

#pragma mark -- 系统时间

/**
 开机时间
 */
+ (int64_t)bootTime{
    
    int64_t interval = [LKDeviceCollect currentTime] - [LKDeviceCollect activeTime];
    return interval;
}
/**
 从开机到现在的活动时间
 */
+ (int64_t)activeTime{
    
    NSTimeInterval upTime =  [NSProcessInfo processInfo].systemUptime;
    return (int64_t)upTime;
}
/**
 系统当前时间
 */
+ (int64_t)currentTime{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    return (int64_t)interval;
}

+ (NSString *)timeZone{
    return [NSString stringWithFormat:@"%@ %@",[NSTimeZone systemTimeZone].name,[NSTimeZone systemTimeZone].abbreviation];
}
#pragma mark -- 唯一标识

/**
 广告标识符
 */
+ (NSString *)idfa{
    __block NSString *adId = nil;

        dispatch_semaphore_t signal = dispatch_semaphore_create(0);

       if (@available(iOS 14, *)) {
                // iOS14使用 AppTrackingTransparency 新框架
                [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                    if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                        adId = [[ASIdentifierManager sharedManager] advertisingIdentifier].UUIDString;
                    }else{
                        adId =  @"";
                    }
                   dispatch_semaphore_signal(signal);
                }];
        } else {
               // 使用原方式访问 IDFA
                adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
                dispatch_semaphore_signal(signal);
        }

        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
    
    return adId.length >0 ? adId : @"";
}

/**
 Vindor标示符
 */
+ (NSString *)idfv{
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return idfv.length > 0 ? idfv : @"";
}

/**
 openudid
 */
+ (NSString *)openudid{
    NSString * account = @"LKopenudid_0";
    NSString * service = [[LKDeviceCollect bundleID] stringByAppendingString:@".LKService"];
    NSString * openudid = [SAMKeychain passwordForService:service account:account];
    if (openudid == nil) {
        unsigned char result[16];
        const char *cStr = [[[NSProcessInfo processInfo] globallyUniqueString] UTF8String];
        CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
        openudid = [[NSString stringWithFormat:
                     @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08lx",
                     result[0], result[1], result[2], result[3],
                     result[4], result[5], result[6], result[7],
                     result[8], result[9], result[10], result[11],
                     result[12], result[13], result[14], result[15],
                     arc4random() % 4294967295] lowercaseString];
        [SAMKeychain setPassword:openudid forService:service account:account];
    }
    return openudid;
}

/**
 uuid
 */
+ (NSString *)uuid{
    NSString * account = @"LKuuid_0";
    NSString * service = [[LKDeviceCollect bundleID] stringByAppendingString:@".LKService"];
    NSString * uuid = [SAMKeychain passwordForService:service account:account];
    if (uuid == nil) {
        CFUUIDRef puuid = CFUUIDCreate( nil );
        CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
        uuid = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
        uuid = [[uuid stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        CFRelease(puuid);
        CFRelease(uuidString);
        [SAMKeychain setPassword:uuid forService:service account:account];
    }
    return uuid;
}

+ (void)printDeviceCollect{
    unsigned int count = 0;
    Class class = objc_getMetaClass("LKDeviceCollect");
    Method *methodList = class_copyMethodList(class, &count);
    for (int i = 0; i < count; i++) {
        Method method = methodList[i];
        char *returnType = method_copyReturnType(method);
        SEL sel = method_getName(method);
        IMP imp = method_getImplementation(method);
        NSString *methodName = [NSString stringWithUTF8String:sel_getName(sel)];
        if (strcmp(returnType, "B") == 0) {
            BOOL returnVaue = ((BOOL(*)(id, SEL))imp)(class, sel);
            NSLog(@"[LKDeviceCollect %@] --- %u",methodName,returnVaue);
        }else if (strcmp(returnType, "q") == 0){
            int64_t returnVaue = ((int64_t(*)(id, SEL))imp)(class, sel);
            NSLog(@"[LKDeviceCollect %@] --- %lld",methodName,returnVaue);
        }else if (strcmp(returnType, "@") == 0){
            id returnVaue = ((id(*)(id, SEL))imp)(class, sel);
            NSLog(@"[LKDeviceCollect %@] --- %@",methodName,returnVaue);
        }else if (strcmp(returnType, "i") == 0){
            int returnVaue = ((int(*)(id, SEL))imp)(class, sel);
            NSLog(@"[LKDeviceCollect %@] --- %d",methodName,returnVaue);
        }else if (strcmp(returnType, "v") == 0 && ![methodName isEqualToString:@"load"] && ![methodName isEqualToString:@"printDeviceCollect"]){
            ((void(*)(id, SEL))imp)(class, sel);
            NSLog(@"[LKDeviceCollect %@]",methodName);
        }else if (strcmp(returnType, "Q") == 0){
            unsigned long long returnVaue = ((unsigned long long(*)(id, SEL))imp)(class, sel);
            NSLog(@"[LKDeviceCollect %@] --- %lld",methodName,returnVaue);
        }
    }
    
    free(methodList);
}

//+ (void)load{
//    [LKDeviceCollect printDeviceCollect];
//}

@end
