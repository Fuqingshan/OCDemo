//
//  LKBuglyLog.h
//  App
//
//  Created by yier on 2018/6/5.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKBuglyLog : NSObject

+ (instancetype)shareInstance;

- (void)configBugly;

@end
