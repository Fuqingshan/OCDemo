//
//  NSString+Helper.m
//  App
//
//  Created by chenfei on 10/11/2016.
//  Copyright © 2016 yier. All rights reserved.
//

#import "NSString+Helper.h"
#import "NSDate+Helper.h"
#import "NSNumber+Formatter.h"

@implementation NSString (Helper)

+ (BOOL)isNilOrEmpty:(NSString *)string
{
    return string == nil || string.length == 0;
}

- (BOOL)isCaptcha
{
    return [self matchesRegex:@"^[0-9]{6}$" options:0];
}

- (BOOL)isAllNumber
{
    return [self matchesRegex:@"^[0-9]*$" options:0];
}

- (BOOL)isPhoneNumber
{
    return [self matchesRegex:@"^1[3456789][0-9]{9}$" options:0];
}

- (BOOL)isIDCardNumber
{
    return [self matchesRegex:@"^[1-9]\\d{5}[1-9]\\d{3}((0[1-9])|(1[0-2]))((0[1-9])|([1|2]\\d)|3[0-1])\\d{3}([\\d|x|X]{1})$" options:0];
}

- (BOOL)isEmailNumber{
    return [self matchesRegex:@"^\\w+((-\\w+)|(\\.\\w+))*\\@[A-Za-z0-9]+((\\.|-)[A-Za-z0-9]+)*\\.[A-Za-z0-9]+$" options:0];
}

- (BOOL)isBankCardNumber
{
    return [self matchesRegex:@"^[0-9]{15,20}$" options:0];
}

- (BOOL)isCreditCardNumber{
    return [self matchesRegex:@"^[0-9]{12,18}$" options:0];
}

- (BOOL)isBankCardNumber16219
{
    return [self matchesRegex:@"^[0-9]{16,19}$" options:0];
}

- (BOOL)isPassword
{
    return [self matchesRegex:@"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,16}$" options:0];
}

- (BOOL)isChineseCharacterName
{
    return [self matchesRegex:@"^[\u4E00-\u9FA5]{1,16}(?:·[\u4E00-\u9FA5]{1,16})*$" options:0];
}

- (BOOL)isChineseNumberLetterAndDot{
    return [self matchesRegex:@"^[\u4e00-\u9fa5_a-zA-Z0-9·]+$" options:0];
}

