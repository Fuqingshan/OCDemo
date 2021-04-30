//
//  OCCrashMonitor.m
//  App
//
//  Created by yier on 2019/9/30.
//  Copyright © 2019 yooli. All rights reserved.
//

#import "OCCrashMonitor.h"

NSString *const OCAppOnException = @"kOCAppOnException";
static NSUncaughtExceptionHandler *OCUncaughtExceptionHandler;

@implementation OCCrashMonitor

+ (void)registerExceptionHandler{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OCUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
        NSSetUncaughtExceptionHandler(&HandleException);
    }) ;
}

void HandleException (NSException *exception) {
    if (OCUncaughtExceptionHandler) {
        [[OCCrashMonitor class] performSelectorOnMainThread:@selector(handleException:) withObject:exception waitUntilDone:YES];
        OCUncaughtExceptionHandler(exception);
    }else{
        [[OCCrashMonitor class] performSelectorOnMainThread:@selector(handleException:) withObject:exception waitUntilDone:YES];
    }
}

+ (void)handleException:(NSException *)exception{
    [OCCrashMonitor handleExceptionMsg:exception];
    [OCCrashMonitor handleExceptionNotify:exception];
}

+ (void)handleExceptionMsg:(NSException *)exception{
    /*拼装crashStacks*/
   NSArray *callStacks = exception.callStackSymbols?:[NSThread callStackSymbols];
   NSString *callStacksStr;
   
   if (callStacks.count > 0) {
       @try {
           NSError *err;
           NSData *data = [NSJSONSerialization dataWithJSONObject:callStacks options:NSJSONWritingPrettyPrinted error:&err];
           if (data && data.length > 0) {
               callStacksStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
           }
       } @catch (NSException *exception) {
           return;
       }
   }
   
   NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,YES).firstObject;
   NSString *crashPath = [path stringByAppendingPathComponent:@"OCCrashs"];
   BOOL createDir = [[NSFileManager defaultManager] createDirectoryAtPath:crashPath withIntermediateDirectories:YES attributes:nil error:nil];
   
   if (!createDir) {
       LKLog(@"OCCrashMonitor --- 崩溃日志存储目录创建失败");
       return;
   }
   
   if (![callStacksStr isValide]) {
       LKLog(@"OCCrashMonitor --- 没有崩溃堆栈");
       return;
   }
   
   //规范文件命名格式
   NSString *dStr = [[NSDate date] stringWithFormat:@"YYYYMMddHHmmss"];
    //custid、时间（崩溃是小概率事件，没必要以custid为维度创建文件）
   NSString *crashTitle = [NSString stringWithFormat:@"%@.crash",dStr];
   NSString *writePath = [crashPath stringByAppendingPathComponent:crashTitle];
    
   NSString *version = [UIApplication sharedApplication].appVersion;
   NSString *crashName = exception.name?:@"未知名称";
   NSString *crashReason = exception.reason?:@"未知原因";
   NSString *crashText = [NSString stringWithFormat:@"version:%@\n name : %@\n reason : %@\n crashCallStack : %@",version,crashName,crashReason,callStacksStr];
   NSData *crashData = [crashText dataUsingEncoding:NSUTF8StringEncoding];
   BOOL success = [crashData writeToFile:writePath atomically:YES];
    
    if (success) {
        LKLogm(@"OCCrashMonitor --- 日志存储成功：%@",writePath);
    }else{
        LKLogm(@"OCCrashMonitor --- 日志存储失败：%@",writePath);
    }
}

+ (void)handleExceptionNotify:(NSException *)exception{
    [[NSNotificationCenter defaultCenter] postNotificationName:OCAppOnException object:nil];
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    for (NSString *mode in (__bridge NSArray *)allModes) {
        CFRunLoopRunInMode((CFStringRef)mode, 0.001, NO);
    }
    CFRelease(allModes);
}

+ (void)crashAfterDelay:(NSTimeInterval)delay{
    __block BOOL flag = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        flag = NO;
    });
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (flag) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, NO);
        }
    }
    CFRelease(allModes);
}

@end
