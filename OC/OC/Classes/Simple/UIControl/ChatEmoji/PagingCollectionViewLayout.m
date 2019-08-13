//
//  PagingCollectionViewLayout.m
//  https://github.com/shengpeng3344/PagingCollectionView
//
//  Created by tangmi on 16/6/9.
//  Copyright © 2016年 tangmi. All rights reserved.
//

#import "PagingCollectionViewLayout.h"

@interface PagingCollectionViewLayout()
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) NSInteger pageNumber;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger line;
@end

@implementation PagingCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.itemSpacing = 10;
        self.lineSpacing = 10;
        self.pageNumber = 1;
        self.row = 0;
        self.line = 0;
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    CGFloat itemWidth = self.itemSize.width;
    CGFloat itemHeight = self.itemSize.height;
    
    CGFloat width = self.collectionViewSize.width;
    CGFloat height = self.collectionViewSize.height;
    
    CGFloat contentWidth = (width - self.sectionInset.left - self.sectionInset.right);
    if ( (2 * itemWidth + self.minimumInteritemSpacing) <= contentWidth) { //如果列数大于2行
        NSInteger m = (contentWidth-itemWidth)/(itemWidth+self.minimumInteritemSpacing);
        self.line = m+1;
        NSInteger n = (NSInteger)(contentWidth-itemWidth)%(NSInteger)(itemWidth+self.minimumInteritemSpacing);
        if (n > 0) {
            CGFloat offset = ((contentWidth-itemWidth) - m*(itemWidth+self.minimumInteritemSpacing))/m;
            self.itemSpacing = self.minimumInteritemSpacing + offset;
        }else if (n == 0){
            self.itemSpacing = self.minimumInteritemSpacing;
        }
    }else{ //如果列数为一行
       self.itemSpacing = 0;
    }
    
    CGFloat contentHeight = (height - self.sectionInset.top - self.sectionInset.bottom);
    if ((2*itemHeight+self.minimumLineSpacing) <= contentHeight) { //如果行数大于2行
        NSInteger m = (contentHeight-itemHeight)/(itemHeight+self.minimumLineSpacing);
        self.row = m+1;
        NSInteger n = (NSInteger)(contentHeight-itemHeight)%(NSInteger)(itemHeight+self.minimumLineSpacing);
        if (n > 0) {
            CGFloat offset = ((contentHeight-itemHeight) - m*(itemHeight+self.minimumLineSpacing))/m;
            self.lineSpacing = self.minimumLineSpacing + offset;
        }else if (n == 0){
            self.lineSpacing = self.minimumInteritemSpacing;
        }
    }else{ //如果行数数为一行
        self.lineSpacing = 0;
    }
    
    self.row = MAX(self.row, 1);
    self.line = MAX(self.line, 1);

    NSInteger itemNumber =  [self.collectionView numberOfItemsInSection:0];
    self.pageNumber = (itemNumber - 1)/(self.row * self.line) + 1;
}

- (CGPoint)targetContentOffsetForProposedContentOffset: (CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity //自动对齐到网格
{
    //proposedContentOffset是没有对齐到网格时本来应该停下的位置
    CGFloat offsetY = MAXFLOAT;
    CGFloat offsetX = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + self.itemSize.width/2;
    CGFloat verticalCenter = proposedContentOffset.y + self.itemSize.height/2;
    CGRect targetRect = CGRectMake(0, 0.0, self.collectionViewSize.width, self.collectionViewSize.height);
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
    
    //对当前屏幕中的UICollectionViewLayoutAttributes逐个与屏幕中心进行比较，找出最接近中心的一个
    CGPoint offPoint = proposedContentOffset;
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        CGFloat itemVerticalCenter = layoutAttributes.center.y;
        if (ABS(itemHorizontalCenter - horizontalCenter) && (ABS(offsetX)>ABS(itemHorizontalCenter - horizontalCenter))) {
            offsetX = itemHorizontalCenter - horizontalCenter;
            offPoint = CGPointMake(itemHorizontalCenter, itemVerticalCenter);
        }
        if (ABS(itemVerticalCenter - verticalCenter) && (ABS(offsetY)>ABS(itemVerticalCenter - verticalCenter))) {
            offsetY = itemHorizontalCenter - horizontalCenter;
            offPoint = CGPointMake(itemHorizontalCenter, itemVerticalCenter);
        }
    }
    return offPoint;
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.collectionViewSize.width * self.pageNumber, self.collectionViewSize.height);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

    CGRect frame;
    frame.size = self.itemSize;
    //下面计算每个cell的frame   可以自己定义
    NSInteger number = self.row * self.line;
    CGFloat m = 0;  //初始化 m p
    CGFloat p = 0;
    if (indexPath.item >= number) {
        p = indexPath.item/number;  //计算页数不同时的左间距
        m = (indexPath.item%number)/self.line;
    }else{
        m = indexPath.item/self.line;
    }
    
    CGFloat n = indexPath.item%self.line;
    frame.origin = CGPointMake( n * self.itemSize.width + n * self.itemSpacing + self.sectionInset.left+(indexPath.section+p)*self.collectionViewSize.width,m*self.itemSize.height + m * self.lineSpacing+self.sectionInset.top);
    attribute.frame = frame;
    return attribute;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{

    NSMutableArray *tmpAttributes = [NSMutableArray new];
    for (NSInteger j = 0; j < self.collectionView.numberOfSections; j ++)
    {
        NSInteger count = [self.collectionView numberOfItemsInSection:j];
        for (NSInteger i = 0; i < count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:j];
            [tmpAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
    return tmpAttributes;
}

- (BOOL)shouldinvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return NO;
}
@end