- (NSString *)formatTelNumber {
    NSString *tel = self;
    if ([tel hasPrefix:@"+86"]) {
        tel = [tel substringFromIndex:4];
    }
    tel = [tel stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    tel = [tel stringByReplacingOccurrencesOfString:@" " withString:@""];
    tel = [tel stringByReplacingOccurrencesOfString:@" " withString:@""];
    tel = [tel stringByReplacingOccurrencesOfString:@"(" withString:@""];
    tel = [tel stringByReplacingOccurrencesOfString:@")" withString:@""];
    tel = [tel stringByReplacingOccurrencesOfString:@"（" withString:@""];
    tel = [tel stringByReplacingOccurrencesOfString:@"）" withString:@""];
    tel = [tel stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return tel;
}

- (BOOL)isChineseAndAtoZ
{
    return [self matchesRegex:@"^[A-Za-z0-9_,，.。？?~!@#$%^&*()——+《》{}【】|、：；“‘… \u4e00-\u9fa5]+$" options:0];
}

- (BOOL)isContainsEmoji {
    NSString *string = self;
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}

+ (NSString *)changeToEncrypStr:(NSString *)originStr fromIndex:(NSInteger)index length:(NSInteger)length
{
    if ([self isNilOrEmpty:originStr]) {
        return @"";
    }
    
    NSMutableString *starStr=[NSMutableString stringWithFormat:@""];
    for (int i=0; i<length; i++) {
        [starStr appendFormat:@"*"];
    }
    
    NSString *encryptStr;
    encryptStr = originStr;
    if (originStr.length > 1)
        encryptStr=[originStr stringByReplacingCharactersInRange:NSMakeRange(index, length) withString:starStr];
    return encryptStr;
}

- (NSString *)charAtIndex:(NSUInteger)index
{
    if (index < self.length)
        return [self substringWithRange:NSMakeRange(index, 1)];
    return @"";
}

- (NSString *)trimLeft
{
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSUInteger i = 0;
    for (; i < self.length; ++i) {
        unichar uc = [self characterAtIndex:i];
        if (![charSet characterIsMember:uc])
            break;
    }
    return [self substringWithRange:NSMakeRange(i, self.length-i)];
}

- (NSString *)trimRight
{
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSUInteger i = self.length;
    for (; i > 0; --i) {
        unichar uc = [self characterAtIndex:i-1];
        if (![charSet characterIsMember:uc])
            break;
    }
    return [self substringWithRange:NSMakeRange(0, i)];
}

- (NSString *)trim
{
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:charSet];
}

- (NSString *)formatAsPhoneNumber
{
    NSString *phoneString = @"";
    for (int i = 0; i < self.length; ++i) {
        NSString *digit = [self charAtIndex:i];
        phoneString = [phoneString stringByAppendingString:digit];
        if (i == 2 || i == 6)
            phoneString = [phoneString stringByAppendingString:@" "];
    }
    return [phoneString trimRight];
}

- (NSString *)formatAsBankCardNumber
{
    NSString *bankCardString = @"";
    for (int i = 0; i < self.length; ++i) {
        NSString *digit = [self charAtIndex:i];
        bankCardString = [bankCardString stringByAppendingString:digit];
        if (i % 4 == 3)
            bankCardString = [bankCardString stringByAppendingString:@" "];
    }
    return [bankCardString trimRight];
}

- (NSUInteger)indexOfString:(NSString *)str
{
    NSRange range = [self rangeOfString:str];
    return range.location;
}

- (NSAttributedString *)currencyStringWithBigFont:(UIFont *)bigFont
                                        smallFont:(UIFont *)smallFont
                                            color:(UIColor *)color
{
    NSString *string = self.currencyString;
    NSArray *components = [string componentsSeparatedByString:@"."];
    NSString *str0 = components.firstObject;
    NSString *str1 = components.lastObject;
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
    attributedStr.yy_font = bigFont;
    attributedStr.yy_color = color;
    [attributedStr yy_setFont:smallFont range:NSMakeRange(str0.length+1, str1.length)];
    return attributedStr;
}

- (NSString *)currencyString
{
    NSNumber *num = [NSNumber numberWithDouble:self.doubleValue];
    return num.currencyString;
}

- (NSString *)dateStringByTimestampString
{
    long time = [self longValue]/1000;
    return [NSDate dateStringYMD:time];
}

- (NSString *)dateStringByYMDHMS
{
    NSArray *array = [self componentsSeparatedByString:@" "];    
    if (array.count)
        return array.firstObject;
    return nil;
}

- (NSMutableAttributedString *)currencySignStringWithBigFont:(UIFont *)bigFont
                                                   smallFont:(UIFont *)smallFont
                                                       color:(UIColor *)color
{
    NSString *string = self.currencyString;
    NSArray *components = [string componentsSeparatedByString:@"."];
    NSString *str0 = components.firstObject;
    NSString *str1 = components.lastObject;
    NSString *str = [NSString stringWithFormat:@"￥%@",string];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    attributedStr.yy_font = bigFont;
    attributedStr.yy_color = color;
    [attributedStr yy_setFont:smallFont range:NSMakeRange(str0.length+1, str1.length+1)];
    [attributedStr yy_setFont:smallFont range:NSMakeRange(0, 1)];

    return attributedStr;
}

- (NSString *)dateStringWithOldFormat:(NSString *)oldFormat newFormat:(NSString *)newFormat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:oldFormat];
    NSDate *date = [dateFormatter dateFromString:self];
    [dateFormatter setDateFormat:newFormat];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

