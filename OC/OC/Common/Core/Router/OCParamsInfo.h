//
//  OCParamsInfo.h
//  App
//
//  Created by yier on 2019/1/28.
//  Copyright © 2019 yier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCParamsInfo : NSObject

+ (NSMutableArray<YYClassPropertyInfo *> *)getPropertysInClass:(Class)cls thresholds:(NSArray<NSString *> *)thresholds;

@end

NS_ASSUME_NONNULL_END
