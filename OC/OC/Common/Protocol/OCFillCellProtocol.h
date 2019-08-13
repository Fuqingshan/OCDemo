//
//  OCFillCellProtocol.h
//  App
//
//  Created by yier on 2018/5/15.
//  Copyright © 2018年 yier. All rights reserved.
//

#ifndef OCFillCellProtocol_h
#define OCFillCellProtocol_h

@protocol OCFillCellProtocol <NSObject>

@required
+ (NSString *)cellReuseIdentifier;

@optional
- (void)fillCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath;

+ (CGFloat)cellHeight;

+ (CGFloat)cellHeightWithModel:(id)model;

@end



@protocol OCFillViewProtocol <NSObject>

@optional

- (void)fillViewWithModel:(id)model;

@end

#endif /* LKFillCellProtocol_h */