- (NSString *)getIDCardToBirthdayDate{
    if (self.length != 18) {
        return nil;
    }
    NSMutableString *result = [NSMutableString stringWithCapacity:0];
    
    NSString *dateStr = [self substringWithRange:NSMakeRange(6, 8)];
    NSString  *year = [dateStr substringWithRange:NSMakeRange(0, 4)];
    NSString  *month = [dateStr substringWithRange:NSMakeRange(4, 2)];
    NSString  *day = [dateStr substringWithRange:NSMakeRange(6,2)];
    
    [result appendString:year];
    [result appendString:@"-"];
    [result appendString:month];
    [result appendString:@"-"];
    [result appendString:day];
    
    return result;
}

+ (BOOL)isPasswordTooSimple:(NSString *)password {
    
    NSString *pattern = @"[a-zA-Z0-9]{6,19}+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    
    if (isMatch) {
        //判断是否相同
        int countSame = 0;
        NSString *newPassword = [password substringToIndex:1];
        for (int i = 0; i < password.length; i++) {//是否全部相同
            NSString *newPassword1;
            if (i == 0) {
                newPassword1 = [password substringToIndex:i + 1]; //当 i 为 0 的时候  取下表为 1 的字符串
            }else{
                //当 i 大于 0 时 我们取下标为 i + 1 新的string.length 为 i 个 所有我们再从后面往前面取
                newPassword1 = [[password substringToIndex:i + 1] substringFromIndex:i];
            }
            if ([newPassword1 isEqualToString:newPassword]) {
                countSame++;
            }
        }
        if (countSame == password.length) {
            return NO; // 这里说明 count个相同的字符串，也就是所有密码输入一样了
        }
        //判断是否顺增
        int countAdd = 0;
        NSString *newPassword00 = [password substringToIndex:1];
        for (int i = 0; i < password.length; i++) {//是否顺增瞬减
            NSString *newPassword1;
            if (i == 0) {
                newPassword1 = [password substringToIndex:i + 1]; //当 i 为 0 的时候  取下表为 1 的字符串
            }else{
                //当 i 大于 0 时 我们取下标为 i + 1 新的string.length 为 i 个 所有我们再从后面往前面取
                newPassword1 = [[password substringToIndex:i + 1] substringFromIndex:i];
            }
            if (newPassword1.integerValue == newPassword00.integerValue +1) {
                countAdd++;
            }
            newPassword00 = newPassword1;
        }
        
        if (countAdd == password.length-1) {
            return NO; // 这里说明顺增
        }
        //判断是否顺减
        int countjian = 0;
        NSString *newPassword01 = [password substringToIndex:1];
        for (int i = 0; i < password.length; i++) {//是否瞬减
            NSString *newPassword1;
            newPassword1 = [password substringToIndex:i + 1];
            if (i == 0) {
                newPassword1 = [password substringToIndex:i + 1]; //当 i 为 0 的时候  取下表为 1 的字符串
            }else{
                newPassword1 = [[password substringToIndex:i + 1] substringFromIndex:i];
            }
            if (newPassword1.integerValue == newPassword01.integerValue -1) {
                countjian++;
            }
            newPassword01 = newPassword1;
        }
        
        if (countjian == password.length-1) {
            return NO; // 这里说明瞬减
        }
    }
    return isMatch;
}

