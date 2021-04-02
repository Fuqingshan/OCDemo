//
//  VideoPublishViewController.m
//  OC
//
//  Created by yier on 2021/4/1.
//  Copyright © 2021 yier. All rights reserved.
//
/*
 GPUImage，纯OC语言框架，封装好了各种滤镜同时也可以编写自定义的滤镜，其本身内置了多达125种常见的滤镜效果.
 GPUImage，3.0版本基于metal，1.0和2.0基于OpenGLES
 */

#import "VideoPublishViewController.h"

@interface VideoPublishViewController ()

@end

@implementation VideoPublishViewController

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
    self.navigationItem.title = LocalizedString(@"发布");
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"发布");
    //更改样式之后刷新UI可以写在这儿
}

@end
