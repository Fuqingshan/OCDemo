//
//  LKAlertModel.h
//  App
//
//  Created by yier on 2019/5/16.
//  Copyright © 2019 yooli. All rights reserved.
//

#import <YYText/YYText.h>

#define tableViewDistance 75.0f///<tableview左右边距
#define labelDistance 15.0f///<YYLable左右边距
#define defaultImgHeight 60///<image的默认高度

typedef NS_ENUM(NSInteger,LKAlertCellType) {
    LKAlertCellTypeSpace = 0,///<空白
    LKAlertCellTypeTitle,///<标题
    LKAlertCellTypeImg,///<图片
    LKAlertCellTypeContent,///<详情
    LKAlertCellTypeButton,///<1个或2个button可以为一行，2个以上拆成每个一行
};

typedef NS_ENUM(NSInteger,LKAlertCellImgStyle) {
    LKAlertCellImgStyleSquare,///<中间1:1正方形，限定为默认高度
    LKAlertCellImgStyleFill,///<根据图片高度自适应
};

@interface LKAlertCellModel : NSObject<YYModel>
@property (nonatomic, assign) LKAlertCellType type;///<样式
@property (nonatomic, copy) NSString *title;///<标题
@property (nonatomic, strong) UIImage *desImg;///<描述的图片
@property (nonatomic, copy) NSString *content;///<详细描述
@property (nonatomic, strong) NSArray<NSString *> *buttons;///<按钮
@property (nonatomic, assign) CGFloat spaceHeight;///<空白高度

//UI
@property (nonatomic, strong) YYTextLayout *textLayout;///<content设置，也可以直接设置来实现content富文本点击
@property (nonatomic, assign) LKAlertCellImgStyle imgStyle;///<图片分布样式
@property (nonatomic, assign) NSTextAlignment titleAlignment;///<标题文字样式

+ (YYTextLayout *)calculateTextLayoutByAttributedString:(NSMutableAttributedString *)attContent;
@end

@interface LKAlertModel : NSObject
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

