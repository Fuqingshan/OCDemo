//
//  DispatchTimer.m
//  App
//
//  Created by yier on 2019/6/27.
//  Copyright © 2019 yier. All rights reserved.
//

/*
 1、dispatch_source_set_event_handler会引起循环引用
 2、dispatch_resume和dispatch_suspend调用次数需要平衡，如果重复调用dispatch_resume则会崩溃,因为重复调用会让dispatch_resume代码里if分支不成立，从而执行了DISPATCH_CLIENT_CRASH("Over-resume of an object")导致崩溃
 3、source在suspend状态下，如果直接设置source = nil
      或者重新创建source都会造成crash。正确的方式是在resume状态下调用dispatch_source_cancel(source)释放当前的source
 */

#import "DispatchTimer.h"

@interface DispatchTimer()
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, copy) dispatch_block_t eventHandler;
@property (nonatomic, copy) dispatch_block_t cancelHandler;
@property (nonatomic, assign) SourceType type;///<0表示无法使用,1表示使用中，2表示暂停

@end

@implementation DispatchTimer

- (void)dealloc{
    [self cancle];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0,0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 1);
        dispatch_source_set_timer(self.timer, start, 1 * NSEC_PER_SEC, 0);
        self.type = SourceTypeSuspend;
        
        dispatch_source_set_event_handler(self.timer, self.eventHandler);
        
        dispatch_source_set_cancel_handler(self.timer, self.cancelHandler);
    }
    return self;
}

+ (instancetype)createDispatchTimer:(NSInteger)interval
                       eventHandler:(dispatch_block_t)eventHandler
                      cancelHandler:(dispatch_block_t)cancelHandler{
    DispatchTimer *timer = [[DispatchTimer alloc] init];
    timer.eventHandler = eventHandler;
    timer.cancelHandler = cancelHandler;
    
    return timer;
}

- (void)resume{
    if (self.type != SourceTypeSuspend) {
        NSLog(@"暂停状态才能继续使用");
        return;
    }
    dispatch_resume(self.timer);
    self.type = SourceTypeResume;
}

- (void)suspend{
    if (self.type != SourceTypeResume) {
        NSLog(@"使用状态才能暂停");
        return;
    }
    dispatch_suspend(self.timer);
    self.type = SourceTypeSuspend;
}

- (void)cancle{
    if (self.type == SourceTypeUnusable) {
        NSLog(@"无法使用状态不能cancle");
        return;
    }
    
    if (self.type == SourceTypeSuspend) {
        NSLog(@"如果当前处理暂停状态，需要启动起来才能cancle");
        dispatch_resume(self.timer);
        self.type = SourceTypeResume;
    }
    
    if (dispatch_source_testcancel(self.timer) != 0) {
        NSLog(@"已经被cancle了");
        return;
    }
    
    dispatch_source_cancel(self.timer);
    self.type = SourceTypeUnusable;
    self.timer = nil;
}

@end
