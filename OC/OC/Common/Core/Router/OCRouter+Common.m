//
//  OCRouter+Common.m
//  App
//
//  Created by yier on 2019/1/22.
//  Copyright © 2019 yier. All rights reserved.
//

#import "OCRouter+Common.h"
#import "WKWebViewController.h"

@implementation OCRouter (Common)

#pragma mark - 处理Common相关的router
+ (BOOL)openCommonURL:(NSURL *)url{
    if (![[url host] isEqualToString:@"common"]) {
        return NO;
    }
    if ([[url path] isEqualToString:@"/web"]) {
        [self showWebViewControllerByURL:url];
    }else{
        return NO;
    }
    
    return YES;
}

#pragma mark - 跳转Storyboard的controller
+ (void)showViewControllerByIdentifier:(NSString *)identifier storyboardName:(NSString *)storyboardName{
    if (![identifier isValide]) {
        return;
    }
    if (![storyboardName isValide]) {
        return;
    }
    @try {
        UIViewController *vc = [[UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:identifier];
        [[OCRouter shareInstance].selectedViewController pushViewController:vc animated:YES];
    } @catch (NSException *exception) {
        NSLog(@"exception:%@",exception);
    } @finally {
        
    }
}

#pragma mark - 展示h5容器
/*
 NSDictionary *dic = @{
 @"urlStr":@"https://www.jn.cn?title=序列化"
 ,@"ignoreWebTitle":@"0"
 ,@"title":@"josn序列化"
 };
 NSURLComponents *components = [NSString mapQuerysURLByDictionary:dic url:@"sumup://common/web"];
 */
+ (void)showWebViewControllerByURL:(NSURL *)url{
    NSDictionary *params = url.absoluteString.params;
    NSString *title = stringInDictionaryForKey(params, @"title");
    NSString *urlStr = stringInDictionaryForKey(params, @"urlStr");
    NSString *ignoreWebTitleStr = stringInDictionaryForKey(params, @"ignoreWebTitle");
    if (![urlStr isValide]) {
        return;
    }
    
    /*忽略h5的title
     1、如果传了title且有效，就忽略h5页面的title
     2、无论是否忽略，如果url中包含了忽略的设置，则设置成url中的
     */
    title = [title stringByRemovingPercentEncoding];
    BOOL ignoreWebTitle = [title isValide];
    if ([ignoreWebTitleStr isEqualToString:@"1"]) {
        ignoreWebTitle = YES;
    }else if ([ignoreWebTitleStr isEqualToString:@"0"]){
        ignoreWebTitle = NO;
    }
    WKWebViewController *webVC = [[WKWebViewController alloc] init];
    webVC.title = title;
    webVC.urlStr = urlStr;
    webVC.ignoreWebTitle = ignoreWebTitle;
    webVC.hidesBottomBarWhenPushed = YES;
    [[OCRouter shareInstance].selectedViewController pushViewController:webVC animated:YES];
}

@end
