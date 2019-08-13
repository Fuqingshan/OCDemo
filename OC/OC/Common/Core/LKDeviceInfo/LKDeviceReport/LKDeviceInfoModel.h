//
//  LKDeviceInfoModel.h
//  App
//
//  Created by yier on 2018/6/20.
//  Copyright © 2018年 yier. All rights reserved.
//

/*
 * param           equipmentModel               设备型号
 * param           equipmentName               设备名（xxx的iphone）
 * param           operateSystemVersion       系统版本
 * param           romMemoryTotalCapacity  存储容量
 * param           operateSystem                 操作系统
 * param           romMemoryFreeCapacity   储存剩余容量
 * param           ipAddress                        IP地址
 * param           root                                是否root（0和1表示）
 * param           simulator                         是否使用模拟器（0和1表示）
 * param           energy                             电池电量
 * param           resolution                        分辨率
 * param           crawlTime                        设备信息抓取时间
 
 * param           networkWay                     联网方式
 * param           ssid                                WiFi名称（ssid）
 * param           ramMemoryTotalCapacity  手机内存（ram）
 * param           networkCompany              数据服务商名称
 * param           dns                                 dns
 * param           mobileBrand                    手机品牌（iphone 6s）
 * param           appVersion                      APP版本
 * param           uuid                                uuid
 * param           udid                                udid
 * param           idfa                                 idfa
 * param           idfv                                 idfv
 * param           equipmentType                设备类型
 
 * param           operator(operatorStr)        运营商(networkCompany)
 * param           equipmentCode                设备身份码(udid)
 * param           equipmentId                     设备id(udid)
 * param           operateSystemModel         ios型号/model(equipmentModel)
 * param           equipmentType                 设备类型(mobileBrand)
 */

@interface LKDeviceInfoModel : NSObject<YYModel>
@property (nonatomic, copy) NSString *equipmentModel;
@property (nonatomic, copy) NSString *equipmentName;
@property (nonatomic, copy) NSString *operateSystemVersion;
@property (nonatomic, copy) NSString *romMemoryTotalCapacity;
@property (nonatomic, copy) NSString *operateSystem;
@property (nonatomic, copy) NSString *romMemoryFreeCapacity;
@property (nonatomic, copy) NSString *ipAddress;
@property (nonatomic, strong) NSNumber *root;
@property (nonatomic, strong) NSNumber *simulator;
@property (nonatomic, copy) NSString *energy;
@property (nonatomic, copy) NSString *resolution;
@property (nonatomic, strong) NSNumber *crawlTime;

@property (nonatomic, copy) NSString *networkWay;
@property (nonatomic, copy) NSString *ssid;
@property (nonatomic, copy) NSString *ramMemoryTotalCapacity;
@property (nonatomic, copy) NSString *networkCompany;
@property (nonatomic, copy) NSString *dns;
@property (nonatomic, copy) NSString *mobileBrand;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *udid;
@property (nonatomic, copy) NSString *idfa;
@property (nonatomic, copy) NSString *idfv;

/**
 下面这些是重复的，依然要传
 */
@property (nonatomic, copy) NSString *operatorStr;
@property (nonatomic, copy) NSString *equipmentCode;
@property (nonatomic, copy) NSString *equipmentId;
@property (nonatomic, copy) NSString *operateSystemModel;
@property (nonatomic, copy) NSString *equipmentType;

@end
