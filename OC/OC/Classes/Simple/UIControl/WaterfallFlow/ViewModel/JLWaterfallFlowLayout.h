//
//  JLWaterfallFlowLayout.h
//  JLWaterfallFlow
//
//  Created by Jasy on 16/1/26.
//  Copyright © 2016年 Jasy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JLWaterfallFlowLayoutDelegate;
@interface JLWaterfallFlowLayout : UICollectionViewLayout
@property (nonatomic, weak) id<JLWaterfallFlowLayoutDelegate>delegate;
@end

@protocol JLWaterfallFlowLayoutDelegate <NSObject>

@required
//item heigh
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(JLWaterfallFlowLayout*)collectionViewLayout heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath*)indexPath;

@optional
/**
 * 有多少列
 */
- (NSUInteger)columnCountInWaterFallLayout:(JLWaterfallFlowLayout *)waterFallLayout ;

/**
 * item之间的间距
 */
- (CGFloat)itemSpacingInWaterFallLayout:(JLWaterfallFlowLayout *)waterFallLayout;

/**
 * 每行之间的间距
 */
- (CGFloat)lineSpacingInWaterFallLayout:(JLWaterfallFlowLayout *)waterFallLayout;

/**
 * 每个item的内边距
 */
- (UIEdgeInsets)edgeInsetdInWaterFallLayout:(JLWaterfallFlowLayout *)waterFallLayout;

//section header
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(JLWaterfallFlowLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;

//section footer
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(JLWaterfallFlowLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

@end
