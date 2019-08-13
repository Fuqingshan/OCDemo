//
//  RuntimeBaseModel.h
//  runtime
//
//  Created by yier on 16/6/20.
//  Copyright © 2016年 newdoone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface RuntimeBaseModel : NSObject

- (NSDictionary *)toDictionary;

- (void)saveModel;

+ (id)getModel;

+ (void)clearModel;
@end
