//
//  PagingCollectionViewLayout.h
//  https://github.com/shengpeng3344/PagingCollectionView
//
//  Created by tangmi on 16/6/9.
//  Copyright © 2016年 tangmi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagingCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, assign) CGFloat minimumLineSpacing; //行间距

@property (nonatomic, assign) CGFloat minimumInteritemSpacing; //item间距

@property (nonatomic, assign) CGSize itemSize; //item大小

@property (nonatomic, assign) UIEdgeInsets sectionInset;

@property (nonatomic, assign) CGSize collectionViewSize;///<从外部传入，这儿10.3.1取得是xib默认的320

@end
