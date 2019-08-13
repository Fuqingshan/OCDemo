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

@end

@implementation BaseViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    NSLog(@"currentVC:\n%@",self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configBackgroundImage];
}

- (void)addNotifacation{
    @weakify(self);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ChangeLanguageNotification object:nil];
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:ChangeLanguageNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
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
