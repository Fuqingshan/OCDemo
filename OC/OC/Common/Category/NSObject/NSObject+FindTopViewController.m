//
//  NSObject+FindTopViewController.m
//  App
//
//  Created by yier on 2018/4/28.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "NSObject+FindTopViewController.h"

@implementation NSObject (FindTopViewController)

- (UIViewController *)findTopViewController{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (!rootViewController) {
        return nil;
    }
    
    UIViewController *topVC = rootViewController;
    while (YES) {
        if ([topVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationVC = (UINavigationController *)topVC;
            topVC = navigationVC.visibleViewController;
        }else if ([topVC isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabbarVC = (UITabBarController *)topVC;
            topVC = tabbarVC.selectedViewController;
        }else if(topVC.presentedViewController){
            topVC = topVC.presentedViewController;
        }else if ([topVC isKindOfClass:[UIViewController class]]) {
            UIViewController *vc = (UIViewController *)topVC;
            topVC = vc;
            break;
        }else{
            topVC = nil;
            break;
        }
    }
    
    return topVC;
}

@end
