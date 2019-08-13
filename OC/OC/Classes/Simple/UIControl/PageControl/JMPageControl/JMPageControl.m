//
//  JMPageControl.m
//  JMPageControl
//
//  Created by yier on 2018/1/29.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "JMPageControl.h"
#import "PageControlCell.h"
#import "PageControlModel.h"

@interface JMPageControl()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation JMPageControl

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setupView];
    }
    return self;
}

- (void)setupView{
    self.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.bounces = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self addSubview:self.collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:[PageControlCell cellIdentifier] bundle:nil] forCellWithReuseIdentifier:[PageControlCell cellIdentifier]];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(CellHeight);
        make.centerX.centerY.mas_equalTo(self);
        make.width.mas_equalTo(0);
    }];
}

- (void)updateDataByCurrentIndex:(NSInteger)currentIndex totalIndex:(NSInteger)totalIndex{
    if (totalIndex > MaxCount) {
        totalIndex = MaxCount;
    }
    if (currentIndex > totalIndex) {
        currentIndex = totalIndex;
    }
    [self.dataSource removeAllObjects];
    for (NSInteger i = 0; i<totalIndex; i++) {
        PageControlModel *model = [PageControlModel new];
        if (i == currentIndex) {
            model.type = PageControlUITypeOval;
        }
        [self.dataSource addObject:model];
    }
    
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(totalIndex * CellWidth);
    }];
    
    [self.collectionView reloadData];
    self.currentIndex = currentIndex;
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    if (currentIndex >= self.dataSource.count) {
        return;
    }
    if (currentIndex == self.currentIndex) {
        return;
    }
    
    _currentIndex = currentIndex;
    
    for (NSInteger i = 0; i < self.dataSource.count; i++) {
        PageControlModel *model = self.dataSource[i];
        model.type = self.currentIndex == i ? PageControlUITypeOval : PageControlUITypeCircle;
    }
    
    [self.collectionView reloadData];
}

- (void)calculatePageControlScrollOffset:(CGFloat)scrollOffset{
//    NSLog(@"scrollOffset:%f",scrollOffset);

    ///计算当前正在变成椭圆的cell的比例
    CGFloat ovalRatio = scrollOffset - (int)scrollOffset;
    if (ovalRatio == 0) {
        self.currentIndex = floor(scrollOffset);
        return;
    }
    
    CGFloat circleRatio = 1 - ovalRatio;
    ///计算滑动方向
    BannerScrollDirection direction = [self calculateBannerScrollDirectionByScrollOffset:scrollOffset];
    NSInteger circleIndex = self.currentIndex;
    NSInteger ovalIndex;
    ///当滑动方向向左时，比例反转
    if (direction == BannerScrollDirectionLeft) {
        ovalIndex = self.currentIndex - 1;
        CGFloat temp = ovalRatio;
        ovalRatio = circleRatio;
        circleRatio = temp;
    }else{
        ovalIndex = self.currentIndex + 1;
    }
    
  ///两端的特殊情况
    if (ovalIndex < 0) {
        ovalIndex = self.dataSource.count - 1;
    }else if (ovalIndex > self.dataSource.count - 1){
        ovalIndex = 0;
    }
    
    NSIndexPath *circlePath = [NSIndexPath indexPathForRow:circleIndex inSection:0];
    NSIndexPath *ovalPath = [NSIndexPath indexPathForRow:ovalIndex inSection:0];
    PageControlCell *circleCell = (PageControlCell *)[self.collectionView cellForItemAtIndexPath:circlePath];
    PageControlCell *ovalCell = (PageControlCell *)[self.collectionView cellForItemAtIndexPath:ovalPath];
    circleCell.model.type = PageControlUITypeCircle;
    ovalCell.model.type = PageControlUITypeOval;
   
    ///圆到椭圆宽度的差值
    CGFloat distanceShape = fabs(CellWidth - CellHeight);
    ///颜色的alpha的差值
    CGFloat distanceAlpha = 1 - 0.27;
        
    circleCell.pointWC.constant = CellHeight + distanceShape * circleRatio;
    ovalCell.pointWC.constant = CellHeight + distanceShape * ovalRatio;
    circleCell.pointView.backgroundColor = [UIColor lk_colorWithHexString:@"0x1C1C1C" alpha:(0.27 + distanceAlpha * circleRatio)];
    ovalCell.pointView.backgroundColor = [UIColor lk_colorWithHexString:@"0x1C1C1C" alpha:( 0.27 + distanceAlpha * ovalRatio)];
}

///计算banner的滚动方向
- (BannerScrollDirection)calculateBannerScrollDirectionByScrollOffset:(CGFloat)scrollOffset{
    BannerScrollDirection direction;
    if (self.currentIndex > scrollOffset) {
        direction = BannerScrollDirectionLeft;
    }else{
        direction = BannerScrollDirectionRight;
    }
    
    ///两端的特殊情况
    if (self.currentIndex == 0 && direction == BannerScrollDirectionRight && scrollOffset > self.dataSource.count - 1) {
        direction = BannerScrollDirectionLeft;
    }else if (self.currentIndex == self.dataSource.count - 1 && direction == BannerScrollDirectionLeft && scrollOffset < 1){
        direction = BannerScrollDirectionRight;
    }
    return direction;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(CellWidth, CellHeight);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return insetForSection;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return minimumLineSpacing;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return minimumInteritemSpacing;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PageControlCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PageControlCell cellIdentifier] forIndexPath:indexPath];
    if (indexPath.row < self.dataSource.count) {
        PageControlModel *model = self.dataSource[indexPath.row];
        [cell updateUIWithModel:model];
    }
    return cell;
}

#pragma mark - lazy load

- (NSMutableArray *)dataSource{
    if(!_dataSource){
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}

@end
