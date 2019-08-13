//
//  DrawCircleViewController.m
//  OC
//
//  Created by yier on 2019/4/1.
//  Copyright © 2019 yier. All rights reserved.
//

#import "DrawCircleViewController.h"
#import "UIColor+Gradient.h"

@interface DrawCircleViewController ()
@property (nonatomic, strong) UILabel *v;
@property (nonatomic, strong) UIButton *v1;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CALayer *tintLayer;
@property (nonatomic, strong) CALayer *imageLayer;

@end

@implementation DrawCircleViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"手绘画圈颜色渐变");
    self.lineWidth = 17.0f;
    self.width = 200;
    
    self.v = [[UILabel alloc] initWithFrame:CGRectMake(100, 200, self.width, self.width)];
    self.v.text = @"渐变";
    self.v.textColor = [UIColor orangeColor];
    self.v.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.v];
    
    self.v1  = [[UIButton alloc] initWithFrame:CGRectMake(100, kMainScreenHeight - 100 - self.width, self.width, self.width)];
    [self.v1 setTitle:@"点击" forState:UIControlStateNormal];
    [self.view addSubview:self.v1];
    @weakify(self);
    [[self.v1 rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
       @strongify(self);
        if (self.shapeLayer.strokeStart < self.shapeLayer.strokeEnd) {
            self.shapeLayer.strokeEnd -= 1.0f / 10;
        }else{
            self.shapeLayer.strokeEnd += 1.0f / 10;
        }
    }];
    
    [self createShapeLayer];
    [self createTintLayer];
    [self createImageLayer];
}

- (void)initData{
    
}

#pragma mark - setupUI

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)createShapeLayer{
    
    CGFloat width = self.v1.frame.size.width;
    
    //创建出CAShapeLayer
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.frame = CGRectMake(0, 0, width, width);
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色为ClearColor
    
    //设置线条的宽度和颜色
    self.shapeLayer.lineWidth = self.lineWidth;
    UIColor *benginColor = [[UIColor orangeColor] colorWithAlphaComponent:0.6];
    UIColor *endColor = [UIColor orangeColor];
    self.shapeLayer.strokeColor = [UIColor colorWithGradientStyle:UIGradientStyleArc withFrame:self.v1.bounds lineWidth:self.lineWidth andColors:@[benginColor,endColor] percent:1].CGColor;
    
    //设置stroke起始点
    self.shapeLayer.strokeStart = 0.0;
    //逆时针缺口
    self.shapeLayer.strokeEnd = 1.0 - 0.1;
    
    //计算shapeLayer相对于v1的中心点
    CGPoint center = CGPointMake(self.v1.frame.size.width / 2.f, self.v1.frame.size.width / 2.f);
    
    //clockwise：YES ，顺时针
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:(width - self.lineWidth) / 2.f
                                                    startAngle: - M_PI/2.0
                                                      endAngle:M_PI * 3/2.0
                                                     clockwise:YES];
    
    //让贝塞尔曲线与CAShapeLayer产生联系
    self.shapeLayer.path = path.CGPath;
    
    //线条拐角
    self.shapeLayer.lineCap = kCALineCapRound;
    //终点处理
    //    self.shapeLayer.lineJoin = kCALineJoinRound;
    
    //添加并显示
    [self.v1.layer addSublayer:self.shapeLayer];
}

- (void)createTintLayer{
    self.tintLayer = [CALayer layer];
    self.tintLayer.frame = CGRectMake(0, 0, self.width, self.width);
    
    self.tintLayer.borderColor = LKHexColor(0xFFF5D4).CGColor;
    self.tintLayer.borderWidth = self.lineWidth;
    self.tintLayer.cornerRadius = self.width /2.0;
    
    [self.v.layer addSublayer:self.tintLayer];
}

- (void)createImageLayer{
    self.imageLayer = [CALayer layer];
    self.imageLayer.frame = CGRectMake(-self.lineWidth/2, -self.lineWidth/2, self.width + self.lineWidth, self.width + self.lineWidth);
    UIColor *benginColor = [UIColor orangeColor];
    UIColor *endColor = LKHexColor(0xFDC374);
    UIColor *color= [UIColor colorWithGradientStyle:UIGradientStyleArc withFrame:self.imageLayer.bounds lineWidth:self.lineWidth andColors:@[benginColor,endColor] percent:0.9];
    
    self.imageLayer.contents = (__bridge id)[self imageWithColor:color size:self.imageLayer.bounds.size].CGImage;
    
    [self.v.layer addSublayer:self.imageLayer];
    
}

#pragma mark - initData

@end
