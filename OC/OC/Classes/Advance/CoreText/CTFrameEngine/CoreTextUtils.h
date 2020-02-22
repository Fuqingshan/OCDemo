//
//  CoreTextUtils.h
//  CoreTextDemo
//
//  Created by yier on 2020/1/12.
//  Copyright © 2020 yier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreTextLinkData.h"
#import "CoreTextData.h"

@import UIKit;
NS_ASSUME_NONNULL_BEGIN

@interface CoreTextUtils : NSObject

+ (CoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(CoreTextData *)data;
@end

NS_ASSUME_NONNULL_END
