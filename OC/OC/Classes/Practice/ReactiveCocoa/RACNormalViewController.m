//
//  RACNormalViewController.m
//  OC
//
//  Created by yier on 2021/3/29.
//  Copyright © 2021 yier. All rights reserved.
//

#import "RACNormalViewController.h"

@interface RACNormalViewController ()

@end

@implementation RACNormalViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)initData{
    
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"常见用法");

}

@end
