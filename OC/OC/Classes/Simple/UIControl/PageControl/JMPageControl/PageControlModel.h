//
//  PageControlModel.h
//  JMPageControl
//
//  Created by yier on 2018/2/22.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,PageControlUIType){
    PageControlUITypeCircle,///圆形
    PageControlUITypeOval,///椭圆
};

@interface PageControlModel : NSObject
@property (nonatomic, assign) PageControlUIType type;

@end
