//
//  PixelViewController.m
//  OC
//
//  Created by yier on 2019/4/7.
//  Copyright © 2019 yier. All rights reserved.
//

#import "PixelViewController.h"
#import "HUTransitionAnimator.h"
#import "ZBFallenBricksAnimator.h"


typedef enum {
    TransitionTypeNormal,
    TransitionTypeVerticalLines,
    TransitionTypeHorizontalLines,
    TransitionTypeGravity,
} TransitionType;

@interface PixelViewController ()<UINavigationControllerDelegate>
@property (nonatomic, assign) TransitionType type;

@end

@implementation PixelViewController

- (void)dealloc{
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

#pragma mark - setupUI
- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"像素pop动画");
    self.type = TransitionTypeNormal;
    self.navigationController.delegate = self;
    
    for (NSInteger i = 0; i<3; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
        btn.tag = 1000+i;
        [btn setTitle:[NSString stringWithFormat:@"像素pop:%zd",i] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor orangeColor]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.height.with.mas_equalTo(100);
            make.top.mas_equalTo(self.view.mas_top).mas_offset(200+i*100);
        }];
        
        [btn addTarget:self action:@selector(pop:) forControlEvents:UIControlEventTouchUpInside];
    }

}

#pragma mark - initData
- (void)initData{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// =============================================================================
#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    NSObject <UIViewControllerAnimatedTransitioning> *animator;
    
    switch (self.type) {
        case TransitionTypeVerticalLines:
            animator = [[HUTransitionVerticalLinesAnimator alloc] init];
            [(HUTransitionAnimator *)animator setPresenting:NO];
            break;
        case TransitionTypeHorizontalLines:
            animator = [[HUTransitionHorizontalLinesAnimator alloc] init];
            [(HUTransitionAnimator *)animator setPresenting:NO];
            break;
        case TransitionTypeGravity:
            animator = [[ZBFallenBricksAnimator alloc] init];
            break;
        default:
            animator = nil;
    }
    
    return animator;
}


// =============================================================================
#pragma mark - IBAction

- (void)pop:(UIButton *)sender {
    switch (sender.tag - 1000) {
        case 0:
            self.type = TransitionTypeVerticalLines;
            break;
        case 1:
            self.type = TransitionTypeHorizontalLines;
            break;
            
        case 2:
            self.type = TransitionTypeGravity;
            break;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
