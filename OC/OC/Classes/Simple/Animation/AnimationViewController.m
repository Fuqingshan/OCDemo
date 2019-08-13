//
//  AnimationViewController.m
//  OC
//
//  Created by yier on 2019/3/31.
//  Copyright © 2019 yier. All rights reserved.
//

#import "AnimationViewController.h"
#import <objc/message.h>

#import "UIView+Genie.h"
#import "UIView+Fold.h"
#import "PPBannerView.h"
#import "LKSubmitButton.h"

@interface AnimationViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

/****正方体
定义主Layer，这个CALayer用来存放其他子Layer，我们一共需要6个子Layer，每一个子Layer代表正方体的一个面。
 */
@property (nonatomic, strong) CALayer *rootLayer;

//点击之后抖动的按钮
@property (nonatomic, strong) UIButton *shakeBtn;

//用来动画的图片
@property (nonatomic, strong) UIImageView *animationImg;
@property (nonatomic, strong) UIImageView *suckImg;
@property (nonatomic, strong) UIImageView *flodImg;

@property (nonatomic, strong) PPBannerView *banner;

@property (nonatomic, strong) UIImageView *emitterImg;

@property (nonatomic, strong) UIImageView *gaussiBlurImg;
@property (nonatomic, strong) LKSubmitButton *submitBtn;

@property (nonatomic, strong) UIImageView *cutImg;

@end

@implementation AnimationViewController

- (void)dealloc{
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

#pragma mark - setupUI
- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"动画");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

#pragma mark - initData
- (void)initData{
    [self getDataSource];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"动画");
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":@"旋转正方体"
                            ,@"sel":@"transformSexAngleSelector"
                            }
                        ,@{
                            @"content":@"旋转正方体增加闪烁"
                            ,@"sel":@"blinkAnimationSelector"
                            }
                        ,@{
                            @"content":@"点击之后抖动的按钮"
                            ,@"sel":@"shakeButtonSelector"
                            }
                        ,@{
                            @"content":@"移动到左下角的图片"
                            ,@"sel":@"moveLeftSelector"
                            }
                        ,@{
                            @"content":@"向右旋转的图片"
                            ,@"sel":@"rotateRightSelector"
                            }
                        ,@{
                            @"content":@"旋转360°的图片"
                            ,@"sel":@"rotate360Selector"
                            }
                        ,@{
                            @"content":@"吮吸动画"
                            ,@"sel":@"suckSelector"
                            }
                        ,@{
                            @"content":@"贝塞尔曲线---直线"
                            ,@"sel":@"bezierPathOfLineSelector"
                            }
                        ,@{
                            @"content":@"贝塞尔曲线---笑脸"
                            ,@"sel":@"bezierPathOfCircleWSelector"
                            }
                        ,@{
                            @"content":@"折叠"
                            ,@"sel":@"flodAnimationSelector"
                            }
                        ,@{
                            @"content":@"3Dbanner"
                            ,@"sel":@"threeDBannerSelector"
                            }
                        ,@{
                            @"content":@"粒子效果"
                            ,@"sel":@"emitterAnimationSelector"
                            }
                        ,@{
                            @"content":@"神奇移动"
                            ,@"sel":@"trasition1Selector"
                            }
                        ,@{
                            @"content":@"弹性pop"
                            ,@"sel":@"trasition2Selector"
                            }
                        ,@{
                            @"content":@"翻页效果"
                            ,@"sel":@"trasition3Selector"
                            }
                        ,@{
                            @"content":@"小圆点扩散"
                            ,@"sel":@"trasition4Selector"
                            }
                        ,@{
                            @"content":@"像素效果"
                            ,@"sel":@"trasition5Selector"
                            }
                        ,@{
                            @"content":@"高斯模糊"
                            ,@"sel":@"gaussiBlurSelector"
                            }
                        ,@{
                            @"content":@"高斯模糊提交按钮"
                            ,@"sel":@"yooliSubmitBtnSelector"
                            }
                        ,@{
                            @"content":@"截取图片"
                            ,@"sel":@"cutSelector"
                            }
                        ,@{
                            @"content":@"手绘画圈"
                            ,@"url":@"sumup://simple/animation/drawcircle"
                            }
                        ,@{
                            @"content":@"物理引擎"
                            ,@"url":@"sumup://simple/animation/dynamicanimator"
                            }
                        ];
    [self.tableView reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary *dic = dictionaryInArrayAtIndex(self.dataSource, indexPath.row);
    NSString *content = stringInDictionaryForKey(dic, @"content");
    cell.textLabel.text = [NSString stringWithFormat:@"%@",content];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = dictionaryInArrayAtIndex(self.dataSource, indexPath.row);
    NSString *selStr = stringInDictionaryForKey(dic, @"sel");
    NSString *url = stringInDictionaryForKey(dic, @"url");
    if ([url isValide]) {
        [OCRouter openURL:[NSURL URLWithString:url]];
        return;
    }
    SEL sel = NSSelectorFromString(selStr);
    @try {
        ((void(*)(id,SEL))objc_msgSend)(self,sel);
        //有返回值
        //    ((NSString *(*)(id,SEL))objc_msgSend)(self,sel);
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.reason);
    } @finally {
        
    }
}

