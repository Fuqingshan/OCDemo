//
//  HitTestViewController.m
//  OC
//
//  Created by yier on 2019/4/7.
//  Copyright © 2019 yier. All rights reserved.
//

#import "HitTestViewController.h"
#import "HitTestBaseView.h"
#import "LLSHitTestView.h"
#import "View1.h"
#import "View2.h"
#import "View3.h"
#import "HitButton.h"
#import <CKYPhotoBrowser/KYPhotoBrowserController.h>


@interface HitTestViewController ()
@property (weak, nonatomic) IBOutlet LLSHitTestView *view1;
@property (weak, nonatomic) IBOutlet LLSHitTestView *view2;
@property (weak, nonatomic) IBOutlet LLSHitTestView *view3;
@property (weak, nonatomic) IBOutlet LLSHitTestView *view4;

@property (weak, nonatomic) IBOutlet HitTestBaseView *baseView;
@property (weak, nonatomic) IBOutlet View1 *a1;
@property (weak, nonatomic) IBOutlet View2 *a2;
@property (weak, nonatomic) IBOutlet View3 *a3;

@property (weak, nonatomic) IBOutlet HitButton *hitButton;

@end

@implementation HitTestViewController

/**
 hitTest 的调用顺序：
 touch -> UIApplication -> UIWindow -> UIViewController.view -> subViews -> ....-> 合适的view

 事件的传递顺序：
 view -> superView ...- > UIViewController.view -> UIViewController -> UIWindow -> UIApplication -> 事件丢弃
 */
- (void)dealloc{
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

#pragma mark - setupUI
- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"响应链");

    self.view1.hitTestType = LLSHitTestTypeNoClip;
    
    //    _view2.hitTestType = LLSHitTestTypeIgnore;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGPoint pointStart = CGPointMake(_view4.frame.size.width/2, _view4.frame.size.height/3);
    CGPoint pointEnd = CGPointMake(_view4.frame.size.width/2, _view4.frame.size.height);
    CGPoint controlPoint1 = CGPointMake(_view4.frame.size.width, 0);
    CGPoint controlPoint4 = CGPointMake(0, 0);
    CGPoint controlPoint5 = CGPointMake(_view4.frame.size.width, _view4.frame.size.height/2);
    CGPoint controlPoint6 = CGPointMake(0, _view4.frame.size.height/2);
    
    [path moveToPoint:pointStart];
    [path addCurveToPoint:pointEnd controlPoint1:controlPoint1 controlPoint2:controlPoint5];
    [path addCurveToPoint:pointStart controlPoint1:controlPoint6 controlPoint2:controlPoint4];
    
    //    _view4.path = path;
}

#pragma mark - initData
- (void)initData{
    
}

#pragma event 
- (IBAction)tap1:(id)sender {
    NSLog(@"tap1");
}

- (IBAction)tap2:(id)sender {
    NSLog(@"tap2");
}

- (IBAction)tap3:(id)sender {
    NSLog(@"tap3");
}

- (IBAction)tap4:(id)sender {
    NSLog(@"tap4");
}

- (IBAction)baseta:(id)sender {
    NSLog(@"base ta tap");
}

- (IBAction)ta1:(id)sender {
    NSLog(@"ta1 tap");
}

- (IBAction)ta2:(id)sender {
    NSLog(@"ta2 tap");
}

- (IBAction)ta3:(id)sender {
    NSLog(@"ta3 tap");
}

- (IBAction)hitButton:(id)sender {
    NSLog(@"hitButton");
    [KYPhotoBrowserController showPhotoBrowserWithImages:@[[UIImage imageNamed:@"hittest.png"]] currentImageIndex:0 delegate:nil];
}

@end
