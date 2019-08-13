//
//  LKLogManager.m
//  App
//
//  Created by yier on 2018/5/3.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "LKLogManager.h"
#import "LKLogFormatter.h"

@interface LKLogManager()
@property (nonatomic, assign) BOOL consoleEnabled;
@property (nonatomic, strong) DDFileLogger  *fileLogger;
@property (nonatomic, assign,readwrite) DDLogLevel logLevel;

@end

@implementation LKLogManager

+(instancetype)shareInstance
{
    static  LKLogManager * _logManager = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _logManager = [[LKLogManager alloc] init] ;
    }) ;
    
    return _logManager ;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.logLevel = DDLogLevelInfo;
        ///改为Silence控制
//#if DEBUG
//        [self enableConsoleLog:YES];
//#endif
        [self createFileLogger];
    }
    return self;
}

- (void)createFileLogger{
    ///最大缓存5m
    NSInteger maximunFileSize = 1024 * 1024 * 5;
    
    ///日志文件生成间隔1天
    NSInteger rollingFrequency = 60.0 * 60 * 24.0;
    
    ///日志最多保留7个
    NSInteger maximumNumberOfLogFiles = 7;
    
    self.fileLogger = [[DDFileLogger alloc] init];
    [self.fileLogger setMaximumFileSize:maximunFileSize];
    [self.fileLogger setRollingFrequency:rollingFrequency];
    [[self.fileLogger logFileManager] setMaximumNumberOfLogFiles:maximumNumberOfLogFiles];
    [self.fileLogger setLogFormatter:[LKLogFormatter new]];
    [DDLog addLogger:self.fileLogger];
}

- (void)enableConsoleLog:(BOOL)enable {
    if (self.consoleEnabled == enable) {
        return;
    }
    self.consoleEnabled = enable;
    if (enable) {
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    }else {
        [DDLog removeLogger:[DDTTYLogger sharedInstance]];
    }
}

+ (void)changeLogLevel:(DDLogLevel)level{
    DDLogLevel changeLevel = DDLogLevelInfo;
    switch (level) {
        case DDLogLevelOff:
            changeLevel = DDLogLevelOff;
            break;
        case DDLogLevelError:
            changeLevel = DDLogLevelError;
            break;
        case DDLogLevelWarning:
            changeLevel = DDLogLevelWarning;
            break;
        case DDLogLevelInfo:
            changeLevel = DDLogLevelInfo;
            break;
        case DDLogLevelDebug:
            changeLevel = DDLogLevelDebug;
            break;
        case DDLogLevelVerbose:
            changeLevel = DDLogLevelVerbose;
            break;
        case DDLogLevelAll:
            changeLevel = DDLogLevelAll;
            break;
        default:
            break;
    }
    [LKLogManager shareInstance].logLevel = changeLevel;
}

@end