#pragma mark - 旋转正方体
- (void)transformSexAngleSelector{
    // 开始利用这个辅助函数来创建每一个面，注意最后要将主Layer进行一次3D变换，这样才能看出3D效果。
    if (self.rootLayer) {
        [self.rootLayer removeAllAnimations];
        [self.rootLayer removeAllSublayers];
        [self.rootLayer removeFromSuperlayer];
        self.rootLayer = nil;
    }else{
        self.rootLayer = [CALayer layer];
        self.rootLayer.contentsScale = [UIScreen mainScreen].scale;
        self.rootLayer.frame = self.view.bounds;
        
        //主Layer的3D变换
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0 / 700;
        //在X轴上做一个20度的小旋转
        transform = CATransform3DRotate(transform, M_PI / 9, 1, 0, 0);
        //设置CALayer的sublayerTransform
        self.rootLayer.sublayerTransform = transform;
        //添加Layer
        [self.view.layer addSublayer:self.rootLayer];
        
        //依次：前、后、左、右、上、下
        [self addLayer:@[@0, @0, @30, @0, @0, @0, @0]];
        [self addLayer:@[@0, @0, @(-30), @(M_PI), @0, @0, @0]];
        [self addLayer:@[@(-30), @0, @0, @(-M_PI_2), @0, @1, @0]];
        [self addLayer:@[@30, @0, @0, @(M_PI_2), @0, @1, @0]];
        [self addLayer:@[@0, @(-30), @0, @(-M_PI_2), @1, @0, @0]];
        [self addLayer:@[@0, @30, @0, @(M_PI_2), @1, @0, @0]];
        
        [self beginSexAngleGroupAnimation];
    }
}

- (void)beginSexAngleGroupAnimation{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.rotation.y"];
    //从0到360度
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    //间隔3秒
    animation.duration = 3.0;
    //无限循环
    animation.repeatCount = HUGE_VALF;
    
    CGMutablePathRef
    path = CGPathCreateMutable();
    //将路径的起点定位到
    CGPathMoveToPoint(path,NULL,50.0,120.0);
    //下面5行添加5条直线的路径到path中
    CGPathAddLineToPoint(path,
                         NULL, 60, 130);
    CGPathAddLineToPoint(path,
                         NULL, 70, 140);
    CGPathAddLineToPoint(path,
                         NULL, 80, 150);
    CGPathAddLineToPoint(path,
                         NULL, 90, 160);
    CGPathAddLineToPoint(path,
                         NULL, 100, 170);
    //下面四行添加四条曲线路径到path
    CGPathAddCurveToPoint(path,NULL,50.0,275.0,150.0,275.0,70.0,120.0);
    CGPathAddCurveToPoint(path,NULL,150.0,275.0,250.0,275.0,90.0,120.0);
    CGPathAddCurveToPoint(path,NULL,250.0,275.0,350.0,275.0,110.0,120.0);
    CGPathAddCurveToPoint(path,NULL,350.0,275.0,450.0,275.0,130.0,120.0);
    //以“position”为关键字
    CAKeyframeAnimation *animation2 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //设置path属性
    [animation2 setPath:path];
    [animation2 setDuration:3.0];
    //自动回到起点
    [animation2 setAutoreverses:YES];
    CFRelease(path);
    
    CAAnimationGroup *group=[CAAnimationGroup animation];
    group.animations =[NSArray arrayWithObjects:animation2, animation,nil];
    group.duration = 3;
    group.removedOnCompletion = NO;//动画完成时是否移除
    group.fillMode = kCAFillModeBackwards;
    group.autoreverses = YES;
    group.repeatCount = 100;
    
    [self.rootLayer addAnimation:group forKey:nil];
}

