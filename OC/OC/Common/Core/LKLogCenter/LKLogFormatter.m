//
//  LKLogFormatter.m
//  App
//
//  Created by yier on 2018/5/3.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "LKLogFormatter.h"

@interface LKLogFormatter()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation LKLogFormatter

- (instancetype)init {
    return [self initWithDateFormatter:nil];
}

- (instancetype)initWithDateFormatter:(NSDateFormatter *)aDateFormatter {
    if ((self = [super init])) {
        if (aDateFormatter) {
            self.dateFormatter = aDateFormatter;
        } else {
            NSString *dateFormat = @"yyyy-MM-dd && HH-mm-ss";
            self.dateFormatter = [[NSDateFormatter alloc] init];
            [self.dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
            [self.dateFormatter setDateFormat:dateFormat];
            //    NSTimeZone*zone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
            //    NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];
            //    NSDate * currentDate = [[NSDate date] dateByAddingTimeInterval:interval];
        }
    }
    return self;
}

- (NSString * )formatLogMessage:(DDLogMessage *)logMessage{
    NSString *dateAndTime = [self.dateFormatter stringFromDate:(logMessage.timestamp)];
    NSString *logLevel;
    switch (logMessage.flag) {
        case DDLogFlagError    : logLevel = @"E"; break;
        case DDLogFlagWarning  : logLevel = @"W"; break;
        case DDLogFlagInfo     : logLevel = @"I"; break;
        case DDLogFlagDebug    : logLevel = @"D"; break;
        default                : logLevel = @"V"; break;
    }
    return [NSString stringWithFormat:@"Time:%@ | Level:%@ | Thread:%@ | FileName:%@ | Function:%@ @ Line%@ | Message:%@",
            dateAndTime, logLevel, logMessage.threadID,logMessage.fileName, logMessage.function, @(logMessage.line), logMessage.message];
}

@end
