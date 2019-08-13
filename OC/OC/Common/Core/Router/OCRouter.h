//
//  OCRouter.h
//  App
//
//  Created by yier on 2019/1/16.
//  Copyright © 2019 yier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContainerViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCRouter : NSObject
@property (nonatomic, strong) ContainerViewController *rootViewController;
@property (nonatomic, strong) UINavigationController *selectedViewController;

/**
 OCRouter的单例

 @return OCRouter
 */
+ (instancetype)shareInstance;

/**
 打开页面，外部打开时严格校验,不支持JLRoutes

 @param url 自定义链接,需要URLQueryAllowedCharacterSet
 */
+ (BOOL)openURL:(NSURL *)url;

/**
 注册内部使用的OCRouters
 */
- (void)registerInnerRouter;

/**
  打开页面，app内部调用可以同时支持外部方式和JLRoutes
 注意：
 1、JLRoutes只用于内部跳转，因为url中会暴露控制器名字和参数
 2、JLRoutes支持直接跳转，如果需要选中商城首页，url可以用外部调用的写法
 
 @param url 自定义链接,需要URLQueryAllowedCharacterSet
 
 example1:
 
 NSString *url = @"sumup://push/OCWebViewController?urlStr=""https://www.json.cn""&ignoreWebTitle=0&title=jsonf序列化";
 NSString *encodedUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
 
 [OCRouter openInnerURL:[NSURL URLWithString:encodedUrl]];
 
 example2:推荐使用这种方式构建

 NSDictionary *dic = @{
 @"urlStr":@"https://www.json.cn?title=序列化"
 ,@"ignoreWebTitle":@"0"
 ,@"title":@"josn序列化"
 };
 NSURLComponents *components = [NSString mapQuerysURLByDictionary:dic url:@"sumup://simple"];
 [OCRouter openURL:components.URL];
 
 注意:NSURLComponents通过[NSURLComponents alloc] initWithString:urlStr]初始化时，如果urlStr中包含中文，将返回nil
 */
+ (BOOL)openInnerURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
