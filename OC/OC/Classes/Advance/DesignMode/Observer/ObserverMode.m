//
//  ObserverMode.m
//  OC
//
//  Created by yier on 2019/8/8.
//  Copyright © 2019 yier. All rights reserved.
//

#import "ObserverMode.h"

static NSString *const kObserverMode = @"kObserverMode";

@interface ObserverMode ()
@property (nonatomic, assign) BOOL subscribed;

@end

@implementation ObserverMode

- (void)dealloc{
    
}

- (void)subscribe{
    if (self.subscribed) {
        return;
    }
    
    self.subscribed = YES;
    @weakify(self);
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kObserverMode object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        [self test];
    }];
}

- (void)observable{
    [[NSNotificationCenter defaultCenter] postNotificationName:kObserverMode object:nil];
}

- (void)test{
    NSLog(@"ObserverMode");
}

@end
