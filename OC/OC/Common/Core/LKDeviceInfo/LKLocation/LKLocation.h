//
//  LKLocation.h
//  App
//
//  Created by yier on 2018/6/19.
//  Copyright © 2018年 yier. All rights reserved.
//

/**
 这儿定位首先采用的高德定位，如果其它模块正在使用高德定位且处于连续定位中，requestLocationWithReGeocode:completionBlock:会失败（精度要求best时，如果拿到的精度少于这个，也会出现持续定位的情况），切换成系统定位，获取到精度之后转换坐标系到高德坐标系，做逆地址解析
 */

#import <Foundation/Foundation.h>
#import "LKLocationModel.h"

typedef void(^CompleteLocation)(LKLocationModel *locationModel, NSError *error);

@interface LKLocation : NSObject
+ (instancetype)shareInstance;
- (void)requestLocationComplete:(CompleteLocation)complete;

@end
