//
//  DebugViewController.m
//  OC
//
//  Created by yier on 2019/3/8.
//  Copyright © 2019 yier. All rights reserved.
//

#import "DebugViewController.h"
#import "JPFPSStatus.h"
#import "UIViewController+Debugging.h"
#import <objc/message.h>

@interface DebugViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation DebugViewController

/*
 1.watch 在第一次出现这个变量的地方打上断点，在log面板的变量上点击右键，点击watch 这个变量，执行下去的时候就会一直显示这个变量的变化
 
 2.在断点上点击右键，选择edit breakPoint，添加条件，比如100的循环里面选择i<15，忽略前面7次（times）打印，点击log message，勾选下方自动进行
 
 3.Symbolic Breakpoint Symbolic Breakpoint 是一种非常强大的断点。在 Xcode 中找到 Breakpoint navigator（你可以通过快捷键 command + 7)，在最下方点击加号，可以看到它。当然，我们也可以仅仅为特定的某个类的方法添加断点。在 Symbol 一栏输入 [ClassName viewDidLoad] (Objective-C) 或 ClassName.viewDidLoad (Swift) 即可。
 */

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"调试");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    [self getDataSource];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"调试");
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":@"fps监控"
                            ,@"sel":@"fpsMonitor"
                            }
                        ,@{
                            @"content":@"悬浮窗调试模式"
                            ,@"sel":@"DebuggingInformationOverlay"
                            }
                        ,@{
                            @"content":@"Bugly异常监控，卡顿监控"
                            ,@"sel":@"BuglySelector"
                            }
                        ,@{
                            @"content":@"查看.a文件的内容"
                            ,@"sel":@"InfoASelector"
                            }
                        ];
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

- (void)fpsMonitor{
    if (![[JPFPSStatus sharedInstance] isOpen]) {
        [[JPFPSStatus sharedInstance] open];
    }else{
        [[JPFPSStatus sharedInstance] close];
    }
}

#pragma mark - 悬浮窗调试模式
/**
 调用下方代码激活悬浮窗口调试工具，两个手指点击顶部状态栏显示出来，ios11以前的系统支持
 配合IPAPatch使用，可查看别人的ipa
 */
- (void)DebuggingInformationOverlay{
    [self showDebugger];
}

- (void)BuglySelector{
    NSLog(@"接入bugly，异常反馈");
}

- (void)InfoASelector{
    NSLog(@"查看DebugViewController的InfoASelector方法");
    /*
     一：分离arch
     1、file一下需要查看的.a文件:"file libMoxieSDK.a"，此时可以看到.a文件由哪些arch组成
     2、使用"lipo libMoxieSDK.a -thin arm64 -output v64.a"，把想看的arch文件分离出来
     
     二：抽离.a文件的object
     1、使用"ar -x v7.a"把文件抽离
     
     三：获取文件
     1、使用"nm MXBSDFPRetryManager.o > MXBSDFPRetryManager.m"获取.m文件查看
     */
}

@end
