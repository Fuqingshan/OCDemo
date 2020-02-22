//
//  CoreTextImageData.h
//  CoreTextDemo
//
//  Created by yier on 2020/1/10.
//  Copyright © 2020 yier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoreTextImageData : NSObject
@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) CGFloat position;
@property(nonatomic, assign) CGRect imagePosition;

@end

NS_ASSUME_NONNULL_END
