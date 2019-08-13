//
//  LKWifiInfo.m
//  App
//
//  Created by yier on 2018/6/15.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "LKWifiInfo.h"
#import "LKWifiHandle.h"

@interface LKWifiInfo()
@property (nonatomic,copy,readwrite) NSString * BSSID;
@property (nonatomic,copy,readwrite) NSString * SSID;//wifi名称
@property (nonatomic,strong) NSDictionary * info;
@property (nonatomic,strong) LKWifiHandle * wifiHandle;
@end

@implementation LKWifiInfo

-(instancetype)initWithInfo:(NSDictionary *)info{
    self = [self init];
    if (self) {
        // 这里其实对应的有三个key:kCNNetworkInfoKeySSID、kCNNetworkInfoKeyBSSID、kCNNetworkInfoKeySSIDData，
        // 不过它们都是CFStringRef类型的
        //  WiFiName = [info objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
        self.info = info;
        self.SSID = info[@"SSID"];
        self.BSSID = info[@"BSSID"];
    }
    return self;
}

-(NSString *)SSID{
    if ([_SSID isKindOfClass:[NSString class]] && _SSID.length > 0) {
        return _SSID;
    }
    return @"";
}

-(NSString *)BSSID{
    if ([_BSSID isKindOfClass:[NSString class]] && _BSSID.length > 0) {
        return _BSSID;
    }
    return @"";
}

-(LKWifiHandle *)wifiHandle{
    if (!_wifiHandle) {
        _wifiHandle = [[LKWifiHandle alloc] init];
    }
    return _wifiHandle;
}

-(NSString *)wifiGateWay{
    return self.wifiHandle.wifiGateWay;
}

-(NSString *)wifiIP{
    return self.wifiHandle.wifiIP;
}

-(NSString *)wifiBroadcastAddress{
    return self.wifiHandle.wifiBroadcastAddress;
}

-(NSString *)wifiNetMast{
    return self.wifiHandle.wifiNetMast;
}

-(NSString *)wifiInterface{
    return self.wifiHandle.wifiInterface;
}

@end
