//
//  ContainerViewController.m
//  OC
//
//  Created by yier on 2019/3/19.
//  Copyright © 2019 yier. All rights reserved.
//

#import "ContainerViewController.h"

@interface ContainerViewController ()

@property (nonatomic, strong) UIVisualEffectView * maskView;///<主控制器上面的蒙层
@end

@implementation ContainerViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    [self configChildViewController];
    [self configMaskView];
}

- (void)configChildViewController{
    self.settingVC = [[UIStoryboard storyboardWithName:@"Setting" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SettingVC"];
    self.settingVC.view.frame = self.view.frame;
    [self.view addSubview:self.settingVC.view];
    [self addChildViewController:self.settingVC];
    [self.settingVC didMoveToParentViewController:self];
    
    self.mineVC = [[UIStoryboard storyboardWithName:@"Mine" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MineVC"];
    self.mineVC.view.frame = self.view.frame;
    [self.view addSubview:self.mineVC.view];
    [self addChildViewController:self.mineVC];
    [self.mineVC didMoveToParentViewController:self];

    self.tabbarVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"BaseTabBarVC"];
    self.tabbarVC.view.frame = self.view.frame;
    [self.view addSubview:self.tabbarVC.view];
    [self addChildViewController:self.tabbarVC];
    [self.tabbarVC didMoveToParentViewController:self];
}

- (void)configMaskView{
    UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.maskView = [[UIVisualEffectView alloc]initWithEffect:blur];
    self.maskView.hidden = YES;
    self.maskView.alpha = 0.0;
    self.maskView.frame = CGRectMake(0, 0, self.tabbarVC.view.frame.size.width, self.tabbarVC.view.frame.size.height);
    [self.tabbarVC.view addSubview:self.maskView];
    
    UIScreenEdgePanGestureRecognizer * screenPan = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(screenPan:)];
    screenPan.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:screenPan];
    
    UIPanGestureRecognizer * identifyMineViewPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(identifyMineViewPanEvent:)];
    [self.maskView addGestureRecognizer:identifyMineViewPan];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenMine)];
    [self.maskView addGestureRecognizer:tap];
}

#pragma mark - initData
- (void)initData{
    
}

- (void)identifyMineViewPanEvent:(UIPanGestureRecognizer *)pan
{
    float moveWidth = [pan translationInView:self.tabbarVC.view].x;
    //    float velocity = [pan velocityInView:self.tabbarVC.view].x;//速率
    float percent = moveWidth/(self.tabbarVC.view.bounds.size.width*0.7);
    float scale = 0.8 - percent*0.2;
    float scale2 = 1+percent*0.2;
    switch (pan.state) {
        case UIGestureRecognizerStateChanged:
        {
            if (moveWidth < 0 && moveWidth >= - self.tabbarVC.view.bounds.size.width*0.7 )
            {
                self.maskView.alpha = (1+percent)*0.7;
                self.tabbarVC.view.transform = CGAffineTransformMake(scale, 0, 0, scale,self.tabbarVC.view.bounds.size.width* 0.7+moveWidth , 0);
                self.mineVC.menuView.transform = CGAffineTransformMake(scale2, 0, 0, scale2,self.tabbarVC.view.bounds.size.width*0.7*(percent), 0);
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
                if (moveWidth >= -60) {
                    [self showMine];
                } else {
                    [self hiddenMine];
                }
        }
            break;
        default:
            break;
    }
    
}

- (void)screenPan:(UIScreenEdgePanGestureRecognizer *)screenPan{
    
    float moveWidth = [screenPan translationInView:self.tabbarVC.view].x;
    //    float velocity = [screenPan velocityInView:tabbarVC.view].x;
    float percent = moveWidth/(self.tabbarVC.view.bounds.size.width*0.7);
    self.maskView.hidden = NO;
    float scale = 1- percent*0.2;
    float scale2 = 0.8+percent*0.2;
    switch (screenPan.state) {
        case UIGestureRecognizerStateChanged:
        {
            if (moveWidth > 0 && moveWidth <= self.tabbarVC.view.bounds.size.width*0.7)
            {
                self.maskView.alpha = percent*0.7;
                self.tabbarVC.view.transform = CGAffineTransformMake(scale, 0, 0, scale, moveWidth, 0);
                self.mineVC.menuView.transform = CGAffineTransformMake(scale2, 0, 0, scale2, self.tabbarVC.view.bounds.size.width* 0.3*(percent-1), 0);
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            //移动距离少于60关闭，否则打开个人中心
            if (moveWidth <= 60) {
                [self hiddenMine];
            } else {
                [self showMine];
            }
        default:
            break;
        }
    }
}

- (void)showMine{
    self.maskView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.tabbarVC.view.transform = CGAffineTransformMake(0.8, 0, 0, 0.8, self.tabbarVC.view.bounds.size.width*0.7, 0);
        self.maskView.alpha = 0.7;
        self.mineVC.menuView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hiddenMine{
    [UIView animateWithDuration:0.5 animations:^{
        self.tabbarVC.view.transform = CGAffineTransformIdentity;
        self.mineVC.menuView.transform = CGAffineTransformMake(0.8, 0, 0, 0.8, - self.tabbarVC.view.bounds.size.width * 0.3, 0);
        self.maskView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.maskView.hidden = YES;
    }];
}

@end
