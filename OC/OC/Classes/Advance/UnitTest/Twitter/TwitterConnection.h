//
//  TwitterConnection.h
//  OCMockTest
//
//  Created by yier on 2020/2/26.
//  Copyright © 2020 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterConnection : NSObject

- (NSArray *)fetchTwitters;

+ (NSArray *)fetchTwitters2;

- (void)fetchTwittersWithBlock:(void (^)(NSDictionary *result,NSError *error))block;

@end

