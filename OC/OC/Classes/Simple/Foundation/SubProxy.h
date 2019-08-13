//
//  SubProxy.h
//  OC
//
//  Created by yier on 2019/2/27.
//  Copyright © 2019 yier. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RealProxyHandler: NSObject<NSCoding>
@property (nonatomic, copy) NSString *name;

//- (void)eat;
@end

@interface SubProxy : NSProxy

@end

NS_ASSUME_NONNULL_END
