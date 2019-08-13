//
//  OCParamsInfo.m
//  App
//
//  Created by yier on 2019/1/28.
//  Copyright © 2019 yier. All rights reserved.
//

#import "OCParamsInfo.h"

@implementation OCParamsInfo

+ (NSMutableArray<YYClassPropertyInfo *> *)getPropertysInClass:(Class)cls thresholds:(NSArray<NSString *> *)thresholds{
    if (!cls) {
        return nil;
    }
    if (thresholds.count == 0) {
        thresholds = @[NSStringFromClass([NSObject class])];
    }
    NSMutableArray *propertys = [[NSMutableArray alloc] init];
    YYClassInfo *classInfo = [YYClassInfo classInfoWithClass:cls];
    propertys = [self getPropertysInClass:classInfo propertys:propertys thresholds:thresholds];
    return propertys;
}

+ (NSMutableArray<YYClassPropertyInfo *> *)getPropertysInClass:(YYClassInfo *)classInfo propertys:(NSMutableArray *)propertys thresholds:(NSArray<NSString *> *)thresholds{
    if(![self checkThresholdEqualByClassName:classInfo.name thresholds:thresholds]) {
        [propertys addObjectsFromArray:classInfo.propertyInfos.allValues];
        return [self getPropertysInClass:classInfo.superClassInfo propertys:propertys thresholds:thresholds];
    }else{
        return propertys;
    }
}

+ (BOOL)checkThresholdEqualByClassName:(NSString *)className thresholds:(NSArray<NSString *> *)thresholds {
    for (NSString *threshold in thresholds) {
        if ([className isEqualToString:threshold]) {
            return YES;
        }
    }
    return NO;
}

@end
