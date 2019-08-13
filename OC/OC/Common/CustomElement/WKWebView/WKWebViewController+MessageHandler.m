//
//  WKWebViewController+MessageHandler.m
//  App
//
//  Created by yier on 2018/12/27.
//  Copyright © 2018 yier. All rights reserved.
//

#import "WKWebViewController+MessageHandler.h"
#import "NSString+URLQuery.h"
#import "NSDictionary+Helper.h"

@implementation WKWebViewController (MessageHandler)

#pragma mark - 刷新页面
- (void)reloadWebView{
    //容错处理，避免重新加载时之前的页面还在处理
    if ([self.webView isLoading]) {
        [self.webView stopLoading];
    }
    [self loadWebView];
}

#pragma mark -  打开外链
- (void)mallExternURL:(NSString *)url{
    if ([NSString isContainsChineseCharacter:url]) {
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    NSURL *openURL = [NSURL URLWithString:url];
    [[UIApplication sharedApplication] openURL:openURL];
}

- (void)openCrossDomainURL:(NSString *)url{
    WKWebViewController *vc = [WKWebViewController new];
    vc.urlStr = url;
    [[OCRouter shareInstance].selectedViewController pushViewController:vc animated:YES];
}

#pragma mark - js通过原生请求
- (void)callNativeRequest:(NSString *)json{
    NSDictionary *dic = [NSDictionary dictionaryWithJsonString:json];
    if (!dic) {
        return;
    }
    
    NSString *paramsStr = stringInDictionaryForKey(dic, @"params");
    NSString *method = stringInDictionaryForKey(dic, @"method");
    NSString *key = stringInDictionaryForKey(dic, @"key");
    NSString *url = stringInDictionaryForKey(dic, @"url");
    
    NSDictionary *params = [NSDictionary dictionaryWithJsonString:paramsStr];
        
    @weakify(self);
    if ([method isEqualToString:@"POST"]) {
//        [NSObject post:string_format(@"%@%@",CurrentBaseURL(),url) parameters:params timeout:10 contentType:@"application/json" progress:nil success:^(id response) {
//            @strongify(self);
//            [self evaluateJScallNativeRequestCallBack:key callBack:response];
//        } failure:^(NSError *error) {
//            [self evaluateJScallNativeRequestCallBack:key callBack:@{@"code":@(-1)}];
//        }];
    }else{
//        [NSObject get:string_format(@"%@%@",CurrentBaseURL(),url) parameters:params timeout:10 contentType:@"application/json" progress:nil success:^(id response) {
//            @strongify(self);
//            [self evaluateJScallNativeRequestCallBack:key callBack:response];
//        } failure:^(NSError *error) {
//            [self evaluateJScallNativeRequestCallBack:key callBack:@{@"code":@(-1)}];
//        }];
    }
}

- (void)evaluateJScallNativeRequestCallBack:(NSString *)key callBack:(id)response{
    if (![key isValide]) {
        return;
    }
    if(!response){
        return;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (!json) {
        return;
    }
    [self evaluateJS:[NSString stringWithFormat:@"%@(%@)",key,json] completionHandler:nil];
}

@end
