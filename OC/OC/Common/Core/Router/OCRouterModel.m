//
//  OCRouterModel.m
//  App
//
//  Created by yier on 2019/1/17.
//  Copyright © 2019 yier. All rights reserved.
//

#import "OCRouterModel.h"

@implementation OCRouterModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"className":@"class"
             };
}

@end

@implementation OCRouterCommonModel

+ (NSArray<NSString *> *)modelPropertyBlacklist{
    return @[
             @"all"
             ];
}

- (NSArray *)all{
    if(!_all){
        NSMutableArray *models = [[NSMutableArray alloc] init];
        for (OCRouterModel *model in self.Common) {
            [models addObject:model];
        }
        _all = [models copy];
    }
    return _all;
}

@end

@implementation OCRouterMineModel

+ (NSArray<NSString *> *)modelPropertyBlacklist{
    return @[
             @"all"
             ];
}

- (NSArray *)all{
    if(!_all){
        NSMutableArray *models = [[NSMutableArray alloc] init];
        for (OCRouterModel *model in self.Mine) {
            [models addObject:model];
        }
        _all = [models copy];
    }
    return _all;
}

@end

@implementation OCRouterPracticeModel

+ (NSArray<NSString *> *)modelPropertyBlacklist{
    return @[
             @"all"
             ];
}

- (NSArray *)all{
    if(!_all){
        NSMutableArray *models = [[NSMutableArray alloc] init];
        for (OCRouterModel *model in self.Practice) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.Setting) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.YYText) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.ReactiveCocoa) {
            [models addObject:model];
        }
        _all = [models copy];
    }
    return _all;
}

@end

@implementation OCRouterAdvanceModel

+ (NSArray<NSString *> *)modelPropertyBlacklist{
    return @[
             @"all"
             ];
}

- (NSArray *)all{
    if(!_all){
        NSMutableArray *models = [[NSMutableArray alloc] init];
        for (OCRouterModel *model in self.Advance) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.Runtime) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.Runloop) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.DesignMode) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.Audio) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.Video) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.CoreText) {
            [models addObject:model];
        }
        
        _all = [models copy];
    }
    return _all;
}

@end

@implementation OCRouterSimpleModel

+ (NSArray<NSString *> *)modelPropertyBlacklist{
    return @[
             @"all"
             ];
}

- (NSArray *)all{
    if(!_all){
        NSMutableArray *models = [[NSMutableArray alloc] init];
        for (OCRouterModel *model in self.Simple) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.QRCode) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.Advantage) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.Preprocessor) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.Foundation) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.Introduction) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.Memory) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.Multithread) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.Debug) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.Security) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.UIControl) {
            [models addObject:model];
        }
        for (OCRouterModel *model in self.Animation) {
            [models addObject:model];
        }
        
        _all = [models copy];
    }
    return _all;
}

@end

@implementation OCRouterPlistModel

@end
