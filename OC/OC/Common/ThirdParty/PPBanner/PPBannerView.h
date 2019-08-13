//
//  PPBannerView.h
//  PengPai Layout
//
//  Created by 朱昌伟 on 15/12/27.
//  Copyright © 2015年 zhuchangwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPBannerView : UIView<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>
@property (retain, nonatomic) UICollectionView *collectionView;
@property (retain, nonatomic) NSArray *arrayData;
@end
