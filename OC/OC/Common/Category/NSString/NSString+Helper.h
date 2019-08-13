//
//  NSString+Helper.h
//  App
//
//  Created by chenfei on 10/11/2016.
//  Copyright © 2016 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)

+ (BOOL)isNilOrEmpty:(NSString *)string;
+ (BOOL)isPasswordTooSimple:(NSString *)password;

///电话号码格式化为数字，去除多余字符串
- (NSString *)formatTelNumber;
- (BOOL)isCaptcha;
- (BOOL)isPhoneNumber;
- (BOOL)isIDCardNumber;
- (BOOL)isEmailNumber;
- (BOOL)isBankCardNumber;
- (BOOL)isCreditCardNumber;
- (BOOL)isBankCardNumber16219;
- (BOOL)isPassword;
- (BOOL)isAllNumber;
- (BOOL)isChineseCharacterName;
- (BOOL)isChineseAndAtoZ;
- (BOOL)isContainsEmoji;
- (BOOL)isTaxpayerNumber;
- (BOOL)isNumberAndDot;//只包含数字和点号(输入过程中判断只让输入数字和点号)
- (BOOL)isChineseNumberLetterAndDot;///<只包含数字、字母、中文、和点（·）（新疆人名字中有）
- (BOOL)isNumber;//数字含小数(最后提交时校验格式)

+ (NSString *)changeToEncrypStr:(NSString *)originStr fromIndex:(NSInteger)index length:(NSInteger)length;
+ (NSString *)addDouhaoInOrginStr:(NSString *)str;//每隔三位添加逗号,有小数点也可以

- (NSString *)charAtIndex:(NSUInteger)index;
- (NSString *)trimLeft;
- (NSString *)trimRight;
- (NSString *)trim;

- (NSString *)formatAsPhoneNumber;
- (NSString *)formatAsBankCardNumber;

- (NSUInteger)indexOfString:(NSString *)str;

- (NSAttributedString *)currencyStringWithBigFont:(UIFont *)bigFont
                                        smallFont:(UIFont *)smallFont
                                            color:(UIColor *)color;

- (NSString *)currencyString;

- (NSString *)dateStringByTimestampString;
- (NSString *)dateStringByYMDHMS;         //去掉时、分、秒的日期
//带￥符号的金额
- (NSMutableAttributedString *)currencySignStringWithBigFont:(UIFont *)bigFont
                                                   smallFont:(UIFont *)smallFont
                                                       color:(UIColor *)color;

- (NSString *)dateStringWithOldFormat:(NSString *)oldFormat newFormat:(NSString *)newFormat;

//截取身份证的出生日期并转换为日期格式
- (NSString *)getIDCardToBirthdayDate;

/**
判断传参的字符串是否不包含nil或者NULL或者换行,需注意使用的类型是否为NSString，里面的类型判断是无效的
条件成立返回YES,不成立返回NO
 @return YES/NO
 */
- (BOOL)isValide;

/**
 nil转成@"", 其他String不会变化

 @param string 任意NSString的对象
 @return nil转成@"", 其他不变的NSString对象
 */
NSString * nilToEmptyString(NSString *string);

/**
 判断是否是数字
@return 是否为数字
 */
- (BOOL)isNumeric;

//是否包含中文
+ (BOOL)isContainsChineseCharacter:(NSString *)content;

/**
 消息中心时间显示
 */
+ (NSString *)dateTimeChatPageStandardDifference:(NSTimeInterval)timeInterval;


/**
 替换字符串指定位置为占位符

 @param symbol 占位符，默认为*
 @param beginIndex 起始位
 @param length 长度
 */
- (NSString *)replaceStringWithSymbol:(NSString *)symbol beginIndex:(NSInteger)beginIndex length:(NSInteger)length;
@end
