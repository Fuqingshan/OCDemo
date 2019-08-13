//
//  NSMutableArray+RACLifting.h
//  MallIM
//
//  Created by Ruoyu Fu on 14-5-12.
//  Copyright (c) 2014年 Jumei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;
@interface NSMutableArray (RACLifting)

- (RACSignal *)rac_addObjectSignal;
- (RACSignal *)rac_removeObjectSignal;
- (RACSignal *)rac_insertObjectsAtIndexes;
@end
