//
//  ContainerViewController.h
//  OC
//
//  Created by yier on 2019/3/19.
//  Copyright © 2019 yier. All rights reserved.
//
//如果不做qq的样式，可以不用container，storyboard的rootViewController用BaseTabBarViewController就可以了

#import "BaseViewController.h"
#import "SettingViewController.h"
#import "MineViewController.h"
#import "BaseTabBarViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContainerViewController : BaseViewController
@property (nonatomic, strong) SettingViewController *settingVC;
@property (nonatomic, strong) MineViewController * mineVC;
@property (nonatomic, strong) BaseTabBarViewController *tabbarVC;

- (void)showMine;
- (void)hiddenMine;
@end

NS_ASSUME_NONNULL_END
