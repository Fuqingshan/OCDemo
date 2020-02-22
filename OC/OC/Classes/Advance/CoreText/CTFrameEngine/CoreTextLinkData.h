//
//  CoreTextLinkData.h
//  CoreTextDemo
//
//  Created by yier on 2020/1/12.
//  Copyright © 2020 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoreTextLinkData : NSObject
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, assign) NSRange range;
@end

NS_ASSUME_NONNULL_END
