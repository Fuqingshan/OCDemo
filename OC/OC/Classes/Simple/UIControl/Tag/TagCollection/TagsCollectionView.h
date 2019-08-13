//
//  TagsCollectionView.h
//  searchBar
//
//  Created by yier on 16/7/7.
//  Copyright © 2016年 yier. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TagsCollectionViewSelectIndex)(NSInteger index,NSString * __nullable tagName);
@interface TagsCollectionView : UIView
@property (assign, nonatomic) BOOL  scrollVertical;

@property (strong, nonatomic,nonnull) UICollectionView * tagsView;
@property (assign, nonatomic,readonly) CGRect tagsViewFrame;
@property (strong, nonatomic,readonly,nullable) NSMutableArray<NSString *> * tagsArr;

@property (copy, nonatomic,nullable) TagsCollectionViewSelectIndex selectBlock;

/**
 *  初始化collectionView
 *
 *  @param scrollVertical 设置滚动方向，默认横向,xib设置或者初始化时设置均可
 */
- (instancetype __nonnull)setUpCollectionViewByScrollVerticalEnable:(BOOL)scrollVertical frame:(CGRect)frame;


/**
 *  设置tagsView来计算
 *
 *  @param tagsArr 展示内容
 */
- (void)caculaterTagsBtnWidthWithTagsArray:(NSMutableArray<NSString *> * __nonnull)tagsArr;

/**
 *  重新设置collectionView的layout
 *
 *  @param scrollDirection     layout方向
 *  @param maximumInteritemSpacing   最大行间距,即两个cell之间的间距
 *  @param animated   animated
 *  @param completion 是否成功回调
 */
- (void)updateScrollDurationByDirection:(UICollectionViewScrollDirection)scrollDirection maximumInteritemSpacing:(CGFloat)maximumInteritemSpacing
                               animated:(BOOL)animated
                             completion:(void (^ __nullable)(BOOL finished))completion;

@end


@interface TagsCollectionView(Extension)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;

@end
