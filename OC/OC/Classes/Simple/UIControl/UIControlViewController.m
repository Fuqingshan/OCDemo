//
//  UIControlViewController.m
//  OC
//
//  Created by yier on 2019/3/12.
//  Copyright © 2019 yier. All rights reserved.
//

#import "UIControlViewController.h"
#import <objc/message.h>

#import "UIControlHeader.h"

#import "FQS_StartView.h"
#import "UnReadBubbleView.h"
#import "CustomButton.h"
#import "WaterWaveButton.h"
#import "UICountingLabel.h"

@interface UIControlViewController ()<UITableViewDelegate,UITableViewDataSource,FQS_StartViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIControlHeader *header;

@property (nonatomic, strong) FQS_StartView *star;
@property (nonatomic, strong) UIButton *btnAdd;
@property (nonatomic, strong) UnReadBubbleView * bv;
@property (nonatomic, strong) CustomButton *customBtn;
@property (nonatomic, strong) WaterWaveButton *waterBtn;

//自增长数值
@property (nonatomic, strong) UICountingLabel* myLabel;
@property (nonatomic, strong) UICountingLabel* countPercentageLabel;
@property (nonatomic, strong) UICountingLabel* scoreLabel;
@property (nonatomic, strong) UICountingLabel* attributedLabel;

@end

@implementation UIControlViewController


- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"UI控件");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:[UIControlHeader cellReuseIdentifier] bundle:nil] forHeaderFooterViewReuseIdentifier:[UIControlHeader cellReuseIdentifier]];
}

- (void)initData{
    [self getDataSource];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"UI控件");
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":@"星级评分(open/off)"
                            ,@"sel":@"StarSelector"
                            }
                        ,@{
                            @"content":@"qq红点拖动效果"
                            ,@"sel":@"redPointBtnSelector"
                            }
                        ,@{
                            @"content":@"只能点击图片部分的按钮"
                            ,@"sel":@"onlySelectImgBtnSelector"
                            }
                        ,@{
                            @"content":@"侧滑置顶删除"
                            ,@"sel":@""
                            }
                        ,@{
                            @"content":@"tableview自适应高度"
                            ,@"url":@"sumup://simple/uicontrol/automaticdimension"
                            }
                        ,@{
                            @"content":@"剪贴板复制功能"
                            ,@"sel":@"UIPasteboardSelector"
                            }
                        ,@{
                            @"content":@"水波纹动画"
                            ,@"sel":@"WaterWaveSelector"
                            }
                        ,@{
                            @"content":@"UIActivityViewController"
                            ,@"sel":@"UIActivityViewControllerSelector"
                            }
                        ,@{
                            @"content":@"表情排版"
                            ,@"url":@"sumup://simple/uicontrol/chatemoji"
                            }
                        ,@{
                            @"content":@"金钱滚动动画"
                            ,@"sel":@"UICountingLabelSelector"
                            }
                        ,@{
                            @"content":@"PageControl和banner联动"
                            ,@"url":@"sumup://simple/uicontrol/pagecontrol"
                            }
                        ,@{
                            @"content":@"IOS8以上searchBar用法"
                            ,@"url":@"sumup://simple/uicontrol/searchbar"
                            }
                        ,@{
                            @"content":@"标签用法"
                            ,@"url":@"sumup://simple/uicontrol/tag"
                            }
                        ,@{
                            @"content":@"照片资源"
                            ,@"url":@"sumup://simple/uicontrol/photo"
                            }
                        ,@{
                            @"content":@"瀑布流"
                            ,@"url":@"sumup://simple/uicontrol/waterfallflow"
                            }
                        ].mutableCopy;
    [self.tableView reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary *dic = dictionaryInArrayAtIndex(self.dataSource, indexPath.row);
    NSString *content = stringInDictionaryForKey(dic, @"content");
    cell.textLabel.text = [NSString stringWithFormat:@"%@",content];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = dictionaryInArrayAtIndex(self.dataSource, indexPath.row);
    NSString *selStr = stringInDictionaryForKey(dic, @"sel");
    NSString *url = stringInDictionaryForKey(dic, @"url");
    if ([url isValide]) {
        [OCRouter openURL:[NSURL URLWithString:url]];
        return;
    }
    SEL sel = NSSelectorFromString(selStr);
    @try {
        ((void(*)(id,SEL))objc_msgSend)(self,sel);
        //有返回值
        //    ((NSString *(*)(id,SEL))objc_msgSend)(self,sel);
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.reason);
    } @finally {
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        return YES;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"delete");
    }
}

//2.实现tableview代理方法 ：

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath

