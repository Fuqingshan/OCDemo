//
//  WaterWaveButton.h
//  WaterWaveBtn
//
//  Created by yier on 16/4/21.
//  Copyright © 2016年 newdoone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TapTarget)(void);
typedef void(^WaterWaveButtonEndAnimation)(void);


/**
 *  光圈重复次数
 *  设置为无限次，需要调用stopAnimation()手动停止
 *  设置为有限次，需要设置重复次数，默认为5次
 */
typedef NS_ENUM(NSInteger,RepeatCountType) {
    MaxFloatType,//无限次
    FinitudeType,//有限次
};

@interface WaterWaveButton : UIView

//重复类型
@property (assign, nonatomic) RepeatCountType  repeatType;

//光圈大小系数,默认2.5,(1.0 ~ 5.0, 可超过5.0)
@property (assign, nonatomic) CGFloat circleFactor;

//设置为有限次时的重复次数
@property (assign, nonatomic) NSInteger repeatNum;

//光圈颜色
@property (strong, nonatomic) UIColor * waterWaveColor;

//动画结束时调用
@property (copy, nonatomic) WaterWaveButtonEndAnimation endAnimationBlock;

//点击按钮时调用
@property (copy, nonatomic) TapTarget tapTargetBlock;

-(instancetype)initWithFrame:(CGRect)frame Image:(YYImage *)image;

- (void)startAnimation;
//无限次数手动结束动画
- (void)stopAnimation;
@end
