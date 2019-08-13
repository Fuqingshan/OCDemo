//
//  NSArray+Helper.h
//  App
//
//  Created by chenfei on 24/11/2016.
//  Copyright © 2016 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Helper)

+ (instancetype)arrayWithJson:(NSString *)json;
- (NSString *)toJSONString;

- (NSArray *)map:(id (^)(id element))transform;

@end
