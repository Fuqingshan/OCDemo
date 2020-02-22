//
//  DisplayLinkDelloc.h
//  AVFoundationDemo
//
//  Created by yier on 2020/2/17.
//  Copyright © 2020 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DisplayLinkDelloc : NSProxy

+ (instancetype)weakProxyForObject:(id)targetObject;

@end

NS_ASSUME_NONNULL_END
