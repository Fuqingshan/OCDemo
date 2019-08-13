//
//  NSDictionary+Helper.h
//  App
//
//  Created by liye on 2016/12/8.
//  Copyright © 2016年 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Helper)

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (NSString *)convertToJsonData:(NSDictionary *)dict;

@end
