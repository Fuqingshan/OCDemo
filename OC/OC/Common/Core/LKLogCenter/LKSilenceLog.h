//
//  LKSilenceLog.h
//  App
//
//  Created by yier on 2018/5/3.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LKSilenceType) {
    LKSilenceTypeNone,///正常NSLog
    LKSilenceTypeAll,///全部忽略NSLog
};

@interface LKSilenceLog : NSObject
@property (nonatomic, assign,readonly) LKSilenceType silence;

/**
 白名单，LKSilenceTypeNone模式下，白名单有值只打印白名单中的，否则打印全部
 */
@property (nonatomic, strong,readonly) NSArray<NSString *> *whiteList;

+(instancetype)shareInstance;
@end
