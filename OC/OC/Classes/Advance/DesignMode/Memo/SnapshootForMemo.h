//
//  SnapshootForMemo.h
//  OC
//
//  Created by yier on 2019/8/8.
//  Copyright © 2019 yier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MemoMode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SnapshootForMemo : NSObject

+ (void)save:(MemoMode *)mode;
+ (MemoMode *)read;

@end

NS_ASSUME_NONNULL_END
