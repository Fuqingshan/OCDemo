//
//  LKWifiHandle.h
//  App
//
//  Created by yier on 2018/6/15.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKWifiHandle : NSObject
/*
 iOS8 - iOS13 ，用户在不同的网络间切换和接入时，mac 地址都不会改变，这也就使得网络运营商还是可以通过 mac 地址对用户进行匹配和用户信息收集，生成完整的用户信息。iOS14 提供 Wifi 加密服务，每次接入不同的 WiFi 使用的 mac 地址都不同。每过 24 小时，mac 地址还会更新一次。需要关注是否有使用用户网络 mac 地址的服务。
 */
@property (nonatomic,copy,readonly) NSString * wifiGateWay;//网关
@property (nonatomic,copy,readonly) NSString * wifiIP;//ip
@property (nonatomic,copy,readonly) NSString * wifiBroadcastAddress;//广播地址
@property (nonatomic,copy,readonly) NSString * wifiNetMast;//子网掩码
@property (nonatomic,copy,readonly) NSString * wifiInterface;//en0端口
@end
