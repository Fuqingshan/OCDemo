//
//  BaseViewController.m
//  OC
//
//  Created by yier on 2019/2/12.
//  Copyright © 2019 yier. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()
@property (nonatomic, strong, readwrite) UIImageView *background;
@property(nonatomic, strong) RACDisposable *dispose;
@end

@implementation BaseViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    NSLog(@"currentVC:\n%@",self);

    //默认显示，需要隐藏的页面重写viewWillAppear加上[self.navigationController setNavigationBarHidden:YES animated:YES]
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //注意：需要禁用手势的页面只能在viewdidAppear禁用。在willapear禁用，如果从禁用的页面vc1 push到没有禁用的页面vc2，从vc2侧滑返回，此时willApear会走vc1的禁用方法，导致pop返回，但没有pop动画，此时页面会卡主
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configBackgroundImage];
}

- (void)addNotifacation{
    @weakify(self);
    //如果之前已经注册过了，直接移除，防止重复
    if (self.dispose) {
        [self.dispose dispose];
        self.dispose = nil;
    }
   self.dispose =  [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:ChangeLanguageNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        [self configBackgroundImageContent];
    }];
}

- (void)configBackgroundImage{
    self.background = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.background];
    [self.view sendSubviewToBack:self.background];
    [self.background mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self configBackgroundImageContent];
    [self addNotifacation];
}

- (void)configBackgroundImageContent{
    NSString *symbol;
    switch ([LanguageManager shareInstance].type) {
        case LanguageTypeCH:
            symbol = @"name";
            break;
        case LanguageTypeEN:
            symbol = @"writer";
    }
    self.background.image = [UIImage imageNamed:[NSString stringWithFormat:@"vc_%@_bg.png",symbol]];
    [self changeLanguageEvent];
}

- (void)changeLanguageEvent{
    
}

@end
