//
//  WaterfallFlowViewController.m
//  OC
//
//  Created by yier on 2019/3/19.
//  Copyright © 2019 yier. All rights reserved.
//

#import "WaterfallFlowViewController.h"
#import "JLCollectionReusableView.h"
#import "JLCollectionViewCell.h"
#import "JLWaterfallFlowLayout.h"
#import "JLViewModel.h"
#import "DataModel.h"

#define CELLBOTTOMHEIGHT 30;//item底部的高度

@interface WaterfallFlowViewController ()<JLWaterfallFlowLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) JLViewModel *viewModel;

@end

@implementation WaterfallFlowViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = @"瀑布流";
    [self configCollectionView];
}

- (void)initData{
    self.viewModel = [[JLViewModel alloc] init];
    [self.viewModel getData];
    
    [self.collectionView reloadData];
}

#pragma mark - setupUI
- (void)configCollectionView {
    JLWaterfallFlowLayout *waterfallFlowLayout = [[JLWaterfallFlowLayout alloc] init];
    waterfallFlowLayout.delegate = self;
    self.collectionView.collectionViewLayout = waterfallFlowLayout;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"JLCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"JLCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JLCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionHeader"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JLCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"sectionFooter"];
}

#pragma mark - initData


#pragma mark UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.viewModel.dataArray.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel.dataArray[section] count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JLCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JLCollectionViewCell" forIndexPath:indexPath];
    cell.bottomHeight.constant = CELLBOTTOMHEIGHT;
    id model = self.viewModel.dataArray[indexPath.section][indexPath.item];
    [cell fillCellWithModel:model indexPath:indexPath];
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        JLCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionHeader" forIndexPath:indexPath];
        headerView.titleLa.text = [NSString stringWithFormat:@"header%@", self.viewModel.nameArray[indexPath.section]];
        return headerView;
    }
    else {
        JLCollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"sectionFooter" forIndexPath:indexPath];
        footerView.titleLa.text = [NSString stringWithFormat:@"footer%@", self.viewModel.nameArray[indexPath.section]];
        return footerView;
    }
}

#pragma mark UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //在这里编写点击事件
    NSLog(@"%zi--%zi", indexPath.section, indexPath.item);
}

#pragma mark JLWaterfallFlowLayoutDelegate
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(JLWaterfallFlowLayout *)collectionViewLayout heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPath
{
    WaterfallFlowDataUnitModel *model = self.viewModel.dataArray[indexPath.section][indexPath.item];
    return model.h/model.w * width + CELLBOTTOMHEIGHT;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(JLWaterfallFlowLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.view.frame.size.width - 20, 20);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(JLWaterfallFlowLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(self.view.frame.size.width - 20, 20);
}

- (NSUInteger)columnCountInWaterFallLayout:(JLWaterfallFlowLayout *)waterFallLayout{
    return 3;
}

- (CGFloat)itemSpacingInWaterFallLayout:(JLWaterfallFlowLayout *)waterFallLayout{
    return 10;
}

- (CGFloat)lineSpacingInWaterFallLayout:(JLWaterfallFlowLayout *)waterFallLayout{
    return 10;
}

- (UIEdgeInsets)edgeInsetdInWaterFallLayout:(JLWaterfallFlowLayout *)waterFallLayout{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

@end
