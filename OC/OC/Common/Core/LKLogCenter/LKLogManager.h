//
//  LKLogManager.h
//  App
//
//  Created by yier on 2018/5/3.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#define LKLog(msg) LKLogm(@"%@",msg);
#define LKLogm(frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, [LKLogManager shareInstance].logLevel, DDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

@interface LKLogManager : NSObject
@property (nonatomic, assign,readonly) DDLogLevel logLevel;

+(instancetype)shareInstance;


/**
 打开控制台打印，LKSilenceTypeNone模式开启

 @param enable YES/NO
 */
- (void)enableConsoleLog:(BOOL)enable;

/**
 修改日志打印等级，默认DDLogLevelInfo

 @param level 日志等级
 */
+ (void)changeLogLevel:(DDLogLevel)level;

@end
