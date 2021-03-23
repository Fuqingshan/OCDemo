//
//  Person.m
//  RunTimeDEMO
//
//  Created by 尹文涛 on 16/4/13.
//  Copyright © 2016年 小木科技. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>

@interface Person ()

@property (nonatomic,copy) NSString *education;//学历 私有变量

@end

@implementation Person


- (void)eat{
}

- (void)sleep{
    NSLog(@"抓紧睡觉");
}

-(NSString *)doSomeThing{
    return @"我要去爬山";
}

- (NSString *)doSomeOtherThing{
    return @"我要去唱歌";
}

- (NSString *)doSomeOtherThingWIthAction:(NSString *)action{
    return  [NSString stringWithFormat:@"我要去%@",action];
}

@end
