//
//  VideoPlayerViewController.m
//  OC
//
//  Created by yier on 2021/4/1.
//  Copyright © 2021 yier. All rights reserved.
//

#import "VideoPlayerViewController.h"

@interface VideoPlayerViewController ()

@end

@implementation VideoPlayerViewController

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
    self.navigationItem.title = LocalizedString(@"短视频");
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"短视频");
    //更改样式之后刷新UI可以写在这儿
}
@end
