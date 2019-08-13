//
//  FQS_StartView.m
//  testStart
//
//  Created by yier on 15/1/22.
//  Copyright (c) 2015年 huiyict. All rights reserved.
//

#import "FQS_StartView.h"

@interface FQS_StartView ()

@property (nonatomic, strong) UIView *starBackgroundView;
@property (nonatomic, strong) UIView *starForegroundView;

@end

@implementation FQS_StartView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame numberOfStar:5];
}

- (id)initWithFrame:(CGRect)frame numberOfStar:(int)number
{
    self = [super initWithFrame:frame];
    if (self) {
        _numberOfStar = number;
        self.starBackgroundView = [self buidlStarViewWithImageName:@"backgroundStar"];
        self.starForegroundView = [self buidlStarViewWithImageName:@"foregroundStar"];
        self.startChooseType = startPrecise;
        [self addSubview:self.starBackgroundView];
        [self addSubview:self.starForegroundView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithCoder:aDecoder numberOfStar:5];
}

- (id)initWithCoder:(NSCoder *)aDecoder numberOfStar:(int)number
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _numberOfStar = number;
        self.starBackgroundView = [self buidlStarViewWithImageName:@"backgroundStar"];
        self.starForegroundView = [self buidlStarViewWithImageName:@"foregroundStar"];
        self.startChooseType = startPrecise;
        [self addSubview:self.starBackgroundView];
        [self addSubview:self.starForegroundView];
    }
    return self;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if(CGRectContainsPoint(rect,point))
    {
        [self changeStarForegroundViewWithPoint:point startChooseType:self.startChooseType isSetInitScore:NO];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    __weak FQS_StartView * weekSelf = self;
    
    [UIView transitionWithView:self.starForegroundView
                      duration:0.2
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        [weekSelf changeStarForegroundViewWithPoint:point startChooseType:self.startChooseType isSetInitScore:NO];
                    }
                    completion:^(BOOL finished){
                        
                     }];
}

- (UIView *)buidlStarViewWithImageName:(NSString *)imageName
{
    CGRect frame = self.bounds;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.clipsToBounds = YES;
    for (int i = 0; i < self.numberOfStar; i ++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.frame = CGRectMake(i * frame.size.width / self.numberOfStar, 0, frame.size.width / self.numberOfStar, frame.size.height);
        [view addSubview:imageView];
    }
    return view;
}

- (void)changeStarForegroundViewWithPoint:(CGPoint)point startChooseType:(startChooseType)startChooseType  isSetInitScore:(BOOL)isInitScore
{
    CGPoint p = point;
    
    if (p.x < 0)
    {
        p.x = 0;
    }
    else if (p.x > self.frame.size.width)
    {
        p.x = self.frame.size.width;
    }
    
    NSString * str = [NSString stringWithFormat:@"%0.1f",p.x / self.frame.size.width/2*10];
    float score = [str floatValue];
     int a = 0;
    if (startChooseType == startOverall) {
        a = ((int)(score*10))%10==0?score:score+1;
         p.x = a*2/10.0 * self.frame.size.width;
    }
    else
    {
     
        score = [str floatValue];
         p.x = score*2/10 * self.frame.size.width;
    }

    self.starForegroundView.frame = CGRectMake(0, 0, p.x, self.frame.size.height);
    if (isInitScore) {
        
    }
    else
    {
        if (startChooseType == startOverall) {
            self.backScore(a);
        }
        else {
            self.backScore(score);
        }

    }
   
    if(self.delegate && [self.delegate respondsToSelector:@selector(FQS_StartView: score:)]){
        if (startChooseType == startOverall) {
            [self.delegate FQS_StartView:self score:a];
        }
        else {
            [self.delegate FQS_StartView:self score:score];
        }
    }
}

- (void)setInitScore:(float)score{
    [self changeStarForegroundViewWithPoint:CGPointMake(score*2/10.0*self.frame.size.width, self.frame.size.height) startChooseType:self.startChooseType isSetInitScore:YES];
}

@end
