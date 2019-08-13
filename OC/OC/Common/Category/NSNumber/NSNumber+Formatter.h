//
//  NSNumber+Formatter.h
//  App
//
//  Created by chenfei on 15/12/2016.
//  Copyright © 2016 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Formatter)

@property(nonatomic, strong, readonly) NSString *currencyString;

/**
 *    NSString转为NSNumber
 *
 *    @param    string    字符串,
 *
 *    @return    NSNumber, 如果string为nil或@""或内容不是数字,返回`0`
 */
+ (NSNumber *)numberWithString:(NSString *)string;

@end