+(NSString *)addDouhaoInOrginStr:(NSString *)numbers {//每隔三位添加逗号,有小数点也可以
    NSString *numberstr = numbers;
    if ([numbers containsString:@"."]) {
        numbers = [numbers componentsSeparatedByString:@"."].firstObject;
    }
    NSString *str = [numbers substringWithRange:NSMakeRange(numbers.length%3, numbers.length-numbers.length%3)];
    NSString *strs = [numbers substringWithRange:NSMakeRange(0, numbers.length%3)];
    for (int  i =0; i < str.length; i =i+3) {
        NSString *sss = [str substringWithRange:NSMakeRange(i, 3)];
        strs = [strs stringByAppendingString:[NSString stringWithFormat:@",%@",sss]];
    }
    if ([[strs substringWithRange:NSMakeRange(0, 1)] isEqualToString:@","]) {
        strs = [strs substringWithRange:NSMakeRange(1, strs.length-1)];
    }
    
    if ([numberstr containsString:@"."]) {
        strs = [NSString stringWithFormat:@"%@.%@",strs,[numberstr componentsSeparatedByString:@"."].lastObject];
    }
    
    return strs;
}

/**
 
 * 验证纳税人识别码15~20位字母，数字
 
 */

- (BOOL)isTaxpayerNumber {
    return [self matchesRegex:@"^[A-Za-z0-9]{15,20}$" options:0];
}

- (BOOL)isNumberAndDot {
    return [self matchesRegex:@"^[.0-9]{0,10}$" options:0];
}

- (BOOL)isNumber {
    return [self matchesRegex:@"^[0-9]+(\\.[0-9]{1,10})?$" options:0];
}

#pragma mark - add by yier

- (BOOL)isValide{
    return ![self isNilOrNSNullOrEmptyOrWhitespace];
}

- (BOOL)isNilOrNSNull {
    if (!self) {
        return YES;
    }
    if ([self isEqual:[NSNull null]]) {
        return YES;
    }
    return NO;
}

