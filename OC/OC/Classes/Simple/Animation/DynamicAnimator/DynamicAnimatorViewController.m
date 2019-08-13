//
//  DynamicAnimatorViewController.m
//  OC
//
//  Created by yier on 2019/4/7.
//  Copyright © 2019 yier. All rights reserved.
//

#import "DynamicAnimatorViewController.h"

@interface DynamicAnimatorViewController ()
@property (weak, nonatomic) IBOutlet UIView *tapView;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBeahvior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;
@end

@implementation DynamicAnimatorViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createDynamiceAnimator];
    
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(dynamicAnimatorSelector:)];
    [self.tapView addGestureRecognizer:gesture];
}

#pragma mark - 物理引擎
- (void)createDynamiceAnimator{
    // Set up
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    self.gravityBeahvior = [[UIGravityBehavior alloc] initWithItems:@[]];
    
    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[]];
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    
    self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[]];
    self.itemBehavior.elasticity = 0.6;
    self.itemBehavior.friction = 0.5;
    self.itemBehavior.resistance = 0.5;
    
    [self.animator addBehavior:self.gravityBeahvior];
    [self.animator addBehavior:self.collisionBehavior];
    [self.animator addBehavior:self.itemBehavior];
}

- (void)dynamicAnimatorSelector:(UITapGestureRecognizer *)gesture{
    NSUInteger num = arc4random() % 40 + 1;
    NSString *filename = [NSString stringWithFormat:@"m%lu", (unsigned long)num];
    UIImage *image = [UIImage imageNamed:filename];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    
    CGPoint tappedPos = [gesture locationInView:gesture.view];
    imageView.center = tappedPos;
    
    [self.gravityBeahvior addItem:imageView];
    [self.collisionBehavior addItem:imageView];
    [self.itemBehavior addItem:imageView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
