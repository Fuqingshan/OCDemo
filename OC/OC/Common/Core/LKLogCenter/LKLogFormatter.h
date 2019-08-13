//
//  LKLogFormatter.h
//  App
//
//  Created by yier on 2018/5/3.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface LKLogFormatter : NSObject<DDLogFormatter>

- (NSString * )formatLogMessage:(DDLogMessage *)logMessage;

@end
