//
//  NSDate+Helper.h
//  App
//
//  Created by chenfei on 15/12/2016.
//  Copyright © 2016 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DateSeparatorStyle) {
    DateSeparatorStyleDot,   // .
    DateSeparatorStyleDash,  // -
    DateSeparatorStyleSpace, //
    DateSeparatorStyleWord,  // 年月日
};

@interface NSDate (Helper)

+ (NSString *)dateStringYMDHMS:(time_t)timestamp style:(DateSeparatorStyle)style;
+ (NSString *)dateStringYMD:(time_t)timestamp style:(DateSeparatorStyle)style;
+ (NSString *)dateStringYMDHMS:(time_t)timestamp;
+ (NSString *)dateStringYMD:(time_t)timestamp;
+ (NSMutableArray *)dateArrayWithNowDate;

@end
