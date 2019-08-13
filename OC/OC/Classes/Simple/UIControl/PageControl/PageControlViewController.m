//
//  PageControlViewController.m
//  OC
//
//  Created by yier on 2019/3/14.
//  Copyright © 2019 yier. All rights reserved.
//

#import "PageControlViewController.h"
#import "JMPageControl.h"
#import "iCarousel.h"

@interface PageControlViewController ()<iCarouselDelegate,iCarouselDataSource,UIScrollViewDelegate>
@property (nonatomic, strong) JMPageControl *pageControl;
@property (nonatomic, strong) iCarousel *pictureContentView;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation PageControlViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)setupUI{
      self.navigationItem.title = @"PageControl和banner联动";
    [self setupiCarousel];
    [self setupPageControl];
}

- (void)initData{
    self.dataSource = @[
                        @"https://ws1.sinaimg.cn/large/006tNc79gy1fopai2lwrlj31kw0zk7wl.jpg"
                        ,@"https://ws3.sinaimg.cn/large/006tNc79gy1fopahdxlrqj31kw0wuag8.jpg"
                        ,@"https://ws3.sinaimg.cn/large/006tNbRwgy1fy3yhr2jx6j30ic0643yk.jpg"
                        ,@"https://ws2.sinaimg.cn/large/006tNbRwgy1fy3ygct1r1g309l036aa7.gif"
                        ,@"https://ws2.sinaimg.cn/large/006tNbRwgy1fy3ye220ldj309l0380sq.jpg"
                        ,@"https://ws3.sinaimg.cn/large/006tNbRwgy1fy3rvsnzsbj30dw099mx5.jpg"
                        ,@"https://ws2.sinaimg.cn/large/006tNbRwgy1fy3rvog7q3j30dw093wey.jpg"
                        ,@"https://ws2.sinaimg.cn/large/006tNbRwgy1fy3rvloz86j30et08c0sx.jpg"
                        ,@"https://ws1.sinaimg.cn/large/006tNbRwgy1fy3rrxyodsj30dw09f74f.jpg"
                        ];
    
        @weakify(self);
        self.timer = [NSTimer timerWithTimeInterval:3 block:^(NSTimer * _Nonnull timer) {
            @strongify(self);
            [self.pictureContentView scrollToItemAtIndex:self.pictureContentView.currentItemIndex + 1 duration:1];
        } repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

#pragma mark - setupUI
- (void)setupiCarousel{
    self.pictureContentView = [[iCarousel alloc] initWithFrame:CGRectMake(0, kStatusBarHeight + 44, [UIScreen mainScreen].bounds.size.width, 200)];
    self.pictureContentView.delegate = self;
    self.pictureContentView.dataSource = self;
    self.pictureContentView.type = iCarouselTypeTimeMachine;
    self.pictureContentView.decelerationRate = 0.5;
    self.pictureContentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.pictureContentView.layer.shadowOffset = CGSizeMake(0, 1.5);
    self.pictureContentView.layer.shadowOpacity = 0.2f;
    self.pictureContentView.layer.shadowRadius = 7.5f;
    self.pictureContentView.scrollEnabled = YES;
    self.pictureContentView.currentItemIndex = 3;
    [self.view addSubview:self.pictureContentView];
    [self.pictureContentView reloadData];
}

- (void)setupPageControl{
    self.pageControl = [[JMPageControl alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.pageControl];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(CellHeight);
        make.top.mas_equalTo(self.pictureContentView.mas_bottom).mas_offset(20);
    }];
    
    [self.pageControl updateDataByCurrentIndex:self.pictureContentView.currentItemIndex totalIndex:self.dataSource.count];
}

#pragma mark - iCarouselDataSource
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.dataSource.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable UIImageView *)view {
    
    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200)];
    view.layer.cornerRadius = 5.0f;
    view.contentMode = UIViewContentModeScaleAspectFill;
    view.clipsToBounds = YES;
    
    NSString *img = stringInArrayAtIndex(self.dataSource, index);
    [view sd_setImageWithURL:[NSURL URLWithString:img]];
    
    return view;
}

#pragma mark - iCarouselDelegate
- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case iCarouselOptionWrap: {
            return YES;
        }
        default: { return value; }
    }
}

- (void)carouselDidScroll:(iCarousel *)carousel{
    [self.pageControl calculatePageControlScrollOffset:carousel.scrollOffset];
}

//图片之间添加间距,自定义类型
-(CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform{
    static CGFloat max_sacle = 1.0f;
    static CGFloat min_scale = 0.8f;
    if (offset <= 1 && offset >= -1) {
        float tempScale = offset < 0 ? 1+offset : 1-offset;
        float slope = (max_sacle - min_scale) / 1;
        
        CGFloat scale = min_scale + slope*tempScale;
        transform = CATransform3DScale(transform, scale, scale, 1);
    }else{
        transform = CATransform3DScale(transform, min_scale, min_scale, 1);
    }
    return CATransform3DTranslate(transform, offset * _pictureContentView.itemWidth * 1.18, 0.0, 0.0);
}

@end