/*
 这里为了使Layer有渐变色，所以使用CAGradientLayer类型，因此第一步就是设置好CAGradientLayer的那些杂七杂八的属性（颜色，位置等），第二步，从参数中获取偏移和旋转3D变换的值，然后执行相应的变换。具体参数我们会在之后调用这个方法时传入，这里总共需要用来偏移的X，Y，Z参数和用来旋转的角度，X，Y，Z参数，一共7个参数。设置好3D Transform后，这个方法的第三步就是把这个新的Layer加入到主Layer中。
 */
- (void)addLayer:(NSArray*)params
{
    
    //CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    //创建支持渐变背景的CAGradientLayer
    CAGradientLayer  *gradient = [CAGradientLayer layer];
    
    //设置位置，和颜色等参数
    gradient.contentsScale = [[UIScreen mainScreen] scale];
    gradient.bounds = CGRectMake(0, 0,60, 60);
    //设置面的中心点
    gradient.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    //每面的颜色组成
    gradient.colors = @[(id)[UIColor orangeColor].CGColor, (id)[UIColor redColor].CGColor];
    //光的投影
    gradient.locations =@[@0,@1];
    gradient.startPoint = CGPointMake(1, 0);
    gradient.endPoint = CGPointMake(0, 1);
    //根据参数对CALayer进行偏移和旋转Transform
    CATransform3D transform = CATransform3DMakeTranslation([[params objectAtIndex:0] floatValue], [[params objectAtIndex:1] floatValue], [[params objectAtIndex:2] floatValue]);
    transform = CATransform3DRotate(transform, [[params objectAtIndex:3] floatValue], [[params objectAtIndex:4] floatValue], [[params objectAtIndex:5] floatValue], [[params objectAtIndex:6] floatValue]);
    //设置transform属性并把Layer加入到主Layer中
    gradient.transform = transform;
    [self.rootLayer addSublayer:gradient];
}

#pragma mark - 正方体增加闪烁
- (void)blinkAnimationSelector{
    if (self.rootLayer) {
        [self.rootLayer addAnimation:[self blink] forKey:nil];
    }else{
        [self transformSexAngleSelector];
        [self.rootLayer addAnimation:[self blink] forKey:nil];
    }
}

- (CABasicAnimation *)blink
{
    //加载闪烁
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    basicAnimation.fromValue = [NSNumber numberWithFloat:1];
    basicAnimation.toValue = [NSNumber numberWithFloat:0];
    basicAnimation.autoreverses = YES;
    basicAnimation.duration = 1;
    basicAnimation.repeatCount = FLT_MAX;
    basicAnimation.removedOnCompletion = NO;
    basicAnimation.fillMode = kCAFillModeForwards;
    
    return basicAnimation;
}

#pragma mark - 点击之后会震动的按钮
- (void)shakeButtonSelector{
    if (self.shakeBtn) {
        [self.shakeBtn.layer removeAllAnimations];
        [self.shakeBtn removeFromSuperview];
        self.shakeBtn = nil;
    }else{
        self.shakeBtn = [[UIButton alloc] initWithFrame:CGRectMake(200, 200, 100, 30)];
        [self.shakeBtn setBackgroundColor:[UIColor orangeColor]];
        [self.view addSubview:self.shakeBtn];
        @weakify(self);
        [[self.shakeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self shakeBtnAnimation];
        }];
    }
}

- (void)shakeBtnAnimation{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    NSMutableArray *values = @[].mutableCopy;
    for (NSInteger i = 0;i<10; i++) {
        if (i % 2 == 0) {
            [values addObject:[NSValue valueWithCGPoint:CGPointMake(self.shakeBtn.center.x, self.shakeBtn.center.y)]];
        }else{
            [values addObject:[NSValue valueWithCGPoint:CGPointMake(self.shakeBtn.center.x, self.shakeBtn.center.y+10)]];
        }
    }
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.duration = 0.2;
    self.shakeBtn.layer.position = CGPointMake(self.shakeBtn.center.x, self.shakeBtn.center.y);
    [self.shakeBtn.layer addAnimation:animation forKey:nil];
}

