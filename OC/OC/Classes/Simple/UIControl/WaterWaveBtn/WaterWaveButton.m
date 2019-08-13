//
//  WaterWaveButton.m
//  WaterWaveBtn
//
//  Created by yier on 16/4/21.
//  Copyright © 2016年 newdoone. All rights reserved.
//

#import "WaterWaveButton.h"

@interface WaterWaveButton()

@property (strong, nonatomic) YYAnimatedImageView * imageView;
@property (strong, nonatomic) UITapGestureRecognizer * gesture;
@property (strong, nonatomic) dispatch_source_t timer;
@end

@implementation WaterWaveButton

- (RepeatCountType)repeatType
{
    if(!_repeatType)
    {
        self.repeatType = MaxFloatType;
    }
    
    return _repeatType;
}

- (CGFloat)circleFactor
{
    if(!_circleFactor)
    {
        self.circleFactor = 2.5;
    }
    
    return _circleFactor;
}

- (UIColor *)waterWaveColor
{
    if(!_waterWaveColor)
    {
        self.waterWaveColor = [UIColor redColor];
    }
    
    return _waterWaveColor;
}

- (NSInteger)repeatNum
{
    if(!_repeatNum)
    {
        self.repeatNum = 5;
    }
    
    return _repeatNum;
}

-(instancetype)initWithFrame:(CGRect)frame Image:(YYImage *)image{
    self = [super initWithFrame:frame];
    if(self){
        [self initFrame:frame Image:image];
    }
    
    return self;
}

-(void)initFrame:(CGRect) frame Image:(YYImage *)image{
    
    self.imageView = [[YYAnimatedImageView alloc]initWithImage:image];
    self.imageView.frame = CGRectMake(0, 0, frame.size.width-5, frame.size.height-5);
    self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    self.imageView.layer.borderWidth = 3;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = self.imageView.frame.size.height/2;
    [self addSubview:self.imageView];
    
    self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.layer.cornerRadius = self.frame.size.height/2;
    self.layer.borderWidth = 5;
    self.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:0.9].CGColor;
    
    self.gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:self.gesture];
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    if (!self.timer) {
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    }
    //开始时间，从现在开始1秒之后
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    
    //间隔时间1秒调用一次
    uint64_t interval = 0.5 * NSEC_PER_SEC;
    
    
    dispatch_source_set_timer(self.timer, start, interval, 0);
    
    
    //设置回调次数
    __block NSInteger num = self.repeatNum;
    
    //设置回调
    dispatch_source_set_event_handler(self.timer, ^{
        [self doAnimation];
        switch (self.repeatType) {
            case MaxFloatType:
            {
                
            }
                break;
            case FinitudeType:
            {
                num -- ;
                if (num == 0) {
                    //num秒之后暂停
                    self.gesture.enabled = YES;
                    dispatch_suspend(self.timer);
                    num = self.repeatNum;
                    if (self.endAnimationBlock) {
                        self.endAnimationBlock();
                    }
                }
            }
                break;
            default:
                NSLog(@"none repeatType");
                break;
        }
 
    });
}

- (void)startAnimation{
    self.gesture.enabled = NO;
    //启动timer
    dispatch_resume(self.timer);
}

- (void)stopAnimation
{
    self.gesture.enabled = YES;
    dispatch_suspend(self.timer);
    if (self.endAnimationBlock) {
        self.endAnimationBlock();
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if (self.tapTargetBlock) {
        self.tapTargetBlock();
    }
    
    tap.enabled = NO;
    //启动timer
    dispatch_resume(self.timer);
}

- (void)doAnimation
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIColor *stroke = self.waterWaveColor ? self.waterWaveColor : [UIColor colorWithWhite:0.8 alpha:0.8];
        
        CGRect pathFrame = CGRectMake(-CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds), self.bounds.size.width, self.bounds.size.height);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:self.layer.cornerRadius];
        
        CGPoint shapePosition = [self convertPoint:self.center fromView:nil];
        
        CAShapeLayer *circleShape = [CAShapeLayer layer];
        circleShape.path = path.CGPath;
        circleShape.position = shapePosition;
        circleShape.fillColor = [UIColor clearColor].CGColor;
        circleShape.opacity = 0;
        circleShape.strokeColor = stroke.CGColor;
        circleShape.lineWidth = 3;
        
        [self.layer addSublayer:circleShape];
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(self.circleFactor, self.circleFactor, 1)];
        
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.fromValue = @1;
        alphaAnimation.toValue = @0;
        
        CAAnimationGroup *animation = [CAAnimationGroup animation];
        animation.animations = @[scaleAnimation, alphaAnimation];
        animation.duration = 0.7f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.repeatCount = 1;
        [circleShape addAnimation:animation forKey:nil];
    });
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
