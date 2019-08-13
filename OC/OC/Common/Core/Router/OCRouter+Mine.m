//
//  OCRouter+Mine.m
//  OC
//
//  Created by yier on 2019/3/19.
//  Copyright © 2019 yier. All rights reserved.
//

#import "OCRouter+Mine.h"
#import "OCRouter+Common.h"

@implementation OCRouter (Mine)

#pragma mark - 处理Mine相关的router
+ (BOOL)openMineURL:(NSURL *)url{
    if (![[url host] isEqualToString:@"mine"]) {
        return NO;
    }
    if ([[url path] isEqualToString:@""]) {
        [self showMineViewController];
    }
    //font
    else if([[url path] isEqualToString:@"/font"]){
        [self showViewControllerByIdentifier:@"SystemFontVC" storyboardName:@"SystemFont"];
    }
    //constraintpriority
    else if([[url path] isEqualToString:@"/constraintpriority"]){
        [self showViewControllerByIdentifier:@"ConstraintPriorityVC" storyboardName:@"ConstraintPriority"];
    }
    //hittest
    else if([[url path] isEqualToString:@"/hittest"]){
        [self showViewControllerByIdentifier:@"HitTestVC" storyboardName:@"HitTest"];
    }
    else{
        return NO;
    }
    
    return YES;
}

#pragma mark -  展示Mine
+ (void)showMineViewController{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[OCRouter shareInstance].rootViewController showMine];
    });
}

@end