{
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    
    UITableViewRowAction *toTop = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"置顶" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"置顶");
        NSString * temp = self.dataSource[0];
        [self.dataSource replaceObjectAtIndex:0 withObject:self.dataSource[indexPath.row]];
        [self.dataSource replaceObjectAtIndex:indexPath.row withObject:temp];
        [tableView setEditing:NO animated:YES];
        [tableView reloadData];
    }];
    
    toTop.backgroundColor =[UIColor redColor];
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"删除");
        [tableView setEditing:NO animated:YES];
    }];
    
    delete.backgroundColor =[UIColor blueColor];
    [arr addObject:toTop];
    [arr addObject:delete];
    
    return arr;
}

#pragma mark - 实现下拉header放大
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[UIControlHeader cellReuseIdentifier]];
    self.header.frame = CGRectMake(0, 0, kMainScreenWidth, [UIControlHeader cellHeight]);
    self.header.bgCH.constant = [UIControlHeader cellHeight];
    return self.header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [UIControlHeader cellHeight];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y<0) {
//        NSLog(@"%f",scrollView.contentOffset.y);
        self.header.bgCH.constant = -scrollView.contentOffset.y+[UIControlHeader cellHeight];
    }
}

#pragma mark - 星级评分
- (void)StarSelector{
    if (self.star) {
        [self.star removeFromSuperview];
        self.star = nil;
    }else{
        self.star = [[FQS_StartView alloc] initWithFrame:CGRectMake(20, 100, 150, 30) numberOfStar:5];
        [self.view addSubview:self.star];
        self.star.delegate = self;
        self.star.startChooseType = startPrecise;
        [self.star setInitScore:4.4];
        self.star.backScore = ^(float score)
        {
            NSLog(@"^^^%f",score);
        };
    }
}

- (void)FQS_StartView:(FQS_StartView *)view score:(float)score
{
    NSLog(@"%f",score);
}

