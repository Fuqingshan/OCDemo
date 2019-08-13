//
//  FQS_StartView.h
//  testStart
//
/*
初始化

 self.start.startChooseType = startPrecise;//初始化精准分数(默认精准到小数)
 
 //初始化分数 满分5.0
 [self.start setInitScore:4.4];
 //返回分数
 self.start.backScore = ^(float score)
 {
    NSLog(@"^^^%f",score);
 };
 
 
使用代理
 <FQS_StartViewDelegate>
self.start.delegate = self;
 - (void)FQS_StartView:(FQS_StartView *)view score:(float)score
 {
 NSLog(@"%f",score);
 }
 
*/
//  Created by yier on 15/1/22.
//  Copyright (c) 2015年 huiyict. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FQS_StartView;

@protocol FQS_StartViewDelegate <NSObject>

@optional
-(void)FQS_StartView:(FQS_StartView *)view score:(float)score;

@end
typedef void(^StartBackScore)(float score);
typedef enum {
    startOverall,  //精确到个位
    startPrecise, // 精确到小数点后两位
}startChooseType;

@interface FQS_StartView : UIView

- (void)setInitScore:(float)score;
- (id)initWithFrame:(CGRect)frame numberOfStar:(int)number;
@property (nonatomic, readonly) int numberOfStar;
@property (nonatomic,assign)StartBackScore backScore;//拖动时返回的分数
@property (nonatomic,assign)startChooseType startChooseType;//精确类型
@property (nonatomic, weak) id <FQS_StartViewDelegate> delegate;

@end
