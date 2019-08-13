//
//  NSString+URLQuery.h
//  App
//
//  Created by yier on 2018/12/19.
//  Copyright © 2018 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (URLQuery)

/**
 把url中的query部分转成dictionary
 */
- (NSDictionary *)params;

/**
 把字典转成URL的参数部分
 */
+ (NSString *)mapDictionaryToURLQueryString:(NSDictionary *)dic;


/**
 把querys字典和url转化成NSURLComponents

 @param dic querys
 @param url 排除querys的前面部分
 @return NSURLComponents
 */
+ (NSURLComponents *)mapQuerysURLByDictionary:(NSDictionary *)dic url:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
