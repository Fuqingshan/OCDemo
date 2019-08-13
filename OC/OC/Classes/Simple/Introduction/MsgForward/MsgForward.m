//
//  MsgForward.m
//  OC
//
//  Created by yier on 2019/2/20.
//  Copyright © 2019 yier. All rights reserved.
//

#import "MsgForward.h"
#import <objc/runtime.h>

@interface MsgForward()
@property (nonatomic, strong) MsgForwardHelper *helper;
@end

@implementation MsgForward

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.helper = [[MsgForwardHelper alloc] init];
    }
    return self;
}

#pragma mark - 动态方法解析
void functionForResolve(id self, SEL _cmd) {
    NSLog(@"%@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
    NSString *selectorString = NSStringFromSelector(sel);
    
    if ([selectorString isEqualToString:@"aaa"]) {
        Class class = object_getClass(self);
        class_addMethod(self.class, sel, (IMP)functionForResolve, "v@:");
    }
    
    return [super resolveInstanceMethod:sel];
}

+ (BOOL)resolveClassMethod:(SEL)sel{
    
    NSString *selectorString = NSStringFromSelector(sel);
    
    if ([selectorString isEqualToString:@"classAAA"]) {
        Class class = objc_getMetaClass(object_getClassName(self));
       BOOL add = class_addMethod(class, sel, (IMP)functionForResolve, "v@:");
    }
    
    return [super resolveClassMethod:sel];
}

#pragma mark - 备用接受者
- (id)forwardingTargetForSelector:(SEL)aSelector{
    NSString *selectorString = NSStringFromSelector(aSelector);

    if ([selectorString isEqualToString:@"BBB"]) {
        return self.helper;
    }
    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark - 完整消息转发
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    
    if (!signature) {
        if ([MsgForwardHelper instancesRespondToSelector:aSelector]) {
            signature = [MsgForwardHelper instanceMethodSignatureForSelector:aSelector];
        }
    }
    
    return signature;
}

/**
 完整消息转发methodSignatureForSelector返回对应的signature才会z调用

 @param anInvocation
 */
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([MsgForwardHelper instancesRespondToSelector:anInvocation.selector]) {
//        [anInvocation invokeWithTarget:_helper];

        NSMethodSignature *signature = [MsgForwardHelper instanceMethodSignatureForSelector:@selector(EEE:b:c:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:self.helper];
        [invocation setSelector:@selector(EEE:b:c:)];
        
        int a = 1;
        int b = 2;
        int c = 3;
        //设置参数，index默认0是self，1是_cmd,没有就不设置
        [invocation setArgument:&a atIndex:2];
        [invocation setArgument:&b atIndex:3];
        [invocation setArgument:&c atIndex:4];
        
        [invocation invokeWithTarget:self.helper];
        
        for (NSInteger i = 0;i < signature.numberOfArguments;i++) {
            printf("\nArgumentType:%s",[signature getArgumentTypeAtIndex:i]);
        }
        
        NSUInteger length = [signature methodReturnLength];
        if (length > 0) {
            if (strcmp(signature.methodReturnType, "@") == 0) {
                id returnValue;
                [invocation getReturnValue:&returnValue];
                NSLog(@"invocationReturnValue:%@",returnValue);
            }
        }
    }
}

@end

@implementation MsgForwardHelper

- (void)BBB{
    NSLog(@"BBB --- %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)CCC{
    NSLog(@"CCC --- %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)DDD{
   NSLog(@"DDD --- %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (NSString *)EEE:(int)a b:(int)b c:(int)c{
    NSLog(@"EEE -- %d %d %d",a,b,c);
    
    return @"EEE --- return";
}

@end
