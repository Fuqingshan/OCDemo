//
//  PageControlCell.h
//  JMPageControl
//
//  Created by yier on 2018/2/22.
//  Copyright © 2018年 yier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PageControlModel;
@interface PageControlCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *pointView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pointWC;

@property (nonatomic, strong) PageControlModel *model;

- (void)updateUIWithModel:(id)model;
+ (NSString *)cellIdentifier;
@end