#pragma mark - 移动到左下角的图片
- (void)moveLeftSelector{
    if (self.animationImg) {
        [self removeAnimatinImg];
    }else{
        [self createAnimationImg];
        CGPoint fromPoint = self.animationImg.center;
        UIBezierPath *movePath = [UIBezierPath bezierPath];
        [movePath moveToPoint:fromPoint];
        
        CGPoint toPoint = CGPointMake(0, kMainScreenHeight);
        [movePath addQuadCurveToPoint:toPoint controlPoint:CGPointMake(toPoint.x, toPoint.y)];
        
        CAKeyframeAnimation *moveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        moveAnimation.path = movePath.CGPath;
        moveAnimation.duration = 1;
        
        CABasicAnimation *animSmaller = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
            animSmaller.fromValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
            animSmaller.toValue = [NSValue valueWithCGSize:CGSizeMake(0.1, 0.1)];
//        animSmaller.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//        animSmaller.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1)];
        
        animSmaller.duration =1;
        animSmaller.removedOnCompletion = NO;
        //透明度变化
        CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"alpha"];
        opacityAnim.fromValue = [NSNumber numberWithFloat:1.0];
        opacityAnim.toValue = [NSNumber numberWithFloat:0.1];
        opacityAnim.removedOnCompletion = NO;
        
        //关键帧，旋转，透明度组合起来执行
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = [NSArray arrayWithObjects:moveAnimation, animSmaller,opacityAnim, nil];
        animGroup.duration = 1;
        animGroup.autoreverses = YES;
        animGroup.repeatCount = MAXFLOAT;
        [self.animationImg.layer addAnimation:animGroup forKey:nil];
    }
}

#pragma mark - 向右旋转的图片
- (void)rotateRightSelector{
    if (self.animationImg) {
        [self removeAnimatinImg];
    }else{
        [self createAnimationImg];
        
        CGPoint fromPoint = self.animationImg.center;
        UIBezierPath *movePath = [UIBezierPath bezierPath];
        [movePath moveToPoint:fromPoint];
        CGPoint toPoint = CGPointMake(fromPoint.x - 100 , fromPoint.y) ;
        
        [movePath addLineToPoint:toPoint];
        
        CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        moveAnim.path = movePath.CGPath;
        moveAnim.removedOnCompletion = YES;
        moveAnim.autoreverses = YES;
        CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        
        //沿Z轴旋转
        scaleAnim.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI,0,0,1)];
        
        //沿Y轴旋转
        // scaleAnim.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI,0,1.0,0)];
        
        //沿X轴旋转
        // scaleAnim.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI,1.0,0,0)];
        scaleAnim.cumulative = YES;
        scaleAnim.duration =1;
        //旋转2遍，360度
        scaleAnim.repeatCount =2;
        self.animationImg.center = toPoint;
        scaleAnim.removedOnCompletion = YES;
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = [NSArray arrayWithObjects:moveAnim, scaleAnim, nil];
        animGroup.duration = 2;
        // animGroup.autoreverses = YES;
        animGroup.removedOnCompletion = YES;
        [self.animationImg.layer addAnimation:animGroup forKey:nil];
        self.animationImg.center = fromPoint;
    }
}

#pragma mark - 旋转360°的图片
- (void)rotate360Selector{
    if (self.animationImg) {
        [self removeAnimatinImg];
    }else{
        [self createAnimationImg];
        CABasicAnimation *animation = [ CABasicAnimation
                                       animationWithKeyPath: @"transform" ];
        animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        
        //围绕Z轴旋转，垂直与屏幕
        animation.toValue = [ NSValue valueWithCATransform3D:
                             
                             CATransform3DMakeRotation(M_PI, 0, 0, 1.0) ];
        animation.duration = 1;
        //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
        animation.cumulative = YES;
        animation.repeatCount = 2;
        
        //在图片边缘添加一个像素的透明区域，去图片锯齿
        CGRect imageRrect = CGRectMake(0, 0,self.animationImg.frame.size.width, self.animationImg.frame.size.height);
        UIGraphicsBeginImageContext(imageRrect.size);
        [self.animationImg.image drawInRect:CGRectMake(1,1,self.animationImg.frame.size.width-2,self.animationImg.frame.size.height-2)];
        self.animationImg.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.animationImg.layer addAnimation:animation forKey:nil];
    }
}

