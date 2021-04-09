//
//  OCVideoLoadingView.m
//  AA
//
//  Created by yier on 2021/4/9.
//


#import "OCVideoLoadingView.h"
#import <Masonry/Masonry.h>

@interface OCVideoLoadingView()
@property (nonatomic, strong) UIView *progress;

@property (nonatomic, strong) CABasicAnimation *animation;
@property (nonatomic, assign) BOOL animating;///< 表示正在进行loading动画
@end

@implementation OCVideoLoadingView

- (void)dealloc {
    [self.progress.layer removeAllAnimations];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.progress];
    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self);
        make.height.mas_equalTo(1);
    }];
    self.progress.hidden = YES;
}

- (void)startAnimation {
    if (self.animating == YES) {
        return;
    }
    self.animating = YES;
    [self.progress.layer removeAllAnimations];
    [self.progress.layer addAnimation:self.animation forKey:@"animationScaleX"];
    self.progress.hidden = NO;
}

- (void)stopAnimation {
    if (self.animating == NO) {
        return;
    }
    self.animating = NO;
    self.progress.hidden = YES;
    [self.progress.layer removeAllAnimations];
}

#pragma mark - lazy load
- (UIView *)progress {
    if (!_progress) {
        _progress = [[UIView alloc] initWithFrame:CGRectZero];
        _progress.backgroundColor = [UIColor whiteColor];
        [self addSubview:_progress];
    }
    return _progress;
}

- (CABasicAnimation *)animation {
    if (!_animation) {
        _animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
        _animation.fromValue = @(0);
        _animation.toValue = @(0.98);
        _animation.repeatCount = HUGE_VAL;
        _animation.duration = 0.5;
        _animation.removedOnCompletion = NO;
        _animation.fillMode = kCAFillModeForwards;
    }
    return _animation;
}

@end
