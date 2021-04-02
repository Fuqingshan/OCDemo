//
//  LKActionSheetModel.h
//  App
//
//  Created by yier on 2018/7/25.
//  Copyright © 2018 yier. All rights reserved.
//


typedef NS_ENUM(NSInteger, LKActionSheetType) {
    LKActionSheetTypeTitle,///<titleCell
    LKActionSheetTypeContent,///<中间的cell
    LKActionSheetTypeCancle,///<取消cell
};


@interface LKActionSheetContentModel: NSObject<YYModel>
@property (nonatomic, assign) LKActionSheetType type;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *detail;

@end

@interface LKActionSheetModel : NSObject<YYModel>
@property (nonatomic, strong) NSArray *dataSource;///<除开title和cancle按钮的其他按钮的标题
@end