- (void)createAnimationImg{
    if (!self.animationImg) {
        self.animationImg = [[UIImageView alloc] initWithFrame:CGRectMake(kMainScreenWidth - 200, 100, 200, 300)];
        self.animationImg.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"L41" ofType:@"png"]]];
        [self.view addSubview:self.animationImg];
    }
}

- (void)removeAnimatinImg{
    if (self.animationImg) {
        [self.animationImg.layer removeAllAnimations];
        [self.animationImg removeFromSuperview];
        self.animationImg = nil;
    }
}

#pragma mark - 吮吸动画
- (void)suckSelector{
    if (self.suckImg) {
        [self.suckImg.layer removeAllAnimations];
        [self.suckImg removeFromSuperview];
        self.suckImg = nil;
    }else{
        self.suckImg = [[UIImageView alloc] initWithFrame:CGRectMake(kMainScreenWidth - 200, 100, 200, 300)];
        self.suckImg.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"L41" ofType:@"png"]]];
        [self.view addSubview:self.suckImg];
        
        self.view.userInteractionEnabled = NO;
        CGRect startRect = CGRectMake(20, 300, 20, 20);
        @weakify(self);
        [self.suckImg genieOutTransitionWithDuration:0.5f
                                    startRect:startRect
                                    startEdge:BCRectEdgeRight
                                   completion:^{
                                       @strongify(self);
                                       [self genieInTransition];
                                   }];
    }
}

- (void)genieInTransition {
    //设置结束时视图的位置及大小，startEdge代表移动方向。
    CGRect endRect = CGRectMake(100, kMainScreenHeight - 100, 100, 30);
    //动画开始会从起始点开始。注意动画过程中视图的中心点始终不变
    @weakify(self);
    [self.suckImg genieInTransitionWithDuration:0.5f
                         destinationRect:endRect
                         destinationEdge:BCRectEdgeTop
                              completion:^{
                                  @strongify(self);
                                  self.view.userInteractionEnabled = YES;
                                  [self springAnimation];
                              }];
}

#pragma mark - 弹簧动画
- (void)springAnimation{
    CASpringAnimation *spring = [CASpringAnimation animationWithKeyPath:@"position.x"];
    spring.damping = 1;
    spring.stiffness = 100;
    spring.mass = 1;
    spring.initialVelocity = -30;
    spring.fromValue = [NSNumber numberWithFloat:self.suckImg.layer.position.x];
    spring.toValue = [NSNumber numberWithFloat:self.suckImg.layer.position.x + 50];
    spring.duration = 1;
    [self.suckImg.layer addAnimation:spring forKey:@""];
}

#pragma mark - 贝塞尔曲线 ------ 直线
- (void)bezierPathOfLineSelector{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 3.0f;
//    animation.delegate = self;
    animation.fromValue = @0;
    animation.toValue = @1;
    
    //线
    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(160, 180)];
    [bezierPath addLineToPoint:CGPointMake(200.0, 280.0)];
    [bezierPath addLineToPoint:CGPointMake(160, 80)];
    [bezierPath addLineToPoint:CGPointMake(120.0, 280)];
    [bezierPath addLineToPoint:CGPointMake(160, 180)];
    [bezierPath addLineToPoint:CGPointMake(200, 80)];
    [bezierPath addLineToPoint:CGPointMake(160.0, 280.0)];
    [bezierPath addLineToPoint:CGPointMake(120, 80)];
    [bezierPath closePath];
    [bezierPath stroke];
    
    CAShapeLayer *lineLayer = [CAShapeLayer new];
    lineLayer.lineWidth = 5;
    lineLayer.frame = self.view.frame;
    lineLayer.path = bezierPath.CGPath;
    lineLayer.strokeColor = [UIColor greenColor].CGColor;
    lineLayer.fillColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:lineLayer];
    [lineLayer addAnimation:animation forKey:@"strokeEnd"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [lineLayer removeAllAnimations];
        [lineLayer removeAllSublayers];
        [lineLayer removeFromSuperlayer];
    });
}

