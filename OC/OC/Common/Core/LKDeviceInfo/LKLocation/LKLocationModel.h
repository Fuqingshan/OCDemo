//
//  LKLocationModel.h
//  App
//
//  Created by yier on 2018/6/20.
//  Copyright © 2018年 yier. All rights reserved.
//

@interface LKLocationModel : NSObject<YYModel>

/*
 * param           lat                          纬度（垂直方向）
 * param           lng                         经度（水平方向）
 * param           positionTime            创建时间
 * param           address                  详细地址
 * param           country                   国家
 * param           province                 省份
 * param           city                        城市
 * param           region                    区县
 * param           street                     街道
 * param           houseNumber          门牌号码
 * param           areaCode               电话区号
 * param           cityCode                城市编码(身份证前6位)
 */
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lng;
@property (nonatomic, copy) NSString *positionTime;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *houseNumber;
@property (nonatomic, copy) NSString *areaCode;
@property (nonatomic, copy) NSString *cityCode;

@end
