//
//  TwitterConnection.m
//  OCMockTest
//
//  Created by yier on 2020/2/26.
//  Copyright © 2020 yier. All rights reserved.
//

#import "TwitterConnection.h"

@implementation TwitterConnection

- (NSArray *)fetchTwitters{
    return @[];
}

+ (NSArray *)fetchTwitters2{
    return @[];
}

- (void)fetchTwittersWithBlock:(void (^)(NSDictionary *result,NSError *error))block{
    block(@{@"hh":@"hh"},nil);
}

@end
