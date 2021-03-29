//
//  OCRouter+Practice.m
//  App
//
//  Created by yier on 2019/1/22.
//  Copyright © 2019 yier. All rights reserved.
//

#import "OCRouter+Practice.h"
#import "OCRouter+Common.h"

@implementation OCRouter (Practice)

#pragma mark - 处理Practice相关的router
+ (BOOL)openPracticeURL:(NSURL *)url{
    if (![[url host] isEqualToString:@"practice"]) {
        return NO;
    }
    if ([[url path] isEqualToString:@""]) {
        [self showPracticeViewController];
    }
    //setting
    else if([[url path] isEqualToString:@"/setting"]){
        [self showViewControllerByIdentifier:@"SettingVC" storyboardName:@"Setting"];
    }
    //YYText
    else if([[url path] isEqualToString:@"/yytext"]){
        [self showViewControllerByIdentifier:@"YYTextVC" storyboardName:@"YYText"];
    }
    //ReactiveCocoa
    else if([[url path] isEqualToString:@"/rac"]) {
        [self showViewControllerByIdentifier:@"ReactiveCocoaVC" storyboardName:@"ReactiveCocoa"];
    }
    else{
        return NO;
    }
    
    return YES;
}

#pragma mark -  展示Practice
+ (void)showPracticeViewController{
    [OCRouter shareInstance].rootViewController.tabbarVC.itemType = TabBarItemTypePractice;
}



@end
