//
//  WKWebViewController.h
//  App
//
//  Created by yier on 2018/5/2.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "BaseViewController.h"


NS_ASSUME_NONNULL_BEGIN
extern NSString *const kMessageHandler;

@interface WKWebViewController : BaseViewController<WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic,copy) NSString *urlStr;
@property (nonatomic, assign) BOOL allMediaAutoPlay;///<所有视听自动播放，默认值为NO
@property (nonatomic, assign) BOOL ignoreWebTitle;///<忽略h5本身的title，默认为NO;
@property (nonatomic, assign) BOOL ignoreScalesPageToFit;///<忽略自适应屏幕
@property (nonatomic, assign) BOOL invalidZoomEnabled;///<禁用webView缩放，默认为NO;

/**
 发起webView请求
 */
- (void)loadWebView;

/**
 注入js

 @param jsString js代码
 */
- (void)evaluateJS:(NSString *)jsString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;
@end

NS_ASSUME_NONNULL_END
