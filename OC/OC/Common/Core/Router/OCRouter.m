//
//  OCRouter.m
//  App
//
//  Created by yier on 2019/1/16.
//  Copyright © 2019 yier. All rights reserved.
//

#import "OCRouter.h"
#import "OCRouter+Simple.h"
#import "OCRouter+Advance.h"
#import "OCRouter+Practice.h"
#import "OCRouter+Mine.h"
#import "OCRouter+Common.h"

#import "OCParamsInfo.h"
#import "OCRouterModel.h"
#import <JLRoutes/JLRoutes.h>
#import "NSObject+FindTopViewController.h"

@interface OCRouter()
@property (nonatomic, strong) OCRouterPlistModel *plistModel;
@end

@implementation OCRouter

+ (void)initialize{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"OCModules" ofType:@"plist"];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:path];
    OCRouterPlistModel *plistModel = [OCRouterPlistModel yy_modelWithDictionary:plistDic];
    [OCRouter shareInstance].plistModel = plistModel;
}

#pragma mark - 校验外部调用是否合法
- (BOOL)validateRouterURL:(NSURL *)url{
    NSString *urlStr = [url.absoluteString stringByRemovingPercentEncoding];
    NSString *valideURL = [urlStr componentsSeparatedByString:@"?"].firstObject;
    if (![valideURL isValide]) {
        return NO;
    }
    
    //查找对应模块是否在简单
    for (OCRouterModel *model in self.plistModel.Simple.all) {
        if ([valideURL isEqualToString:model.url]) {
            return YES;
        }
    }
    //查找对应模块是否在高级
    for (OCRouterModel *model in self.plistModel.Advance.all) {
        if ([valideURL isEqualToString:model.url]) {
            return YES;
        }
    }
    //查找对应模块是否在联系
    for (OCRouterModel *model in self.plistModel.Practice.all) {
        if ([valideURL isEqualToString:model.url]) {
            return YES;
        }
    }
    
    //查找对应模块是否在我的页面
    for (OCRouterModel *model in self.plistModel.Mine.all) {
        if ([valideURL isEqualToString:model.url]) {
            return YES;
        }
    }
    
    //查找对应模块是否在公共部分
    for (OCRouterModel *model in self.plistModel.Common.all) {
        if ([valideURL isEqualToString:model.url]) {
            return YES;
        }
    }
    
    return NO;
}

+ (void)showAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"当前版本无法访问相关页面，请检查是否已更新至最新版本~" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"查看新版" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/id1407252536?mt=8"];
        [[UIApplication sharedApplication] openURL:url];
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

+ (instancetype)shareInstance{
    static  OCRouter * _router = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _router = [[self alloc] init] ;
    }) ;
    
    return _router;
}

- (ContainerViewController *)rootViewController{
    if(!_rootViewController){
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([rootVC isKindOfClass:[ContainerViewController class]]) {
            _rootViewController = (ContainerViewController *)rootVC;
        }
    }
    return _rootViewController;
}

- (UINavigationController *)selectedViewController{
    return self.rootViewController.tabbarVC.selectedViewController;
}

#pragma mark - 外部打开页面
+ (BOOL)openURL:(NSURL *)url{
    if (![[url scheme] isEqualToString:@"sumup"]) {
        return NO;
    }
    
    if (![[OCRouter shareInstance] validateRouterURL:url]) {
        [OCRouter showAlert];
        return NO;
    }
    
    if ([[url host] containsString:@"simple"]) {
        return [OCRouter openSimpleURL:url];
    }else if([[url host] containsString:@"advance"]) {
        return [OCRouter openAdvanceURL:url];
    }else if([[url host] containsString:@"practice"]) {
        return [OCRouter openPracticeURL:url];
    }else if([[url host] containsString:@"mine"]) {
        return [OCRouter openMineURL:url];
    }else if([[url host] containsString:@"common"]) {
        return [OCRouter openCommonURL:url];
    }else{
        return NO;
    }
    
    return YES;
}

#pragma mark - 内部打开页面
+ (BOOL)openInnerURL:(NSURL *)url{
    if (![[url scheme] isEqualToString:@"sumup"]) {
        return NO;
    }
    
    if ([[JLRoutes routesForScheme:@"sumup"] canRouteURL:url]) {
        return [[JLRoutes routesForScheme:@"sumup"]routeURL:url];
    }else{
        return [OCRouter openURL:url];
    }
}

#pragma mark - 注册内部使用的router
- (void)registerInnerRouter{
    /*
     Route是对应的匹配规则，handler是匹配到这个规则之后执行的结果，返回值YES表示解析参数正确，往下执行顺利
     */
    @weakify(self);
    [[JLRoutes routesForScheme:@"sumup"] addRoutes:@[@"/push/:controller",@"/present/:controller"] handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        @strongify(self);
        return [self handleRouterByParameters:parameters];
    }];
}

/**
 根据参数跳转

 @param parameters 参数
 @return YES表示正常跳转，NO表示在当前匹配规则下不满足跳转条件
 */
- (BOOL)handleRouterByParameters:(NSDictionary<NSString *,id> *)parameters{
    Class class = NSClassFromString(parameters[@"controller"]);
    if (!class) {
        return NO;
    }
    UIViewController *vc = [[class alloc] init];
    [self paramToVc:vc param:parameters];
    NSString *title = stringInDictionaryForKey(parameters, @"title");
    if ([title isValide]) {
        vc.title = title;
    }
    
    NSString *JLRoutePattern = stringInDictionaryForKey(parameters, @"JLRoutePattern");
    if ([JLRoutePattern isEqualToString:@"/push/:controller"]) {
       
    }else{
        /*
         如果当前存在present的vc，比如AlertController，再present一次会出问题
         注意：vc本身present两层是没问题的，但最好别这样做，因为不好控制层级
        */
        UIViewController *presentedViewController = self.selectedViewController.visibleViewController.presentedViewController;
        if (presentedViewController) {
            [presentedViewController dismissViewControllerAnimated:YES completion:^{
                [self.selectedViewController.topViewController presentViewController:vc animated:YES completion:nil];
            }];
        }else{
            [self.selectedViewController.topViewController presentViewController:vc animated:YES completion:nil];
        }
    }
    
    return YES;
}

#pragma mark - runtime将参数传递至需要跳转的控制器
- (void)paramToVc:(UIViewController *)vc param:(NSDictionary<NSString *,NSString *> *)parameters{
    NSMutableArray<YYClassPropertyInfo *> *propertys = [OCParamsInfo getPropertysInClass:[vc class] thresholds:@[NSStringFromClass([BaseViewController class]),NSStringFromClass([NSObject class])]];
    
    for (YYClassPropertyInfo *propertyInfo in propertys) {
        NSString *param = stringInDictionaryForKey(parameters, propertyInfo.name);
        if ([param isValide]) {
            [vc setValue:param forKey:propertyInfo.name];
        }
    }
}

@end
