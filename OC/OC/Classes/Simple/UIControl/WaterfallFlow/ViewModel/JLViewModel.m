//
//  JLViewModel.m
//  JLWaterfallFlow
//
//  Created by Jasy on 16/1/25.
//  Copyright © 2016年 Jasy. All rights reserved.
//

#import "JLViewModel.h"
#import "DataModel.h"
@implementation JLViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataArray = [NSArray array];
        self.nameArray = [NSArray array];
    }
    return self;
}

-(void)getData
{
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"waterfallFlow1" ofType:@"plist"];
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"waterfallFlow2" ofType:@"plist"];
    NSString *path3 = [[NSBundle mainBundle] pathForResource:@"waterfallFlow3" ofType:@"plist"];
    NSArray *plistArr1 = [NSArray arrayWithContentsOfFile:path1];
    NSArray *plistArr2 = [NSArray arrayWithContentsOfFile:path2];
    NSArray *plistArr3 = [NSArray arrayWithContentsOfFile:path3];
    if (!plistArr1 || !plistArr2 || !plistArr3) {
        return;
    }
    NSDictionary *dataDic = @{
                              @"waterfallFlow1":plistArr1
                              ,@"waterfallFlow2":plistArr2
                              ,@"waterfallFlow3":plistArr3
                              };
    
    WaterfallFlowDataModel *model = [WaterfallFlowDataModel yy_modelWithDictionary:dataDic];
    if (model.waterfallFlow1.count == 0 || model.waterfallFlow2.count == 0 || model.waterfallFlow3.count == 0) {
        return;
    }
    self.dataArray = @[model.waterfallFlow1, model.waterfallFlow2, model.waterfallFlow3];
    self.nameArray = @[@"1.plist", @"2.plist", @"3.plist"];
}

@end
