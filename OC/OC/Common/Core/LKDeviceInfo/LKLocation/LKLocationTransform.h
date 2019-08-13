//
//  LKLocationTransform.h
//  App
//
//  Created by yier on 2018/6/21.
//  Copyright © 2018年 yier. All rights reserved.
//


@interface LKLocationTransform : NSObject<YYModel>
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;

- (id)initWithLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude;

/*
 坐标系：
 WGS-84：是国际标准，GPS坐标（Google Earth使用、或者GPS模块）
 GCJ-02：中国坐标偏移标准，Google Map、高德、腾讯使用
 BD-09 ：百度坐标偏移标准，Baidu Map使用
 */

#pragma mark - 从GPS坐标转化到高德坐标
- (id)transformFromGPSToGD;

#pragma mark - 从高德坐标转化到百度坐标
- (id)transformFromGDToBD;

#pragma mark - 从百度坐标到高德坐标
- (id)transformFromBDToGD;

#pragma mark - 从高德坐标到GPS坐标
- (id)transformFromGDToGPS;

#pragma mark - 从百度坐标到GPS坐标
- (id)transformFromBDToGPS;

#pragma mark - 从GPS坐标到百度坐标
- (id)transformFromGPSToBD;
@end