- (void)redPointBtnSelector{
    if (self.btnAdd) {
        [self.bv removeFromSuperview];
        [self.btnAdd removeFromSuperview];
        self.bv = nil;
        self.btnAdd = nil;
    }else{
        self.btnAdd=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.btnAdd.frame=CGRectMake(50, 200, [UIScreen mainScreen].bounds.size.width-100, 60);
        self.btnAdd.backgroundColor = [UIColor lightGrayColor];
        [self.btnAdd setTitle:@"添加红点" forState:UIControlStateNormal];
        [self.btnAdd addTarget:self action:@selector(btnAddClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.btnAdd];
    }
}

- (void)btnAddClick{
    if ([self.btnAdd.subviews containsObject:self.bv]) {
        [self.bv removeFromSuperview];
        [self.btnAdd removeFromSuperview];
        self.bv = nil;
        self.btnAdd = nil;
        return;
    }
    NSString * num = @"312";
    
    self.bv=[[UnReadBubbleView alloc] initWithFrame:CGRectMake(self.btnAdd.bounds.size.width-35,10, 31, 31)];
    self.bv.bubbleColor = [UIColor redColor];
    self.bv.viscosity = 20;
    self.bv.bubbleLabel.text = num;
    [self.btnAdd addSubview:self.bv];
}

- (void)onlySelectImgBtnSelector{
    if (self.customBtn) {
        [self.customBtn removeFromSuperview];
        self.customBtn = nil;
    }else{
        self.customBtn = [CustomButton buttonWithType:UIButtonTypeCustom];
        self.customBtn.frame = CGRectMake(200, 200, 79, 78);
        self.customBtn.backgroundColor = [UIColor orangeColor];
        [self.customBtn setImage:[UIImage imageNamed:@"最新动态_38.png"] forState:UIControlStateNormal ];
        [self.customBtn addTarget:self action:@selector(customBtnTap) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.customBtn];
    }
}

- (void)customBtnTap{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)UIPasteboardSelector{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = @"在其他应用中粘贴";
}

- (void)WaterWaveSelector{
    if (self.waterBtn) {
        [self.waterBtn stopAnimation];
        [self.waterBtn removeFromSuperview];
        self.waterBtn = nil;
    }else{
        YYImage *img = [YYImage imageNamed:@"waterWave"];
        self.waterBtn = [[WaterWaveButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100) Image:img];
        self.waterBtn.repeatType = MaxFloatType;
        self.waterBtn.repeatNum = 10;
        [self.view addSubview:self.waterBtn];
        
        [self.waterBtn startAnimation];
        
        self.waterBtn.tapTargetBlock = ^(){
            NSLog(@"target");
        };
        
        self.waterBtn.endAnimationBlock = ^(){
            NSLog(@"end");
        };
    }
}

- (void)UIActivityViewControllerSelector{
    NSString *shareTitle = @"分享的标题";
    UIImage *shareImage = [UIImage imageNamed:@"vc_name_bg.png"];
    NSURL *shareUrl = [NSURL URLWithString:@"https://www.baidu.com"];
    NSArray *activityItems = @[shareTitle,
                               shareImage,
                               shareUrl]; // 必须要提供url 才会显示分享标签否则只显示图片
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    activityVC.excludedActivityTypes = [self excludetypes];
    
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        
        NSLog(@"activityType: %@,\ncompleted: %d,\nreturnedItems:%@,\nactivityError:%@",activityType,completed,returnedItems,activityError);
    };
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

/**
 设定不想显示的平台和功能
 */
- (NSArray *)excludetypes{
    NSMutableArray *excludeTypesM =  [NSMutableArray arrayWithArray:@[
                                                                      UIActivityTypePostToFacebook,
                                                                      UIActivityTypePostToTwitter,
                                                                      UIActivityTypePostToWeibo,
                                                                      //                                                                      UIActivityTypeMessage,
                                                                      //                                                                      UIActivityTypeCopyToPasteboard,//剪贴板
                                                                      UIActivityTypeMail,
                                                                      UIActivityTypePrint,
                                                                      UIActivityTypeAssignToContact,
                                                                      //                                                                      UIActivityTypeSaveToCameraRoll,
                                                                      UIActivityTypeAddToReadingList,
                                                                      UIActivityTypePostToFlickr,
                                                                      UIActivityTypePostToVimeo,
                                                                      UIActivityTypePostToTencentWeibo,
                                                                      UIActivityTypeAirDrop,
                                                                      UIActivityTypeOpenInIBooks
                                                                      ,@"com.apple.reminders.RemindersEditorExtension"///<事件提醒
                                                                      ,@"com.apple.mobilenotes.SharingExtension"///<记事本
                                                                      ]];
    
        if (@available(iOS 11.0, *)) {
            [excludeTypesM addObject:UIActivityTypeMarkupAsPDF];
        } else {
            // Fallback on earlier versions
        }
    
    return excludeTypesM;
}

- (void)UICountingLabelSelector{
    if (self.myLabel || self.countPercentageLabel || self.scoreLabel || self.attributedLabel) {
        [self.myLabel removeFromSuperview];
        [self.countPercentageLabel removeFromSuperview];
        [self.scoreLabel removeFromSuperview];
        [self.attributedLabel removeFromSuperview];
        self.myLabel = nil;
        self.countPercentageLabel = nil;
        self.scoreLabel = nil;
        self.attributedLabel = nil;
    }else{
        self.myLabel = [[UICountingLabel alloc] initWithFrame:CGRectMake(210, 110, 200, 40)];
        self.myLabel.method = UILabelCountingMethodLinear;
        self.myLabel.format = @"%d";
        self.myLabel.textColor = [UIColor orangeColor];
        [self.view addSubview:self.myLabel];
        [self.myLabel countFrom:1 to:10 withDuration:3.0];
        
        // make one that counts up from 5% to 10%, using ease in out (the default)
        self.countPercentageLabel = [[UICountingLabel alloc] initWithFrame:CGRectMake(210, 150, 200, 40)];
        [self.view addSubview:self.countPercentageLabel];
        self.countPercentageLabel.format = @"%.01f";
        self.countPercentageLabel.textColor = [UIColor orangeColor];
        [self.countPercentageLabel countFrom:0.5 to:9999.99 withDuration:5];
        
        // count up using a string that uses a number formatter
        self.scoreLabel = [[UICountingLabel alloc] initWithFrame:CGRectMake(210, 190, 200, 40)];
        self.scoreLabel.textColor = [UIColor orangeColor];
        [self.view addSubview:self.scoreLabel];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = kCFNumberFormatterDecimalStyle;
        self.scoreLabel.formatBlock = ^NSString* (CGFloat value)
        {
            NSString* formatted = [formatter stringFromNumber:@((int)value)];
            return [NSString stringWithFormat:@"Score: %@",formatted];
        };
        self.scoreLabel.method = UILabelCountingMethodEaseOut;
        [self.scoreLabel countFrom:0 to:10000 withDuration:2.5];
        
        // count up with attributed string
        NSInteger toValue = 100;
        self.attributedLabel = [[UICountingLabel alloc] initWithFrame:CGRectMake(200, 230, 200, 40)];
        self.attributedLabel.textColor = [UIColor orangeColor];
        [self.view addSubview:self.attributedLabel];
        self.attributedLabel.attributedFormatBlock = ^NSAttributedString* (CGFloat value)
        {
            NSDictionary* normal = @{ NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-UltraLight" size: 20] };
            NSDictionary* highlight = @{ NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue" size: 20] };
            
            NSString* prefix = [NSString stringWithFormat:@"%d", (int)value];
            NSString* postfix = [NSString stringWithFormat:@"/%d", (int)toValue];
            
            NSMutableAttributedString* prefixAttr = [[NSMutableAttributedString alloc] initWithString: prefix
                                                                                           attributes: highlight];
            NSAttributedString* postfixAttr = [[NSAttributedString alloc] initWithString: postfix
                                                                              attributes: normal];
            [prefixAttr appendAttributedString: postfixAttr];
            
            return prefixAttr;
        };
        [self.attributedLabel countFrom:0 to:toValue withDuration:2.5];
    }
}

@end