#pragma mark - 贝塞尔曲线——圆形
- (void)bezierPathOfCircleWSelector{
    CAAnimationGroup * group = [CAAnimationGroup animation];
    group.duration = 3.0f;
    
    NSMutableArray * animationArrays = [NSMutableArray arrayWithCapacity:0];
    NSArray * pointArray  = @[@"150",@"300",@"120",@"300",@"180",@"300",@"120",@"290",@"180",@"290",@"150",@"310"];
    for (int i = 0; i<6; i++) {
        CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//        animation.delegate = self;
        animation.fromValue = @0;
        animation.toValue = @1;
        [animationArrays addObject:animation];
        
        UIBezierPath *arcPath  = nil;
        if (i == 0) {
            arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake([pointArray[i*2] floatValue], [pointArray[i*2+1] floatValue])
                                                     radius:60
                                                 startAngle:-M_PI
                                                   endAngle:M_PI
                                                  clockwise:YES];
        }
        else if (i == 1)
        {
            arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake([pointArray[i*2] floatValue], [pointArray[i*2+1] floatValue])
                                                     radius:20
                                                 startAngle:-M_PI_4*3
                                                   endAngle:-M_PI_4*1
                                                  clockwise:YES];
        }
        else if (i == 2)
        {
            arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake([pointArray[i*2] floatValue], [pointArray[i*2+1] floatValue])
                                                     radius:20
                                                 startAngle:-M_PI_4*3
                                                   endAngle:-M_PI_4*1
                                                  clockwise:YES];
        }
        else if (i == 3)
        {
            arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake([pointArray[i*2] floatValue], [pointArray[i*2+1] floatValue])
                                                     radius:5
                                                 startAngle:-M_PI
                                                   endAngle:M_PI
                                                  clockwise:YES];
        }
        else if ( i == 4)
        {
            arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake([pointArray[i*2] floatValue], [pointArray[i*2+1] floatValue])
                                                     radius:5
                                                 startAngle:-M_PI
                                                   endAngle:M_PI
                                                  clockwise:YES];
        }
        else
        {
            arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake([pointArray[i*2] floatValue], [pointArray[i*2+1] floatValue])
                                                     radius:20
                                                 startAngle:M_PI_4*3
                                                   endAngle:M_PI_4
                                                  clockwise:NO];
        }
        
        CAShapeLayer *arcLayer = [CAShapeLayer new];
        arcLayer.frame = self.view.frame;
        arcLayer.lineWidth = 5;
        arcLayer.fillColor = nil;
        arcLayer.strokeColor = [UIColor orangeColor].CGColor;
        [self.view.layer addSublayer:arcLayer];
        arcLayer.path = arcPath.CGPath;
        
        group.animations = animationArrays;
        [arcLayer addAnimation:group forKey:@"strokeEnd"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [arcLayer removeAllAnimations];
            [arcLayer removeAllSublayers];
            [arcLayer removeFromSuperlayer];
        });
    }
}

#pragma mark - 折叠
- (void)flodAnimationSelector{
    if (self.flodImg) {
        [self.flodImg removeFromSuperview];
        self.flodImg = nil;
    }else{
        self.flodImg = [[UIImageView alloc] initWithFrame:CGRectMake(kMainScreenWidth - 200, 100, 200, 300)];
        self.flodImg.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"L41" ofType:@"png"]]];
        [self.view addSubview:self.flodImg];
        //动画的containerLayer颜色和父视图相同，此处父视图改成红色验证,UIView+Fold -- 158行
        UIColor *tempColor = self.view.backgroundColor;
        self.view.backgroundColor = [UIColor orangeColor];
        
        @weakify(self);
        [self.flodImg foldWithFolds:3 duration:1 completion:^(BOOL finished) {
            @strongify(self);
            [self.flodImg unfoldWithFolds:5 duration:1 completion:^(BOOL finished) {
                @strongify(self);
                self.view.backgroundColor = tempColor;
            }];
        }];
    }
}

#pragma mark - 3D滚动视图
- (void)threeDBannerSelector{
    if (self.banner) {
        [self.banner removeFromSuperview];
        self.banner = nil;
    }else{
        self.banner = [[PPBannerView alloc] initWithFrame:CGRectMake(0, 100, kMainScreenWidth, 300)];
        [self.view addSubview:self.banner];
    }
}

