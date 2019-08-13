//
//  PPBannerView.m
//  PengPai Layout
//
//  Created by 朱昌伟 on 15/12/27.
//  Copyright © 2015年 zhuchangwei. All rights reserved.
//

#import "PPBannerView.h"
#import "PPHeadCell.h"
#import "PPFlowLayout.h"
#import "UIImage+Test.h"
#import <Masonry/Masonry.h>

@implementation PPBannerView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self createCollectionView];
}
- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createCollectionView];
    }
    return self;
}

- (void)createCollectionView
{
    _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:[[PPFlowLayout alloc]init]];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self addSubview:_collectionView];
    
    
    UINib *nib = [UINib nibWithNibName:@"PPHeadCell" bundle:[NSBundle bundleForClass:[PPHeadCell class]]];
    [_collectionView registerNib:nib forCellWithReuseIdentifier:@"cell"];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.center.mas_equalTo(self);
        make.height.mas_equalTo(self);
        make.width.mas_equalTo(self);
    }];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PPHeadCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"00%d.jpg", (int)indexPath.row + 1]];
    cell.backImage.image = [image antiAlias];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float width = _collectionView.frame.size.width;
    
    NSInteger number = [_collectionView numberOfItemsInSection:0];
    float unitLength = width /number;
    
    float offsetX = scrollView.contentOffset.x;
    if (offsetX < unitLength/2) {
        scrollView.contentOffset = CGPointMake(width + offsetX, 0);
    }
    else if (offsetX > width + unitLength / 2)
    {
         scrollView.contentOffset = CGPointMake(unitLength/2, 0);
    }
}

@end
