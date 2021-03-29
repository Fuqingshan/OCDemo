//
//  BaseTabBarViewController.m
//  OC
//
//  Created by yier on 2019/2/13.
//  Copyright © 2019 yier. All rights reserved.
//

#import "BaseTabBarViewController.h"
#import "SimpleViewController.h"
#import "AdvanceViewController.h"
#import "PracticeViewController.h"

#import "BaseTabBar.h"

@interface BaseTabBarViewController ()
@property(nonatomic, strong) RACDisposable *dispose;
@end

@implementation BaseTabBarViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifacation];
    // Do any additional setup after loading the view.
}

- (void)addNotifacation{
    @weakify(self);
    //如果之前已经注册过了，直接移除，防止重复
    if (self.dispose) {
        [self.dispose dispose];
        self.dispose = nil;
    }
   self.dispose = [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:ChangeLanguageNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        BaseTabBar *tabbar = (BaseTabBar *)self.tabBar;
        [tabbar getBaseItemsByTabBarItems:self.tabBar.items];
    }];
}

- (TabBarItemType)itemType{
    return self.selectedIndex;
}

- (void)setItemType:(TabBarItemType)itemType{
    if (self.selectedIndex == itemType) {
        return;
    }
    NSString *selectVCStr;
    switch (itemType) {
        case TabBarItemTypeSimple:
            selectVCStr = NSStringFromClass([SimpleViewController class]);
            break;
        case TabBarItemTypeAdvance:
            selectVCStr = NSStringFromClass([AdvanceViewController class]);
            break;
        case TabBarItemTypePractice:
            selectVCStr = NSStringFromClass([PracticeViewController class]);
            break;
    }
    
    UINavigationController *selectVC;
    for (UINavigationController *vc in self.viewControllers) {
        if ([NSStringFromClass([vc.topViewController class]) isEqualToString:selectVCStr]) {
            selectVC = vc;
            break;
        }
    }
    
    if (!selectVC) {
        LKLog(@"没有找到能对应的tabBarItem的ViewController");
        return;
    }
    
    self.selectedIndex = [self.viewControllers indexOfObject:selectVC];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
