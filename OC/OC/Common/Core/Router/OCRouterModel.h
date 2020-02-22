//
//  OCRouterModel.h
//  App
//
//  Created by yier on 2019/1/17.
//  Copyright © 2019 yier. All rights reserved.
//

@protocol OCRouterModel
@end
@interface OCRouterModel : NSObject<YYModel>
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *className;///<plist里面用class是因为url和desc都是一个单词,class类型本身被系统占用了😁
@property (nonatomic, copy) NSString *desc;///<router的url的描述
@end

@interface OCRouterCommonModel : NSObject<YYModel>
@property (nonatomic, strong) NSArray<OCRouterModel> *Common;

@property (nonatomic, strong) NSArray<OCRouterModel> *all;

@end

@interface OCRouterMineModel : NSObject<YYModel>
@property (nonatomic, strong) NSArray<OCRouterModel> *Mine;

@property (nonatomic, strong) NSArray<OCRouterModel> *all;

@end

@interface OCRouterPracticeModel : NSObject<YYModel>
@property (nonatomic, strong) NSArray<OCRouterModel> *Practice;
@property (nonatomic, strong) NSArray<OCRouterModel> *Setting;

@property (nonatomic, strong) NSArray<OCRouterModel> *all;

@end

@interface OCRouterAdvanceModel : NSObject<YYModel>
@property (nonatomic, strong) NSArray<OCRouterModel> *Advantage;
@property (nonatomic, strong) NSArray<OCRouterModel> *Runtime;
@property (nonatomic, strong) NSArray<OCRouterModel> *Runloop;
@property (nonatomic, strong) NSArray<OCRouterModel> *DesignMode;
@property (nonatomic, strong) NSArray<OCRouterModel> *Audio;
@property (nonatomic, strong) NSArray<OCRouterModel> *Video;
@property (nonatomic, strong) NSArray<OCRouterModel> *CoreText;

@property (nonatomic, strong) NSArray<OCRouterModel> *all;

@end

@interface OCRouterSimpleModel : NSObject<YYModel>
@property (nonatomic, strong) NSArray<OCRouterModel> *Simple;
@property (nonatomic, strong) NSArray<OCRouterModel> *QRCode;
@property (nonatomic, strong) NSArray<OCRouterModel> *Advantage;
@property (nonatomic, strong) NSArray<OCRouterModel> *Preprocessor;
@property (nonatomic, strong) NSArray<OCRouterModel> *Foundation;
@property (nonatomic, strong) NSArray<OCRouterModel> *Introduction;
@property (nonatomic, strong) NSArray<OCRouterModel> *Memory;
@property (nonatomic, strong) NSArray<OCRouterModel> *Multithread;
@property (nonatomic, strong) NSArray<OCRouterModel> *Debug;
@property (nonatomic, strong) NSArray<OCRouterModel> *Security;
@property (nonatomic, strong) NSArray<OCRouterModel> *UIControl;
@property (nonatomic, strong) NSArray<OCRouterModel> *Animation;

@property (nonatomic, strong) NSArray<OCRouterModel> *all;

@end

@interface OCRouterPlistModel: NSObject<YYModel>
@property (nonatomic, strong) OCRouterSimpleModel *Simple;
@property (nonatomic, strong) OCRouterAdvanceModel *Advance;
@property (nonatomic, strong) OCRouterPracticeModel *Practice;
@property (nonatomic, strong) OCRouterMineModel *Mine;
@property (nonatomic, strong) OCRouterCommonModel *Common;

@end
