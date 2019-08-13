//
//  LKBuglyLog.m
//  App
//
//  Created by yier on 2018/6/5.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "LKBuglyLog.h"
#import <Bugly/Bugly.h>

static NSString *const BuglyAppID = @"123456";
@interface LKBuglyLog()<BuglyDelegate>

@end

@implementation LKBuglyLog

+ (instancetype)shareInstance{
    
    static  LKBuglyLog * _buglyLog = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _buglyLog  = [[self alloc] init] ;
    }) ;
    
    return _buglyLog ;
}

- (void)configBugly{
    
    BuglyConfig * config = [[BuglyConfig alloc] init];
    config.delegate = self;
    config.channel = @"App Store";
    config.excludeModuleFilter = [self blackList];
    config.version = [[UIApplication sharedApplication] appVersion];
    config.deviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
    // 设置自定义日志上报的级别，默认不上报自定义日志
    config.reportLogLevel = BuglyLogLevelInfo;
    
#if DEBUG
    config.blockMonitorEnable = YES;
    config.blockMonitorTimeout = 5;
#else
    // 卡顿监控开关，默认关闭,Bugly的实现方式是监听主线程runloop卡顿，即使是在子线程监听的，也会消耗一部分性能，因此Release环境关闭
    config.blockMonitorEnable = NO;
    config.blockMonitorTimeout = 5;
#endif
    
    [Bugly startWithAppId:BuglyAppID config:config];

    // 日志打印上传不同于CocoaLumberjack，Bugly只是把崩溃前的使用BuglyLog打印的reportLogLevel级别的上传，受崩溃状态和文件大小，条数限制，因此日志系统还是需要自己构建
    [BuglyLog initLogger:BuglyLogLevelInfo consolePrint:NO];
}

/**
 *  崩溃数据过滤器，如果崩溃堆栈的模块名包含过滤器中设置的关键字，则崩溃数据不会进行上报
 */
- (NSArray *)blackList{
return @[
         //搜狗输入法崩溃信息
            @"SogouInputIPhone.dylib"
         ];
}

- (NSString * BLY_NULLABLE)attachmentForException:(NSException * BLY_NULLABLE)exception{
    NSDictionary *dictionary = @{
                                 @"custID":@""
                                ,@"phoneNum":@""
                                ,@"isAppCrashedOnStartUpExceedTheLimit":@([Bugly isAppCrashedOnStartUpExceedTheLimit])
                                 };
    return [NSString stringWithFormat:@"CustomReport:%@",dictionary];
}

@end
