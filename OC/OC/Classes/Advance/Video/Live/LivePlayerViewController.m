//
//  LivePlayerViewController.m
//  OC
//
//  Created by yier on 2021/4/1.
//  Copyright © 2021 yier. All rights reserved.
//

/*理论上RTMP、RTSP、HTTP都可以用来做视频直播或点播。但通常来说，直播一般用 RTMP、RTSP，而点播用 HTTP。

 1，RTMP协议直播源
 香港卫视：rtmp://live.hkstv.hk.lxdns.com/live/hks

 2，RTSP协议直播源
 珠海过澳门大厅摄像头监控：rtsp://218.204.223.237:554/live/1/66251FC11353191F/e7ooqwcfbqjoo80j.sdp
 大熊兔（点播）：rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov

 3，HTTP协议直播源
 香港卫视：http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8
 CCTV1高清：http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8
 CCTV3高清：http://ivi.bupt.edu.cn/hls/cctv3hd.m3u8
 CCTV5高清：http://ivi.bupt.edu.cn/hls/cctv5hd.m3u8
 CCTV5+高清：http://ivi.bupt.edu.cn/hls/cctv5phd.m3u8
 CCTV6高清：http://ivi.bupt.edu.cn/hls/cctv6hd.m3u8
 苹果提供的测试源（点播）：http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/gear2/prog_index.m3u8
 */

#import "LivePlayerViewController.h"

@interface LivePlayerViewController ()

@end

@implementation LivePlayerViewController

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
    self.navigationItem.title = LocalizedString(@"直播拉流");
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"直播拉流");
    //更改样式之后刷新UI可以写在这儿
}

@end
