//
//  VideoViewController.m
//  OC
//
//  Created by yier on 2019/8/12.
//  Copyright © 2019 yier. All rights reserved.
//

#import "VideoViewController.h"

@interface VideoViewController ()

@end

@implementation VideoViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"视频");
    
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"视频");
}

- (void)initData{
   
}

@end
