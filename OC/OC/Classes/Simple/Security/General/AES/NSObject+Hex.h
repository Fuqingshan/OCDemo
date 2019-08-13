//
//  NSObject+Hex.h
//  OC
//
//  Created by yier on 2019/3/12.
//  Copyright © 2019 yier. All rights reserved.
//
//加密之后的数据可以转成16进制在网络中传输
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Hex)

/**
 将加密后的Data转为16进制字符串

 @param data 加密后的data
 @return 16进制字符串
 */
+ (NSString *)Hex_DataToHexStringByData:(NSData *)data;

/**
 把加密的16进制字符串转为2进制NSData类型

 @param str 加密后的字符串
 @return 16进制的data
 */
+ (NSData *)Hex_StringToHexDataByString:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
