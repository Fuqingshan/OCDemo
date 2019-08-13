//
//  AdapterMode.m
//  OC
//
//  Created by yier on 2019/8/8.
//  Copyright © 2019 yier. All rights reserved.
//

#import "AdapterMode.h"
#import "AdapterOld.h"

@interface AdapterMode()
@property (nonatomic, strong) AdapterOld *old;
@end

@implementation AdapterMode

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.old = [[AdapterOld alloc] init];
    }
    return self;
}

- (void)test{
    //适配老旧的方法
    [self.old oldTest];
}

@end
