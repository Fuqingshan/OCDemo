//
//  LanguageManager.m
//  OC
//
//  Created by yier on 2019/2/14.
//  Copyright © 2019 yier. All rights reserved.
//

#import "LanguageManager.h"

NSString *const ChangeLanguageNotification = @"kChangeLanguageNotification";
NSString *const UserLanguage = @"kUserLanguage";

@implementation LanguageManager

+ (instancetype)shareInstance{
    
    static  LanguageManager * _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
        [_manager systemLanguageType];
    }) ;
    
    return _manager;
}

- (void)systemLanguageType{
    self.type = LanguageTypeCH;
    //默认中文，如果本地存储了用户选择的语言，则取本地app存储的，如果没有，则取系统的第一语言
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:UserLanguage];
    if (language.length == 0) {
        NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        language = stringInArrayAtIndex(appLanguages, 0);
    }
   
    if ([language containsString:@"zh-Hans"]) {
        self.type = LanguageTypeCH;
    }else{
        self.type = LanguageTypeEN;
    }
    
    if (self.type == LanguageTypeCH) {
        [self changeBundle:@"zh-Hans"];
    } else {
        [self changeBundle:@"en"];
    }
}

//设置语言
- (void)setUserlanguage:(LanguageType)type {
    switch (type) {
        case LanguageTypeCH:
        {
            [self saveLanguage:@"zh-Hans"];
            [self changeBundle:@"zh-Hans"];
            self.type = LanguageTypeCH;
        }
            break;
        case LanguageTypeEN:
        {
            [self saveLanguage:@"en"];
            [self changeBundle:@"en"];
            self.type = LanguageTypeEN;
        }
            break;
    }
    
    //改变完成之后发送通知，告诉其他页面修改完成，提示刷新界面
    [[NSNotificationCenter defaultCenter] postNotificationName:ChangeLanguageNotification object:nil];
}

#pragma mark - 保存语言
- (void)saveLanguage:(NSString *)language {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:language forKey:UserLanguage];
    [defaults synchronize];
}

//改变bundle
- (void)changeBundle:(NSString *)language {
    //1.第一步改变bundle的值
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj" ];
    self.bundle = [NSBundle bundleWithPath:path];
}

@end
