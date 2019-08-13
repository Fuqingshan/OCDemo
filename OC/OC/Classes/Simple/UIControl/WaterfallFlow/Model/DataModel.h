//
//  DataModel.h
//  JLWaterfallFlow
//
//  Created by Jasy on 16/1/25.
//  Copyright © 2016年 Jasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol WaterfallFlowDataUnitModel
@end
@interface WaterfallFlowDataUnitModel : NSObject <YYModel>
@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, assign) CGFloat w;
@property (nonatomic, assign) CGFloat h;
@end

@interface WaterfallFlowDataModel : NSObject <YYModel>
@property (nonatomic, strong) NSArray<WaterfallFlowDataUnitModel> *waterfallFlow1;
@property (nonatomic, strong) NSArray<WaterfallFlowDataUnitModel> *waterfallFlow2;
@property (nonatomic, strong) NSArray<WaterfallFlowDataUnitModel> *waterfallFlow3;

@end
