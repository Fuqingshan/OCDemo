//
//  LivePushViewController.m
//  OC
//
//  Created by yier on 2021/4/1.
//  Copyright © 2021 yier. All rights reserved.
//
/*
 推流一般用RTMP（Real Time Message Protocol实时消息传输），是一个基于TCP的协议族，是一种设计用来进行实时数据通信的网络协议，而且它的延迟只有1 ~ 3秒，由于网络不稳定，一般还会在主播端和播放端设置缓存。
 拉流常见的有三种：RTMP、HLS、HDL
 穿透性：端口是否被拦截
 RTMP：通过TCP传输码流数据，延迟1~3秒，但是有些比如1935端口可能会被禁，跨平台性差，适合互动直播
 HLS：苹果基于HTTP流媒体传输协议开发的，传输时视频切片，延迟会根据切片大小决定，一般大于10s，穿透性高，html5可以直接播放，跨平台性好，适合高延迟，非互动直播
 HDL：通过HTTP协议传输FLV文件，延迟1~3秒，略好于RTMP，穿透性强，跨平台性差，适合低延时互动直播
 */

//推流 LFLiveKit：框架支持RTMP，由Adobe公司开发
#import "LivePushViewController.h"

@interface LivePushViewController ()

@end

@implementation LivePushViewController

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
    self.navigationItem.title = LocalizedString(@"直播推流");
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"直播推流");
    //更改样式之后刷新UI可以写在这儿
}

@end
