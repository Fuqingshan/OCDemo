//
//  LKWifiHandle.h
//  App
//
//  Created by yier on 2018/6/15.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKWifiHandle : NSObject
@property (nonatomic,copy,readonly) NSString * wifiGateWay;//网关
@property (nonatomic,copy,readonly) NSString * wifiIP;//ip
@property (nonatomic,copy,readonly) NSString * wifiBroadcastAddress;//广播地址
@property (nonatomic,copy,readonly) NSString * wifiNetMast;//子网掩码
@property (nonatomic,copy,readonly) NSString * wifiInterface;//en0端口
@end
