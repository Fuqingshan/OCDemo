//
//  WKWebViewController+MessageHandler.h
//  App
//
//  Created by yier on 2018/12/27.
//  Copyright © 2018 yier. All rights reserved.
//
//公共的messageHandler

#import "WKWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewController (MessageHandler)

/**
 刷新页面
 */
- (void)reloadWebView;

/**
 打开外链
 @param url 外链地址
 */
- (void)mallExternURL:(NSString *)url;

/**
 打开跨域页面

 @param url 跨域的连接
 */
- (void)openCrossDomainURL:(NSString *)url;

/**
 js通过原生请求
 */
- (void)callNativeRequest:(NSString *)json;
@end

NS_ASSUME_NONNULL_END
