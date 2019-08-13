//
//  NSNumber+Formatter.m
//  App
//
//  Created by chenfei on 15/12/2016.
//  Copyright © 2016 yier. All rights reserved.
//

#import "NSNumber+Formatter.h"
#import "NSString+Helper.h"

@implementation NSNumber (Formatter)

- (NSString *)currencyString
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    formatter.numberStyle = kCFNumberFormatterDecimalStyle; //加千位分隔符
    formatter.roundingMode = NSNumberFormatterRoundHalfEven;
    formatter.minimumFractionDigits = 2;
    formatter.maximumFractionDigits = 2;
    NSString *str = [formatter stringFromNumber:self];
    return str;
}

+ (NSNumber *)numberWithString:(NSString *)string {
    if (string && [string isNumeric] ) {
        return [[self class] numberWithDouble:[string doubleValue]];
    } else {
        return [[self class] numberWithFloat:0.0f];
    }
}

@end
