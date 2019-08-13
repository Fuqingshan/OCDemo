//
//  LKActionSheet.h
//  App
//
//  Created by yier on 2018/7/25.
//  Copyright © 2018 yier. All rights reserved.
//

/*
 方法一：
 NSDictionary *dic = @{
 @"dataSource":@[
 @{@"type":@"0",@"content":@"选择添加银行卡的方式"}
 ,@{@"type":@"1",@"content":@"从网银导入",@"detail":@"90%人选择"}
 ,@{@"type":@"1",@"content":@"从邮箱导入"}
 ,@{@"type":@"2",@"content":@"取消"}]
 };
 LKActionSheetModel *actionsheetModel = [[LKActionSheetModel alloc] initWithDictionary:dic error:nil];
  [LKActionSheet new].instance(actionsheetModel).show();
 
 方法二：
 [LKActionSheet new].instanceStr(@"", @[@"删除信用卡",@"问题反馈"], @"取消").show().attributedStrs(^(NSInteger index, UILabel *contentLabel, UILabel *detailLabel) {
     if (index == 0) {
         contentLabel.textColor = LKHexColor(0xF62929);
       }
 });
 */

#import <UIKit/UIKit.h>
#import "LKActionSheetModel.h"

@interface LKActionSheet : UIView
/*
 两种初始化方法，自选其一
 instance model初始化支持后面增加一个详细的label，可以通过attributedStrs方式修改
 instanceStr string的方式初始化没有后面的详细的label，可以通过attributedStrs方式增加内容
 */
@property (nonatomic, copy) LKActionSheet * (^instance) (LKActionSheetModel *model);
@property (nonatomic, copy) LKActionSheet * (^instanceStr) (NSString *title,NSArray<NSString *> *contents,NSString *cancle);

@property (nonatomic, copy) LKActionSheet * (^show) (void);
@property (nonatomic, copy) LKActionSheet * (^dismiss) (void);

@property (nonatomic, copy) LKActionSheet * (^attributedStrs) (void (^str) (NSInteger index, UILabel *contentLabel, UILabel *detailLabel));
@property (nonatomic, copy) LKActionSheet * (^bgColors) (void (^bg) (NSInteger index, UIView *view));
/*
 index计算是按照title到cancle计算的，有就加1
 */
@property (nonatomic, copy) LKActionSheet * (^onClicked) (void (^clicked) (NSInteger index));
@end
