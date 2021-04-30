//
//  AppDelegate.m
//  OC
//
//  Created by yier on 2019/2/12.
//  Copyright © 2019 yier. All rights reserved.
//

#import "AppDelegate.h"
#import "OCCrashMonitor.h"

@implementation AppDelegate(Appearance)

- (void)configAppearance{
    //左右item的颜色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //中间Title字体颜色样式
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName :[UIColor whiteColor]};
    //设置导航背景透明
    [[UINavigationBar appearance] setShadowImage:[UIImage imageWithColor:LKHexColor(0xE1E1E1)]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:LKHexColor(0x4CFFFFFF)] forBarMetrics:UIBarMetricsDefault];
}

@end

@interface AppDelegate ()
@property(nonatomic, strong) UIImageView *maskView;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self configAppearance];
    [OCCrashMonitor registerExceptionHandler];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self p_addMaskView];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self p_removeMaskView];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//4.2 ~ 9.0
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation{
//    if ([[url scheme] isEqualToString:@"sumup"]){
//        return [OCRouter openURL:url];
//    }else{
//        return YES;
//    }
//}

//>=9.0
- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options{
    if ([[url scheme] isEqualToString:@"sumup"]){
        return [OCRouter openURL:url];
    }else{
        return YES;
    }
}

#pragma mark - 添加蒙层
- (UIImageView *)maskView{
    if(!_maskView){
        _maskView = [[UIImageView alloc]init];
        _maskView.hidden = YES;
        _maskView.alpha = 1.0;
        _maskView.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
        _maskView.image = [[UIImage screenShot] blurredImage];
    }
    return _maskView;
}

- (void)p_addMaskView{
    self.maskView.hidden = NO;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.maskView];
}

- (void)p_removeMaskView{
    self.maskView.alpha = 0.7;
    [UIView animateWithDuration:0.2 animations:^{
        self.maskView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }];
}

@end
