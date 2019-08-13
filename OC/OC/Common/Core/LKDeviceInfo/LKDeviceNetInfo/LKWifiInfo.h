//
//  LKWifiInfo.h
//  App
//
//  Created by yier on 2018/6/15.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKWifiInfo : NSObject
@property (nonatomic,copy,readonly) NSString * BSSID;
@property (nonatomic,copy,readonly) NSString * SSID;//wifi名称

@property (nonatomic,readonly) NSString * wifiGateWay;//网关
@property (nonatomic,readonly) NSString * wifiIP;//ip
@property (nonatomic,readonly) NSString * wifiBroadcastAddress;//广播地址
@property (nonatomic,readonly) NSString * wifiNetMast;//子网掩码
@property (nonatomic,readonly) NSString * wifiInterface;//en0端口

-(instancetype)initWithInfo:(NSDictionary *)info;
@end
