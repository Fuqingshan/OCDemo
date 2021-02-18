//
//  LKLocation.m
//  App
//
//  Created by yier on 2018/6/19.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "LKLocation.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "LKLocationTransform.h"

static NSString *const AMapAPIKey = @"123456";

@interface LKLocation()<CLLocationManagerDelegate,AMapSearchDelegate>
@property (nonatomic, strong) AMapLocationManager *amapLocationManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, copy) CompleteLocation complete;
@end

@implementation LKLocation

+ (instancetype)shareInstance{
    
    static  LKLocation * _location = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _location  = [[self alloc] init] ;
    }) ;
    
    return _location ;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //amapLocationManager不能用懒加载初始化，会卡主线程
        [AMapServices sharedServices].apiKey = AMapAPIKey;
        self.amapLocationManager = [[AMapLocationManager alloc] init];
        self.amapLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.amapLocationManager.distanceFilter = kCLDistanceFilterNone;
        self.amapLocationManager.locationTimeout = 3;
        self.amapLocationManager.reGeocodeTimeout = 3;
        
        self.search = [AMapSearchAPI new];
        self.search.timeout = 3.0f;
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    return self;
}

- (void)requestLocationComplete:(CompleteLocation)complete{
    //定位必须在主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.complete){
            LKLog(@"其他地方使用定位服务，导致这次定位被打断");
            !self.complete?:self.complete(nil,[NSError errorWithDomain:@"其他地方使用定位服务，导致这次定位被打断" code:500 userInfo:nil]);
            self.complete = nil;
            [self.amapLocationManager stopUpdatingLocation];
            [self stopLocation];
            [self cancelSearch];
        }
        
        self.complete = complete;
        [self startAmapLocation];
    });
}

- (void)startAmapLocation{
   @weakify(self);
    AMapLocatingCompletionBlock block = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
       @strongify(self);
        if (error) {
            //其他非定位引起的异常且request返回YES，虽然没遇到过
            [self starLocationIfAuthorized];
            return ;
        }
        //开始逆地址解析
        if (location) {
            [self searchReGeocodeWithLocation:location];
        }
    };
    BOOL request = [self.amapLocationManager requestLocationWithReGeocode:NO completionBlock:block];
    //因为持续定位引起的失败，换成系统定位
    if (!request) {
        [self starLocationIfAuthorized];
    }
}

- (void)starLocationIfAuthorized{
    //有权限，但是返回失败的情况,使用系统方法定位
    if ([LKLocation locationServicesAuthorized]) {
        [self startLocationManager];
    }else{
        LKLog(@"没有定位权限");
        !self.complete?:self.complete(nil,[NSError errorWithDomain:@"没有定位权限" code:500 userInfo:nil]);
        self.complete = nil;
    }
}
/*
 1、iOS14 新增用户大致位置选项可供用户选择，iOS14 授权弹窗新增的 Precise的开关默认会选中精确位置。用户通过这个开关可以进行更改，当把这个值设为 On 时，地图上会显示精确位置；切换为Off时，将显示用户的大致位置。
 2、通过用户在 “隐私设置” 中设置来开启精确定位，但是可能用户宁可放弃使用这个应用也不愿意开启
 3、iOS14 在 CLLocationManager 新增两个方法可用于向用户申请临时开启一次精确位置权限，这个主要用于你无权访问精准位置时使用
 4、使用方法，首先在 Info.plist 中配置“NSLocationTemporaryUsageDescriptionDictionary”字典中需要配置 key 和 value 表明使用位置的原因，以及具体的描述。
 5、requestTemporaryFullAccuracyAuthorizationWithPurposeKey:(NSString *)purposeKey completion:，purposeKey就是info.plist里面NSLocationTemporaryUsageDescriptionDictionary的key，根据key展示给用户精准定位的目的
 
 ps：对于地理位置不敏感的App 来说，iOS14 也可以通过直接在 info.plist 中添加 NSLocationDefaultAccuracyReduced 为 true 默认请求大概位置。即使用户想要为该 App 开启精确定位权限，也无法开启。当 App 在 Background 模式下，如果并未获得精确位置授权，那么 Beacon 及其他位置敏感功能都将受到限制。
 */
- (void)startLocationManager {
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self stopLocation];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)stopLocation{
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
}

#pragma mark -- CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [self stopLocation];
    LKLogm(@"LKLocation ----- 定位成功:%@",locations);
    
    CLLocation *location = [locations lastObject];
    if (location) {
        [self searchReGeocodeWithLocation:location];
    }else{
        LKLog(@"使用CLLocationManager定位成功之后没有拿到location");
        !self.complete?:self.complete(nil,[NSError errorWithDomain:@"使用CLLocationManager定位成功之后没有拿到location" code:500 userInfo:nil]);
        self.complete = nil;
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self stopLocation];
    LKLogm(@"LKLocation ----- 定位失败:%@",error);
    
    !self.complete?:self.complete(nil,error);
    self.complete = nil;
}

#pragma mark - search

- (void)searchReGeocodeWithLocation:(CLLocation *)location{
    LKLocationTransform *transform = [[LKLocationTransform alloc] initWithLatitude:location.coordinate.latitude andLongitude:location.coordinate.longitude];
    transform = [transform transformFromGPSToGD];
    
    AMapReGeocodeSearchRequest *request = [AMapReGeocodeSearchRequest new];
    request.location = [AMapGeoPoint locationWithLatitude:transform.latitude longitude:transform.longitude];
    request.requireExtension = YES;
    self.search.delegate = self;
    [self.search AMapReGoecodeSearch:request];
}

- (void)cancelSearch{
    self.search.delegate = nil;
    [self.search cancelAllRequests];
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    !self.complete?:self.complete(nil,error);
    self.complete = nil;
    [self cancelSearch];
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    LKLocationModel *locationModel = [self createLocationModelByRequest:request response:response];
    !self.complete?:self.complete(locationModel,nil);
    self.complete = nil;
    [self cancelSearch];
}

- (LKLocationModel *)createLocationModelByRequest:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    LKLocationModel *locationModel = [LKLocationModel new];
    locationModel.lat = @(request.location.latitude);
    locationModel.lng = @(request.location.longitude);
    locationModel.positionTime = [[NSDate date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    locationModel.address = response.regeocode.formattedAddress;
    locationModel.country = response.regeocode.addressComponent.country;
    locationModel.province = response.regeocode.addressComponent.province;
    locationModel.city = response.regeocode.addressComponent.city;
    locationModel.region = response.regeocode.addressComponent.district;
    locationModel.street = response.regeocode.addressComponent.streetNumber.street;
    locationModel.houseNumber = response.regeocode.addressComponent.streetNumber.number;
    locationModel.areaCode = response.regeocode.addressComponent.adcode;
    locationModel.cityCode = response.regeocode.addressComponent.citycode;
    
    return locationModel;
}

#pragma mark - lazy load

+ (BOOL)locationServicesAuthorized
{
    return [CLLocationManager locationServicesEnabled] &&
    [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied;
}

@end
