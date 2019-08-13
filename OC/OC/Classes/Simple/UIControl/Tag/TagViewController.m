//
//  TagViewController.m
//  OC
//
//  Created by yier on 2019/3/18.
//  Copyright © 2019 yier. All rights reserved.
//

#import "TagViewController.h"
#import "TagsCollectionView.h"

#import <MJRefresh/MJRefresh.h>

@interface TagViewController ()
@property (strong, nonatomic) TagsCollectionView *collectView;

@end

@implementation TagViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    [self configTagCollectView];
}

- (void)initData{
    
}

#pragma mark - setupUI

- (void)configTagCollectView
{
    self.collectView = [[TagsCollectionView alloc] initWithFrame:CGRectMake(0, 100,kMainScreenWidth, 200)] ;
    self.collectView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.collectView];
    //VerticalEnable为YES，竖向排列CGRectMake(0,0,kMainScreenWidth,200),为NO时CGRectMake(0, 0,kMainScreenWidth, 50)
    [self.collectView setUpCollectionViewByScrollVerticalEnable:YES frame:CGRectMake(0, 0,kMainScreenWidth, 200)];
    self.collectView.tagsView.backgroundColor = [UIColor lightGrayColor];
    
    NSMutableArray<NSString *> * tagsArr = @[].mutableCopy;
    NSString * str = @"时间加上亟待解决啥都会撒谎接口的啥空间好的撒回家回家看的撒和空间的撒谎进口红酒多撒谎就挥洒的还好撒打开和";
    NSInteger count = 1;
    
    for (int i = 0 ; i < 30; i++) {
        count++;
        if (count > 5) {
            count = random() % 5 + 1;
        }
        NSString *tagName = [str substringWithRange:NSMakeRange(i,count)];
        [tagsArr addObject:tagName];
    }
    
    [self.collectView caculaterTagsBtnWidthWithTagsArray:tagsArr];
    
    self.collectView.selectBlock = ^(NSInteger index, NSString * tagName){
        NSLog(@"%@",tagName);
    };
    
    self.collectView.tagsView.alwaysBounceVertical = YES;
    
//    @weakify(self);
//    self.collectView.tagsView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        @strongify(self);
//        NSLog(@"下拉");
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.collectView.tagsView.mj_header endRefreshing];
//        });
//    }];
}

#pragma mark - initData

@end
