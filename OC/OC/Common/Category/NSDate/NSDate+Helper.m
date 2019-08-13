//
//  NSDate+Helper.m
//  App
//
//  Created by chenfei on 15/12/2016.
//  Copyright © 2016 yier. All rights reserved.
//

#import "NSDate+Helper.h"

@implementation NSDate (Helper)

+ (NSString *)dateStringYMDHMS:(time_t)timestamp style:(DateSeparatorStyle)style
{
    NSString *format = @"";
    switch (style) {
        case DateSeparatorStyleDot:
            format = @"yyyy.MM.dd HH:mm:ss";
            break;
        case DateSeparatorStyleDash:
            format = @"yyyy-MM-dd HH:mm:ss";
            break;
        case DateSeparatorStyleWord:
            format = @"yyyy年MM月dd日 HH:mm:ss";
            break;
        case DateSeparatorStyleSpace:
            format = @"yyyy MM dd HH:mm:ss";
            break;
        default:
            format = @"yyyy-MM-dd HH:mm:ss";
            break;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return [date stringWithFormat:format];
}

+ (NSString *)dateStringYMD:(time_t)timestamp style:(DateSeparatorStyle)style
{
    NSString *format = @"";
    switch (style) {
        case DateSeparatorStyleDot:
            format = @"yyyy.MM.dd";
            break;
        case DateSeparatorStyleDash:
            format = @"yyyy-MM-dd";
            break;
        case DateSeparatorStyleWord:
            format = @"yyyy年MM月dd日";
            break;
        case DateSeparatorStyleSpace:
            format = @"yyyy MM dd";
            break;
        default:
            format = @"yyyy-MM-dd";
            break;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return [date stringWithFormat:format];
}

+ (NSString *)dateStringYMDHMS:(time_t)timestamp
{
    return [self dateStringYMDHMS:timestamp style:DateSeparatorStyleDash];
}

+ (NSString *)dateStringYMD:(time_t)timestamp
{
    return [self dateStringYMD:timestamp style:DateSeparatorStyleDash];
}

+(NSMutableArray *)dateArrayWithNowDate
{
    NSMutableArray * yearsNum = [[NSMutableArray alloc]init];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger year = [dateComponent year];
    for (NSInteger i = year; i>=year-9; i--) {
        [yearsNum addObject:[NSString stringWithFormat:@"%ld",(long)i]];
    }
    return yearsNum;
}
@end
