//
//  SignalMode.m
//  OC
//
//  Created by yier on 2019/8/8.
//  Copyright © 2019 yier. All rights reserved.
//

#import "SignalMode.h"

@implementation SignalMode

+ (instancetype)shareInstance{
    
    static  SignalMode * _signal = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _signal = [[self alloc] init];
    }) ;
    
    return _signal;
}

- (void)test{
    NSLog(@"SignalMode");
}

@end