#pragma mark - 粒子效果
- (void)emitterAnimationSelector{
    // =================== 背景图片 ===========================
    if (self.emitterImg) {
        [self.emitterImg.layer removeAllAnimations];
        [self.emitterImg.layer removeAllSublayers];
        [self.emitterImg removeFromSuperview];
        self.emitterImg = nil;
    }else{
        self.emitterImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 200)];
        self.emitterImg.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"樱花树" ofType:@"jpg"]]];
        self.emitterImg.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:self.emitterImg];
        
        // =================== 樱花飘落 ====================
        CAEmitterLayer * snowEmitterLayer = [CAEmitterLayer layer];
        snowEmitterLayer.emitterPosition = CGPointMake(100, -30);
        snowEmitterLayer.emitterSize = CGSizeMake(self.view.bounds.size.width * 2, 0);
        /**
         *  发送的样式:emitterMode //120行开始
         -  CA_EXTERN NSString * const kCAEmitterLayerPoints以点的方式  默认样式
         -   CA_EXTERN NSString * const kCAEmitterLayerOutline线的样式
         -   CA_EXTERN NSString * const kCAEmitterLayerSurface  以面的形式
         -   CA_EXTERN NSString * const kCAEmitterLayerVolume    以团的样式
         */
        snowEmitterLayer.emitterMode = kCAEmitterLayerOutline;
        
        /**
         *  发送形状的样式:emitterShape
         -  CA_EXTERN NSString * const kCAEmitterLayerPoint  点
         -  CA_EXTERN NSString * const kCAEmitterLayerLine   线
         -  CA_EXTERN NSString * const kCAEmitterLayerRectangle  举行
         -  CA_EXTERN NSString * const kCAEmitterLayerCuboid 立方体
         -  CA_EXTERN NSString * const kCAEmitterLayerCircle 曲线
         -  CA_EXTERN NSString * const kCAEmitterLayerSphere 圆形
         */
        snowEmitterLayer.emitterShape = kCAEmitterLayerLine;
        
        /**
         *  粒子出现的样式:renderMode//点进去第129行开始
         -   CA_EXTERN NSString * const kCAEmitterLayerOldestFirst最后一个出生的粒子在第一个
         -   CA_EXTERN NSString * const kCAEmitterLayerOldestLast最后出生的就在最后一个
         -   CA_EXTERN NSString * const kCAEmitterLayerBackToFront把后面的放到上面
         -   CA_EXTERN NSString * const kCAEmitterLayerAdditive叠加效果
         */
        //    snowEmitterLayer.renderMode = kCAEmitterLayerAdditive;
        
        
        /**
         *  - 表示粒子的是:CAEmitterCell  他不是一个Layer
         - contents:粒子的内容
         - lifetime:存活时间
         - lifetimeRange:存活时间的范围
         - birthRate:每秒的粒子生成的数量
         - emissionLatitude:散发的维度  他表示的是一个弧度   上下
         - emissionLongitude:散发的经度  ->弧度   ->左右
         - velocity:发送的速度   速度越快发送的越远->动力
         -  velocityRange:发送速度的范围
         - xAcceleration;  x，y，z轴的加速度  惯性  动力
         - yAcceleration;
         - zAcceleration;
         - emissionRange:散发的范围  ->弧度  ->范围
         - name:粒子的名字  可以通过名字  找到粒子
         */
        CAEmitterCell * snowCell = [CAEmitterCell emitterCell];
        snowCell.contents = (__bridge id)[UIImage imageNamed:@"樱花瓣2"].CGImage;
        
        // 花瓣缩放比例
        snowCell.scale = 0.02;
        snowCell.scaleRange = 0.5;
        
        // 每秒产生的花瓣数量
        snowCell.birthRate = 7;
        snowCell.lifetime = 80;
        
        // 每秒花瓣变透明的速度
        snowCell.alphaSpeed = -0.01;
        
        // 秒速“五”厘米～～
        snowCell.velocity = 40;
        snowCell.velocityRange = 60;
        
        // 花瓣掉落的角度范围
        snowCell.emissionRange = M_PI;
        
        // 花瓣旋转的速度
        snowCell.spin = M_PI_4;
        
        // 每个cell的颜色
        //    snowCell.color = [[UIColor redColor] CGColor];
        
        // 阴影的 不透明 度
        snowEmitterLayer.shadowOpacity = 1;
        // 阴影化开的程度（就像墨水滴在宣纸上化开那样）
        snowEmitterLayer.shadowRadius = 8;
        // 阴影的偏移量
        snowEmitterLayer.shadowOffset = CGSizeMake(3, 3);
        // 阴影的颜色
        snowEmitterLayer.shadowColor = [[UIColor whiteColor] CGColor];
        
        
        snowEmitterLayer.emitterCells = [NSArray arrayWithObject:snowCell];
        [self.emitterImg.layer addSublayer:snowEmitterLayer];
    }
}

