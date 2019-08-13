//
//  PPFlowLayout.m
//  PengPai Layout
//
//  Created by 朱昌伟 on 15/12/27.
//  Copyright © 2015年 zhuchangwei. All rights reserved.
//

#import "PPFlowLayout.h"

@implementation PPFlowLayout
{
    float _unitLength;
    NSInteger _numberOfItem;
    
}
- (id)init
{
    self = [super init];
    if (self) {
       
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    _numberOfItem = [self.collectionView numberOfItemsInSection:0];
    _unitLength = self.collectionView.frame.size.width / _numberOfItem;
    
    
}

- (CGSize)collectionViewContentSize
{
    float height = self.collectionView.frame.size.height;
    float width = self.collectionView.frame.size.width;
    return CGSizeMake(width * 2.0, height);
    
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = CGSizeMake(400, 250);
    
    CGPoint offset = self.collectionView.contentOffset;
    float width = self.collectionView.frame.size.width;
    
    NSInteger currentIndex = (offset.x +5)/_unitLength;
    
  //  NSLog(@"currnt = %d ,index.row = %d, item = %d", (int)currentIndex, (int)indexPath.row, (int)indexPath.item);
    if (currentIndex > indexPath.row) {
          attributes.center = CGPointMake(_unitLength * (indexPath.row + 0.5 + _numberOfItem), self.collectionView.frame.size.height / 2);
    }
    else
    {
         attributes.center = CGPointMake(_unitLength * (indexPath.row + 0.5), self.collectionView.frame.size.height / 2);
    }
   
    float centerX = offset.x + width/2;
    
    float distance = centerX - attributes.center.x;
    
    //NSLog(@"%.2f********%.2f****%.2f",centerX, attributes.center.x, distance);
    
    float angle = 0;
    float dis = 0;
    if (distance > _unitLength) {
        angle = M_PI/3;
    }
    else if (distance < -_unitLength)
    {
        angle = -M_PI/3;
    }
    else
    {
        angle = distance/_unitLength *M_PI/3;
        dis = 150 * (1 -ABS(distance/_unitLength));
    }
    CATransform3D tranform = CATransform3DMakeRotation(angle, 0, 1, 0);
    tranform = CATransform3DTranslate(tranform, 0, 0, dis);
    
    attributes.transform3D = [self catransform3DPerspect:tranform ponit:CGPointMake(0, 0) distance:1000];
    
    
    
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    NSInteger number = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < number; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        
        [array addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return array;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [self layoutAttributesForElementsInRect:targetRect];
   
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}
- (CATransform3D)catransform3DMakePerspective:(CGPoint)center distance:(float)dis
{
    CATransform3D transformToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1/dis;
    
    return CATransform3DConcat(CATransform3DConcat(transformToCenter, scale), transBack);
    
}

- (CATransform3D)catransform3DPerspect:(CATransform3D)transform ponit:(CGPoint)center distance:(float)dis
{
    return CATransform3DConcat(transform, [self catransform3DMakePerspective:center distance:dis]);
}
@end
