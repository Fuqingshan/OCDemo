//
//  LKSilenceLog.m
//  App
//
//  Created by yier on 2018/5/3.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "LKSilenceLog.h"
#import "LKLogManager.h"
#import "fishhook.h"

static void (*orig_NSLog)(NSString *, ...);

void LKLogv(NSString *format, ...){
    //none
    if ([LKSilenceLog shareInstance].silence == LKSilenceTypeNone) {
        
        if ([LKSilenceLog shareInstance].whiteList.count == 0) {
            va_list args;
            va_start(args, format);
            NSLogv(format, args);
            va_end(args);
            return;
        }
        
        NSArray *stacks = [NSThread callStackSymbols];
        NSString *caller;
        if (stacks.count > 2) {
            caller = stacks[1];
        }
        if (!caller) {
            return;
        }
        
        BOOL flag = NO;
        for (NSString *className in [LKSilenceLog shareInstance].whiteList) {
            if ([caller rangeOfString:className].location != NSNotFound) {
                flag = YES;
                break;
            }
        }
        if (!flag) {
            return;
        }
        
        va_list args;
        va_start(args, format);
        NSLogv(format, args);
        va_end(args);
        return;
    }
    
    //all
    if ([LKSilenceLog shareInstance].silence == LKSilenceTypeAll) {
        return;
    }
}

///count控制优先级，里面的数字越小优先级越高，1 ~ 100 为系统保留, 在+load之后
__attribute__((constructor(200))) static void LKNSLogHook(void) {
    struct rebinding log_rebinding = {"NSLog", LKLogv, (void *)&orig_NSLog};
    rebind_symbols((struct rebinding[1]){log_rebinding}, 1);
}

__attribute__((destructor(200))) static void afterMain(void) {
    ///"afterMain";
}

@interface LKSilenceLog ()

@property (nonatomic, assign,readwrite) LKSilenceType silence;
@property (nonatomic, strong,readwrite) NSArray<NSString *> *whiteList;

@end

@implementation LKSilenceLog

+(instancetype)shareInstance
{
    static  LKSilenceLog * _silenceLog = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _silenceLog  = [[self alloc] init] ;
        [[LKLogManager shareInstance] enableConsoleLog:_silenceLog.silence == LKSilenceTypeNone];
    }) ;
    
    return _silenceLog ;
}

- (LKSilenceType)silence {
#if DEBUG
    return LKSilenceTypeNone;
#else
    return LKSilenceTypeAll;
#endif
}

- (NSArray<NSString *> *)whiteList{
    if(!_whiteList){
        _whiteList = @[
//            @"MePage"
                       ];
    }
    return _whiteList;
}

@end