#pragma mark - 转场动画
- (void)trasition1Selector{
    [self.navigationController pushViewController:[[NSClassFromString(@"XWMagicMoveController") alloc] init] animated:YES];
}

- (void)trasition2Selector{
    [self.navigationController pushViewController:[[NSClassFromString(@"XWPresentOneController") alloc] init] animated:YES];
}

- (void)trasition3Selector{
    [self.navigationController pushViewController:[[NSClassFromString(@"XWPageCoverController") alloc] init] animated:YES];
}

- (void)trasition4Selector{
    [self.navigationController pushViewController:[[NSClassFromString(@"XWCircleSpreadController") alloc] init] animated:YES];
}

- (void)trasition5Selector{
    [self.navigationController pushViewController:[[NSClassFromString(@"PixelViewController") alloc] init] animated:YES];
}

#pragma mark - 高斯模糊
- (void)gaussiBlurSelector{
    if (self.gaussiBlurImg) {
        [self.gaussiBlurImg removeFromSuperview];
        self.gaussiBlurImg = nil;
    }else{
        self.gaussiBlurImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, kMainScreenWidth, 300)];
        self.gaussiBlurImg.contentMode =UIViewContentModeScaleAspectFill;
        [self.view addSubview:self.gaussiBlurImg];
        //dispatch_async指的是无需等待block返回，可以立即往下执行,dispatch_sync需要等待返回
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //dataWithContentsOfURL这个是个sync方法，返回结果或超时之后才会往下执行
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://img5.duitang.com/uploads/item/201409/10/20140910153458_Ze8Zt.thumb.700_0.jpeg"]];
            NSLog(@"1");
            //dispatch_sync需要等待数据返回，打印顺序是1、2、3，如果换成dispatch_async，打印是1、（2、3）不确定，一般来说是1、3、2，data变成img需要时间
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *img = [UIImage imageWithData:imgData];
                self.gaussiBlurImg.image = img;
                NSLog(@"2");
            });
            NSLog(@"3");
        });
    }
}

- (UIImage *)gaussiBlurByImage:(UIImage *)img radius:(CGFloat)number useRect:(CGRect)useRect{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [[CIImage alloc] initWithImage:img];
    // create gaussian blur filter
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:number] forKey:@"inputRadius"];
    // blur image
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    if (CGRectEqualToRect(useRect, CGRectZero)) {
        useRect = [result extent];
    }
    CGImageRef cgImage = [context createCGImage:result fromRect:useRect];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return image;
}

#pragma mark - 高斯模糊的提交按钮
- (void)yooliSubmitBtnSelector{
    if (self.submitBtn) {
        [self.submitBtn removeFromSuperview];
        self.submitBtn = nil;
    }else{
        self.submitBtn = [[LKSubmitButton alloc] initWithFrame:CGRectMake(15, 200, 345, 48)];
        [self.view addSubview:self.submitBtn];
    }
}

#pragma mark - 截取图片
- (void)cutSelector{
    if (self.cutImg) {
        [self.cutImg removeFromSuperview];
        self.cutImg = nil;
    }else{
        self.cutImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 200, kMainScreenWidth, 200)];
        [self.view addSubview:self.cutImg];
        
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"樱花树" ofType:@"jpg"]]];
        self.cutImg.layer.contents = (__bridge id)image.CGImage;
        self.cutImg.layer.contentsGravity = kCAGravityResizeAspectFill;
        self.cutImg.layer.contentsScale = 2.0;
        self.cutImg.layer.masksToBounds = YES;
        self.cutImg.layer.backgroundColor = [UIColor cyanColor].CGColor;
        self.cutImg.image = image;
        self.cutImg.layer.contentsRect = CGRectMake(0.25, 0.25, 0.75, 0.75);
    }
}

@end
