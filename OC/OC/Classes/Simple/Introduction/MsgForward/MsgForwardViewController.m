//
//  MsgForwardViewController.m
//  OC
//
//  Created by yier on 2019/2/19.
//  Copyright © 2019 yier. All rights reserved.
//

#import "MsgForwardViewController.h"
#import "MsgForward.h"
#import <objc/message.h>
#import <CKYPhotoBrowser/KYPhotoBrowserController.h>

@interface MsgForwardViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation MsgForwardViewController

/*
 当继承NSObject的类找不到方法时，通常由NSObject的“doesNotRecognizeSelector”抛出异常；当一个对象无法接收某一消息时，就会启动”消息转发(message forwarding)“机制，通过这一机制，我们可以告诉对象如何处理未知的消息，但是大多数时候，我们调用前会用respondsToSelector判断一下
 消息转发的三个步骤：
 
 1、动态方法解析：Runtime 会发送 +resolveInstanceMethod: 或者 +resolveClassMethod: 尝试去 resolve 这个消息；
 
 2、备用接收者：如果 resolve 方法返回 NO，Runtime 就发送 -forwardingTargetForSelector: 允许你把这个消息转发给另一个对象；
 
 3、完整消息转发：如果没有新的目标对象返回， Runtime 就会发送-methodSignatureForSelector: 和 -forwardInvocation: 消息。你可以发送 -invokeWithTarget: 消息来手动转发消息或者发送 -doesNotRecognizeSelector: 抛出异常。
 
 type encoding:https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100
 
 注意：MsgForward.m用-w屏蔽⚠️
 
 iosu不允许继承多个类（多继承），但是可以通过分类、协议、消息转发的方式实现
 */

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = @"消息与转发";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    self.dataSource = @[
                        @{
                            @"content":@"动态解析"
                            ,@"sel":@"dynamicResolve"
                            }
                        ,@{
                            @"content":@"备用接收者"
                            ,@"sel":@"forwardTarget"
                            }
                        ,@{
                            @"content":@"完整消息转发"
                            ,@"sel":@"forwardInvocation"
                            }
                        ,@{
                            @"content":@"消息转发流程图"
                            ,@"sel":@"showImageBrower"
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
    SEL sel = NSSelectorFromString(selStr);
    ((void(*)(id,SEL))objc_msgSend)(self,sel);
    //有返回值
//    ((NSString *(*)(id,SEL))objc_msgSend)(self,sel);
}

#pragma mark - 动态解析
- (void)dynamicResolve{
    MsgForward *mf = [[MsgForward alloc] init];
    //调用实力方法
    [mf performSelector:@selector(aaa)];
    //调用类方法
    [MsgForward performSelector:@selector(classAAA)];
}

#pragma mark - 备用接收者
- (void)forwardTarget{
    MsgForward *mf = [[MsgForward alloc] init];
    //备用接受者
    [mf performSelector:@selector(BBB)];
}

#pragma mark - 完整消息转发
- (void)forwardInvocation{
    MsgForward *mf = [[MsgForward alloc] init];
    [mf performSelector:@selector(CCC)];
}

#pragma mark - 展示流程图
- (void)showImageBrower{
    [KYPhotoBrowserController showPhotoBrowserWithImages:@[[UIImage imageNamed:@"msgforward.png"]] currentImageIndex:0 delegate:nil];
}

@end
