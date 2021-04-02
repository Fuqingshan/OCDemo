//
//  LKActionSheetModel.m
//  App
//
//  Created by yier on 2018/7/25.
//  Copyright © 2018 yier. All rights reserved.
//

#import "LKActionSheetModel.h"

@implementation LKActionSheetContentModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"type":@"type",
             @"content"  : @"content",
             @"detail"  : @"detail"
            };
}

@end

@implementation LKActionSheetModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"dataSource" : LKActionSheetContentModel.class,
            };
}

@end
