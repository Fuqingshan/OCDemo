//
//  LanguageManager.h
//  OC
//
//  Created by yier on 2019/2/14.
//  Copyright © 2019 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ChangeLanguageNotification;

#define LocalizedString(key) NSLocalizedStringFromTableInBundle(key, @"Localizable", [LanguageManager shareInstance].bundle, nil)

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,LanguageType) {
    LanguageTypeCH,///<中文
    LanguageTypeEN,///<英文
};

@interface LanguageManager : NSObject
@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, assign) LanguageType type;

+ (instancetype)shareInstance;

- (void)setUserlanguage:(LanguageType)type;

@end

NS_ASSUME_NONNULL_END