- (BOOL)isEmptyOrWhitespace{
    
    if ([self isNilOrNSNull]) {
        return YES;
    }
    
    if (![self isKindOfClass:[NSString class]]) {
        return YES;
    }
    
    // A nil or NULL string is not the same as an empty string
    return 0 == self.length ||
    ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

- (BOOL)isNilOrNSNullOrEmptyOrWhitespace {
    if ([self isNilOrNSNull]) {
        return YES;
    }
    if ([self isEmptyOrWhitespace]) {
        return YES;
    }
    return NO;
}

NSString * nilToEmptyString(NSString *string) {
    if (string) {
        return string;
    } else {
        return @"";
    }
}

- (BOOL)isNumeric {
    if ([self length] == 0) {
        return NO;
    }
    NSScanner *sc = [NSScanner scannerWithString:self];
    if ([sc scanFloat:NULL]) {
        return [sc isAtEnd];
    }
    return NO;
}

+ (BOOL)isContainsChineseCharacter:(NSString *)content {
    // 匹配包含中文：利用rangeOfString:option:直接查找
    NSString *regEx = @".*[\u4e00-\u9fa5].*";
    NSRange range = [content rangeOfString:regEx options:NSRegularExpressionSearch];
    
    return range.length;
}

#pragma mark -  消息中心时间显示
+ (NSString *)dateTimeChatPageStandardDifference:(NSTimeInterval)timeInterval{
    if (timeInterval == 0) {
        return @"";
    }
    
    NSTimeInterval accurateTimeInterval = timeInterval;
    NSDate *nowDate = [NSDate date];
    NSDate *editTimeDate = [NSDate dateWithTimeIntervalSince1970:accurateTimeInterval];
    NSTimeInterval timeDifference =[nowDate timeIntervalSinceDate:editTimeDate];
    NSInteger day = timeDifference/(3600*24);
    NSInteger hour = timeDifference/(3600);
    
    /////////////今天时间显示规则 上午时：分 ，下午时：分///////////////////////////////////////
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH";
    NSString *currentDay = [[formatter stringFromDate:nowDate] substringToIndex:10];
    //当天零点
    NSString *currentDayOf0Str = [NSString stringWithFormat:@"%@ 00",currentDay];
    NSDate *currentDayOf0Date = [formatter dateFromString:currentDayOf0Str];
    //消息收到时间到今天0点的差值
    NSTimeInterval difIntervalFromDayOf0 = accurateTimeInterval-[currentDayOf0Date timeIntervalSince1970];
    NSLocale *zh_Locale = [[NSLocale alloc] initWithLocaleIdentifier:[self getPreferredLanguage]];
    [formatter setLocale:zh_Locale];
    //从0点开始的24小时以内
    if (difIntervalFromDayOf0 < (24 * 3600 ) && difIntervalFromDayOf0 >= 0) {
        formatter.dateFormat = @"HH:mm";
        NSString *dateStr = [formatter stringFromDate:editTimeDate];
        return dateStr;
    }
    ////////////////昨天时间显示规则 “昨天”////////////////////////////////////////////////////
    if (difIntervalFromDayOf0 < 0 && difIntervalFromDayOf0 >= (-24 * 3600)) {
        formatter.dateFormat = @"HH:mm";
        NSString *dateStr_ = [NSString stringWithFormat:@"昨天 %@",[formatter stringFromDate:editTimeDate]];
        return dateStr_;
    }
//    ////////////////最近七天时间显示规则 “星期X 上午h:mm”///////////////////////////////////////////////
//    if (difIntervalFromDayOf0 < (-24 * 3600) && difIntervalFromDayOf0 >= (-24 * 7 * 3600)) {
//        formatter.dateFormat = @"EEEE hh:mm";
//        return [formatter stringFromDate:editTimeDate];
//    }
    
    ////////////////当年时间显示规则 “MM-dd”，往年 “yyyy-MM-dd”///////////////////////////////
    //超过本年1月1号的,都显示年份-月份;今年内的显示月份-日期
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *currentYear = [[formatter stringFromDate:nowDate] substringToIndex:4];
    NSString *firstDayOfCurrentYearStr = [NSString stringWithFormat:@"%@-01-01",currentYear];
    NSDate *firstDataOfCurrentYear = [formatter dateFromString:firstDayOfCurrentYearStr];
    NSTimeInterval offset =[nowDate timeIntervalSinceDate:firstDataOfCurrentYear];
    NSInteger daysForCurrentYear = offset / (3600 * 24);
    
    if (24 <= hour && day < daysForCurrentYear) {
        NSString *timeDayContent = [self formatDateWithTimeInterval:timeInterval
                                                                 format:@"MM-dd HH:mm"];
        return timeDayContent;
    } else if (day >= daysForCurrentYear) {
        NSString *timeDayContent = [self formatDateWithTimeInterval:timeInterval
                                                                 format:@"yyyy-MM-dd HH:mm"];
        return timeDayContent;
    } else  {
        NSString *timeDayContent = [self formatDateWithTimeInterval:timeInterval
                                                                 format:@"yyyy-MM-dd HH:mm"];
        return timeDayContent;
    }
}

+ (NSString*)getPreferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    return preferredLang;
}

+ (NSString *)formatDateWithTimeInterval:(NSTimeInterval)timeInterval format:(NSString *)format {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //常用格式 @"yyyy-MM-dd HH:mm:ss"
    [dateFormatter setDateFormat:format];
    NSString *result = [dateFormatter stringFromDate:date];
    
    return result;
}

#pragma mark - 替换*号
- (NSString *)replaceStringWithSymbol:(NSString *)symbol beginIndex:(NSInteger)beginIndex length:(NSInteger)length{
    NSString *replaceStr = self;
    if (length <= 0) {
        return replaceStr;
    }

    //如果替换的内容超出总长度
    if (replaceStr.length < beginIndex + length) {
        return replaceStr;
    }
    //如果没有设置替换的占位符
    if (!symbol) {
        symbol = @"*";
    }
    NSString *tempStr = @"";
    for (int i = 0; i < length; i++) {
        tempStr = [tempStr stringByAppendingString:symbol];
    }
    replaceStr = [replaceStr stringByReplacingCharactersInRange:NSMakeRange(beginIndex, length) withString:tempStr];
    
    return replaceStr;
}

@end
