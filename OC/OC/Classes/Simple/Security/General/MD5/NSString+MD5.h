//
//  NSString+MD5.h
//  MD5Demo
//
//  Created by Arlexovincy on 14-3-12.
//  Copyright (c) 2014年 Arlexovincy. All rights reserved.
// 16位其实就是32位去除头和尾各8位

#import <Foundation/Foundation.h>

@interface NSString(MD5)

//把字符串加密成32位小写md5字符串
+ (NSString*)MD5_32BitLower:(NSString *)inPutText;

//把字符串加密成32位大写md5字符串
+ (NSString*)MD5_32BitUpper:(NSString*)inPutText;


@end
