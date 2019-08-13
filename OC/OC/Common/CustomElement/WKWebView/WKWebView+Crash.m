//
//  WKWebView+Crash.m
//  App
//
//  Created by yier on 2018/5/2.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "WKWebView+Crash.h"

@implementation WKWebView (Crash)
/*
 WKWebView 退出前调用evaluateJavaScript，导致crash(on ios8)
 对于iOS 8系统，可以通过在 completionHandler 里 retain WKWebView 防止 completionHandler 被过早释放
 */
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originSEL = NSSelectorFromString(@"evaluateJavaScript:completionHandler:");
        SEL newSEL = @selector(altEvaluateJavaScript:completionHandler:);
        Method originMethod = class_getInstanceMethod([self class], originSEL);
        Method newMethod = class_getInstanceMethod([self class], newSEL);
        BOOL add = class_addMethod([self class], method_getName(originMethod), method_getImplementation(newMethod), method_copyReturnType(newMethod));
        if (add) {
            class_replaceMethod([self class], method_getName(newMethod),method_getImplementation(originMethod), method_copyReturnType(originMethod));
        }else{
            method_exchangeImplementations(originMethod, newMethod);
        }
    });
    
}
/*
 * fix: WKWebView crashes on deallocation if it has pending JavaScript evaluation
 */
- (void)altEvaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    id strongSelf = self;
    [self altEvaluateJavaScript:javaScriptString completionHandler:^(id r, NSError *e) {
        [strongSelf title];
        if (completionHandler) {
            completionHandler(r, e);
        }
    }];
}

@end
