//
//  AutomaticDimensionViewController.m
//  OC
//
//  Created by yier on 2019/3/12.
//  Copyright © 2019 yier. All rights reserved.
//

#import "AutomaticDimensionViewController.h"
#import "AutomaticDimensionCell.h"

@interface AutomaticDimensionViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray * dataSource;
@end

@implementation AutomaticDimensionViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = @"tableview自适应高度";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:[AutomaticDimensionCell cellReuseIdentifier] bundle:nil] forCellReuseIdentifier:[AutomaticDimensionCell cellReuseIdentifier]];
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)initData{
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[@{@"photo":@"https://ws2.sinaimg.cn/large/006tNbRwgy1fy3rvog7q3j30dw093wey.jpg",@"name":@"张三疯",@"content":@"　这两天出门不戴口罩的都是勇士，雾霾这两天赖在南京不肯走，昨天空气质量重度污染，南京发布入冬后首个霾预警、重污染天气蓝色预警。昨天傍晚，天空更是出现了雾霾自带颜色的奇景，网友吐槽：“玫红色的雾霾还是头回吸上。”现代快报记者了解到，这种现象是傍晚的霞光跟雾霾走在一起造成的，不是特殊污染物造成的。"},@{@"photo":@"https://ws2.sinaimg.cn/large/006tNbRwgy1fy3rvog7q3j30dw093wey.jpg",@"name":@"张三疯",@"content":@"　这两天出门不戴口罩的都是勇士，雾霾这两天赖在南京不肯走，昨天空气质量重度污染，南京发布入冬后首个霾预警、重污染天气蓝色预警。昨天傍晚，天空更是出现了雾霾自带颜色的奇景，网友吐槽：“玫红色的雾霾还是头回吸上。”现代快报记者了解到，这种现象是傍晚的霞光跟雾霾走在一起造成的，不是特殊污染物造成的。"},@{@"photo":@"https://ws2.sinaimg.cn/large/006tNbRwgy1fy3rvog7q3j30dw093wey.jpg",@"name":@"张三疯",@"content":@"　这两天出门不戴口罩的都是勇士，雾霾这两天赖在南京不肯走，昨天空气质量重度污染，南京发布入冬后首个霾预警、重污染天气蓝色预警。昨天傍晚，天空更是出现了雾霾自带颜色的奇景，网友吐槽：“玫红色的雾霾还是头回吸上。”现代快报记者了解到，这种现象是傍晚的霞光跟雾霾走在一起造成的，不是特殊污染物造成的。"},@{@"photo":@"https://ws2.sinaimg.cn/large/006tNbRwgy1fy3rvog7q3j30dw093wey.jpg",@"name":@"张三疯",@"content":@"网友吐槽：“玫红色的雾霾还是头回吸上。”现代快报记者了解到，这种现象是傍晚的霞光跟雾霾走在一起造成的，不是特殊污染物造成的。"},@{@"photo":@"https://ws2.sinaimg.cn/large/006tNbRwgy1fy3rvog7q3j30dw093wey.jpg",@"name":@"张三疯",@"content":@"　这两天出门不戴口罩的都是勇士，雾霾这两天赖在南京不肯走，昨天空气质量重度污染，南京发布入冬后首个霾预警、重污染天气蓝色预警。昨天傍晚，天空更是出现了雾霾自带颜色的奇景，网友吐槽：“玫红色的雾霾还是头回吸上。”现代快报记者了解到，这种现象是傍晚的霞光跟雾霾走在一起造成的，不是特殊污染物造成的。"},@{@"photo":@"https://ws2.sinaimg.cn/large/006tNbRwgy1fy3rvog7q3j30dw093wey.jpg",@"name":@"张三疯",@"content":@"雾霾还是头回吸上。”现代快报记者了解到，这种现象是傍晚的霞光跟雾霾走在一起造成的，不是特殊污染物造成的。"},@{@"photo":@"https://ws2.sinaimg.cn/large/006tNbRwgy1fy3rvog7q3j30dw093wey.jpg",@"name":@"张三疯",@"content":@"　这两天出门不戴口罩的都是勇士，雾霾这两天赖在南京不肯走，昨天空气质量重度污染，南京发布入冬后首个霾预警、重污染天气蓝色预警。昨天傍晚，天空更是出现了雾霾自带颜色的奇景，网友吐槽：“玫红色的雾霾还是头回吸上。”现代快报记者了解到，这种现象是傍晚的霞光跟雾霾走在一起造成的，不是特殊污染物造成的。"},@{@"photo":@"https://ws2.sinaimg.cn/large/006tNbRwgy1fy3rvog7q3j30dw093wey.jpg",@"name":@"张三疯",@"content":@"　这两天出门不戴口罩的都是勇士，雾霾这两天赖在南京不肯走，昨天空气质量重度污染，南京发布入冬后首个霾预警、重污染天气蓝色预警。昨天傍晚，天空更是出现了雾霾自带颜色的奇景，网友吐槽：“玫红色的雾霾还是头回吸上。”现代快报记者了解到，这种现象是傍晚的霞光跟雾霾走在一起造成的，不是特殊污染物造成的。"}];
    [self.tableView reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AutomaticDimensionCell *cell = [tableView dequeueReusableCellWithIdentifier:[AutomaticDimensionCell cellReuseIdentifier] forIndexPath:indexPath];
    NSDictionary *dic = dictionaryInArrayAtIndex(self.dataSource, indexPath.row);
    [cell fillCellWithModel:dic indexPath:indexPath];
    return cell;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self beginShowNagc:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"******end %f",scrollView.contentOffset.y);
    if (scrollView.contentOffset.y <= kStatusBarHeight + 44 ) {
        [self beginShowNagc:NO];
        return;
    }
    
    CGFloat currentOffset = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom;
    CGFloat maximumOffset = scrollView.contentSize.height;
    //判断是否滑到底
    CGFloat offset = maximumOffset - currentOffset;
    if (offset <= 0) {
        NSLog(@"滑到底部了");
        return;
    }
    
    //scrollView已经有拖拽手势，直接拿到scrollView的拖拽手势
    UIPanGestureRecognizer *pan = scrollView.panGestureRecognizer;
    //获取到拖拽的速度 >0 向下拖动 <0 向上拖动
    CGFloat velocity = [pan velocityInView:scrollView].y;
    
    if (velocity <- 5) {
        //向上拖动，隐藏导航栏
        [self beginHiddenNagc];
    }else if (velocity > 5) {
        //向下拖动，显示导航栏
        [self beginShowNagc:YES];
    }else if(velocity == 0){
        //停止拖拽
    }
    
}

#pragma mark - 导航栏隐藏及显示相关

- (void)beginShowNagc:(BOOL)animation
{
    if (!self.navigationController.navigationBar.hidden) {
        return;
    }
    [self.navigationController setNavigationBarHidden:NO animated:animation];
    if (animation) {
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [self.view layoutIfNeeded];
        }completion:nil];
    }else{
        [self.view layoutIfNeeded];
    }
}

- (void)beginHiddenNagc {
    if (self.navigationController.navigationBar.hidden) {
        return;
    }
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
    }];
}

@end
