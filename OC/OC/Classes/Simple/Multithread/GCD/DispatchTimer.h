//
//  DispatchTimer.h
//  App
//
//  Created by yier on 2019/6/27.
//  Copyright © 2019 yier. All rights reserved.
//
/*
 
 @property (nonatomic, strong) LKDispatchTimer *timer;

 if (!self.timer) {
     @weakify(self);
     self.timer = [LKDispatchTimer createDispatchTimer:1 eventHandler:^{
         @strongify(self);
         if (self.count >= self.authModel.roomMaxWaitMintes * 60) {
             [self.timer cancle];
         }
     } cancelHandler:^{
           //调用cancle之后的回调
    }];
 }
 
 //暂停
 [self.timer suspend];;

 //继续使用
 [self.timer resume];

 //处理timer没销毁的情况
   [self.timer cancle];
 
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,SourceType) {
    SourceTypeUnusable = 0,///<无法使用
    SourceTypeResume = 1,///<使用中
    SourceTypeSuspend = 2,///<暂停
};

@interface DispatchTimer : NSObject

/**
 创建timer

 @param interval 时间间隔 单位：S
 @param eventHandler 间隔单次触发回调
 @param cancelHandler timer被cancle回调
 @return timer
 */
+ (instancetype)createDispatchTimer:(NSInteger)interval
                       eventHandler:(dispatch_block_t)eventHandler
                      cancelHandler:(dispatch_block_t)cancelHandler;

/**
 暂停状态下才能继续使用，初始化之后默认为暂停状态
 */
- (void)resume;

/**
 使用状态下才能暂停，内部有判断
 */
- (void)suspend;

/**
 cancle之后无法继续使用，不使用的时候一定要记得调用，否则会导致无法释放
 */
- (void)cancle;

@end

