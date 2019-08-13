//
//  JMPageControl.h
//  JMPageControl
//
//  Created by yier on 2018/1/29.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageControlDefine.h"

@interface JMPageControl : UIView
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger currentIndex;

- (void)updateDataByCurrentIndex:(NSInteger)currentIndex totalIndex:(NSInteger)totalIndex;

/**
 计算PageControl的偏移量

 @param scrollOffset 当前banner滑动到第几个view的什么位置,count从0开始计数，(0.0 ~ 1.0) + count
 */
- (void)calculatePageControlScrollOffset:(CGFloat)scrollOffset;
@end
