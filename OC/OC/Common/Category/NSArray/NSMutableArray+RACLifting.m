//
//  NSMutableArray+RACLifting.m
//  MallIM
//
//  Created by Ruoyu Fu on 14-5-12.
//  Copyright (c) 2014年 Jumei. All rights reserved.
//

#import "NSMutableArray+RACLifting.h"
#import <ReactiveObjC/NSObject+RACDescription.h>

@implementation NSMutableArray (RACLifting)

- (RACSignal *)rac_addObjectSignal {
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal != nil) return signal;

    signal = [[[self rac_signalForSelector:@selector(addObject:)] map:^id(RACTuple *value) {
        return [value first];
    }] setNameWithFormat:@"%@ -rac_addObjectSignal", RACDescription(self)];

    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}

- (RACSignal *)rac_removeObjectSignal {
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal != nil) return signal;
    
    signal = [[[self rac_signalForSelector:@selector(removeObject:)] map:^id(RACTuple *value) {
        return [value first];
    }] setNameWithFormat:@"%@ -rac_removeObjectSignal", RACDescription(self)];
    
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}

- (RACSignal *)rac_insertObjectsAtIndexes {
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal != nil) return signal;
    
    signal = [[[self rac_signalForSelector:@selector(insertObjects:atIndexes:)] map:^id(RACTuple *value) {
        return [value first];
    }] setNameWithFormat:@"%@ -rac_insertObjectsAtIndexes", RACDescription(self)];
    
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}

@end
