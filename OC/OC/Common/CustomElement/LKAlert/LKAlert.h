//
//  LKAlert.h
//  App
//
//  Created by yier on 2019/5/15.
//  Copyright © 2019 yooli. All rights reserved.
//

/*
 方法一（快速创建）：
 [LKAlert initWithTitle:@"" image:[UIImage imageNamed:@"icons_diahuan"] message:@"真的要放弃吗？" buttons:@[@"放弃",@"继续提交"] buttonBlock:^(NSInteger index) {
 if (index == 0) {
 NSLog(@"返回");
 }else{
 NSLog(@"我知道了");
 }
 }];
 
 方法二（自定义，支持富文本）：
 NSMutableAttributedString *attContent = [[NSMutableAttributedString alloc] initWithString:@"你好，"];
 attContent.yy_font = PingFangSCRegular(15.0f);
 attContent.yy_color = LKHexColor(0xB2000000);
 attContent.yy_alignment = NSTextAlignmentCenter;
 
 NSMutableAttributedString *tapContent = [[NSMutableAttributedString alloc] initWithString:@"老师"];
 tapContent.yy_font = PingFangSCMedium(18.0f);
 [tapContent yy_setTextHighlightRange:NSMakeRange(0, tapContent.string.length) color:LKHexColor(0xFE4070) backgroundColor:LKHexColor(0xEEEEEE) tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
 NSLog(@"老师点击：\n%@ \n%@ \n%@ \n%@",containerView,text,NSStringFromRange(range),NSStringFromCGRect(rect));
 }];
 
 NSMutableAttributedString *endContent = [[NSMutableAttributedString alloc] initWithString:@"。中信修复后，同一张卡通过网银怕寻后的card_id还是和"];
 endContent.yy_font = PingFangSCRegular(15.0f);
 endContent.yy_color = LKHexColor(0xB2000000);
 
 [attContent appendAttributedString:tapContent];
 [attContent appendAttributedString:endContent];
 
 YYTextLayout *textLayout = [LKAlertCellModel calculateTextLayoutByAttributedString:attContent];
 
 [LKAlert initFromNib].title(@"提示")
 .image([UIImage imageNamed:@"icons_diahuan"]).message(textLayout).buttons(@[@"取消",@"确定",@"老师介绍"]).show().buttonConfig(^(UIButton *btn) {
 if ([btn.titleLabel.text isEqualToString:@"取消"]) {
 [btn setTitleColor:LKHexColor(0x999999) forState:UIControlStateNormal];
 }else if ([btn.titleLabel.text isEqualToString:@"老师介绍"]){
 [btn setTitleColor:LKHexColor(0xFE4070) forState:UIControlStateNormal];
 }
 }).onClick(^(NSInteger index) {
 if (index == 1) {
 NSLog(@"确定");
 }else if(index == 2){
 NSLog(@"魔蝎老师介绍");
 }
 });
 */

#import <UIKit/UIKit.h>
#import "LKAlertModel.h"

@interface LKAlert : UIWindow

@property (nonatomic, copy) LKAlert *(^space) (CGFloat height);
@property (nonatomic, copy) LKAlert *(^title) (NSString *title);
@property (nonatomic, copy) LKAlert *(^titleModifyAlignment) (NSString *title,NSTextAlignment titleAlignment);
@property (nonatomic, copy) LKAlert *(^image) (UIImage *img);
@property (nonatomic, copy) LKAlert *(^imageModifyStyle) (UIImage *img,LKAlertCellImgStyle style);
@property (nonatomic, copy) LKAlert *(^message) (id msg);///<支持NSString和YYTextLayout，YYTextLayout由[LKAlertCellModel calculateTextLayoutByAttributedString:attContent]生成
@property (nonatomic, copy) LKAlert *(^buttons) (NSArray<NSString *>*buttons);///<按钮顺序，从左到右，从上到下
@property (nonatomic, copy) LKAlert *(^horizontalButtons) (NSArray<NSString *>*horizontalButtons);///<按钮顺序，从上到下

@property (nonatomic, copy) LKAlert *(^show) (void);

@property (nonatomic, copy) LKAlert *(^buttonConfig) (void (^buttonConfigBlock) (UIButton *btn));///<show之后设置按钮颜色等
@property (nonatomic, copy) LKAlert *(^onClick) (void (^clicked) (NSInteger index));///<buttons数组的顺序

@property (nonatomic, copy) LKAlert *(^close) (void);///<close按钮
@property (nonatomic, copy) LKAlert *(^onCloseClick) (dispatch_block_t closeClick);///<close按钮点击

@property (nonatomic, copy) LKAlert *(^dismiss) (void);

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 初始化方法

 @return LKAlert
 */
+ (instancetype)initFromNib;

/**
 快速创建方式

 @param title 标题，传nil或""不显示
 @param img 图片，传nil不显示，默认高度为60，展示logo
 @param message 内容，传nil或""不显示
 @param buttons 默认第0个按钮为灰色，最好用来设置只有2个按钮的情况
 @param buttonBlock 点击按钮的block
 @return LKAlert
 */
+ (instancetype)initWithTitle:(NSString *)title
                       image:(UIImage *)img
                      message:(NSString *)message
                      buttons:(NSArray *)buttons
                      buttonBlock:(void (^)(NSInteger index))buttonBlock;
@end

