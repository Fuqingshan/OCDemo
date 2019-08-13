//
//  SubProxy.m
//  OC
//
//  Created by yier on 2019/2/27.
//  Copyright © 2019 yier. All rights reserved.
//

#import "SubProxy.h"

@implementation RealProxyHandler
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:nilToEmptyString(self.name) forKey:@"name"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
    }
    
    return self;
}


- (void)eat{
    NSLog(@"RealProxyHandler 吃");
}

@end

@interface SubProxy()
@property (nonatomic, strong) RealProxyHandler *handler;

@end

@implementation SubProxy

- (BOOL)respondsToSelector:(SEL)aSelector{
    return [RealProxyHandler instancesRespondToSelector:aSelector];
}

#pragma mark - 完整消息转发
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature;
    
    if ([RealProxyHandler instancesRespondToSelector:aSelector]) {
        signature = [RealProxyHandler instanceMethodSignatureForSelector:aSelector];
    }
    
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([RealProxyHandler instancesRespondToSelector:anInvocation.selector]) {
        NSMethodSignature *signature = [RealProxyHandler instanceMethodSignatureForSelector:@selector(eat)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:self.handler];
        [invocation setSelector:@selector(eat)];
        [invocation invokeWithTarget:self.handler];
    }
}

- (RealProxyHandler *)handler{
    if(!_handler){
        _handler = [RealProxyHandler new];
    }
    return _handler;
}

@end
