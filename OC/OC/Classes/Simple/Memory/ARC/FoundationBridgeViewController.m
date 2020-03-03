//
//  FoundationBridgeViewController.m
//  OC
//
//  Created by yier on 2019/2/25.
//  Copyright © 2019 yier. All rights reserved.
//

#import "FoundationBridgeViewController.h"
#import <objc/message.h>

@interface FoundationBridgeViewController()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSMutableSet *set;
@property (nonatomic, strong) NSString *a;
@end

@implementation FoundationBridgeViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"直接桥接");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    self.dataSource = @[
                        @{
                            @"content":@"隐式转换"
                            ,@"sel":@"implicitConversion"
                            }
                        ,@{
                            @"content":@"显示转换"
                            ,@"sel":@"explicitConversion"
                            }
                        ];
    [self.tableView reloadData];
    [self NSSet];
    /*忽略performSelectory警告
    
     #pragma clang diagnostic push
     #pragma clang diagnostic ignored "-相关命令"
     // 你自己的代码
     #pragma clang diagnostic pop
     
     
     相关命令：
     -Wunused-variable（未使用变量）
     -Wdeprecated-declarations（方法弃用警告）
     -Wincompatible-pointer-types（不兼容指针类型）
     -Warc-retain-cycles（循环引用）
     -Warc-performSelector-leaks（内存泄漏警告）
     */
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


- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"直接桥接");
}

#pragma mark - NSSet
/*
 使用集合类实例时会出现释放所有者的情况。当集合类实例添加对象时，对象会retain一次，被释放时,ARC会自动向该集合中的每个对象发送一条 release消息。
 */
- (void)NSSet{
    self.a = @"321321321";
    self.set = [[NSMutableSet alloc] init];
    [self.set addObject:self.a];
    NSLog(@"%@  %@",self.set,self.a);
    self.a = nil;
    NSLog(@"%@  %@",self.set,self.a);
}

#pragma mark - 隐式转换
/*
 类方法[ NSArray arraywithobject:]接收类型为id的参数( Objective-CI对象指针),但是在传
 送时被作为CFStringRef类型的数据。因为 CFStringRef是一种直接桥接数据类型,所以参数cstr
 会被隐式转换为NSString对象,这儿为了避免编译器发出警告,该参数被转换了
 */
- (void)implicitConversion{
    CFStringRef cstr = CFStringCreateWithCString(NULL,"Hello, World!",
                                                kCFStringEncodingASCII);
    NSArray*data = [NSArray arrayWithObject: CFBridgingRelease(cstr)];
    NSLog(@"%@",[[data firstObject] class]);
}

#pragma mark - 显示转换
/*
 桥接方式介绍：
 在使用ARC时,通过ARC桥接转换可以使用直接桥接数据类型。这些操作必须将特殊标记
 __bridge、__bridge_retained和 __bridge_transfer用作前缀。
 
 使用__bridge标记可以在不改变所有权的情况下,将对象从 Core Foundation框架数据类型
 转换为 Foundation框架数据类型(反之亦然)。换言之,如果你以动态方式创建了一个
 Foundation框架对象,然后(通过直接桥接)将它的数据类型转换为 Core Foundation框架
 数据类型,那么通过 bridge标记可以使编译器知道这个对象的生命周期仍旧由ARC管
 理。反过来,如果你创建了一个 Core Foundation框架数据类型的对象,然后将它的数据类
 型转化为 Foundation框架的数据类型,那么通过__bridge标记可以告诉编译器这个对象的
 生命周期仍旧是以手动方式管理的(不是使用ARC管理的)。注意,使用该标记可以使编
 译器不报错,但是不会改变对象的所有权,因此在使用它解决内存泄漏和悬挂指针问题
 时应多加小心。
 
 使用__bridge_retained标记可以将 Foundation框架数据类型对象转换为 Core foundation框
 架数据类型对象,并从ARC接管对象的所有权。这样你就可以手动管理直接桥接数据的生命周期。
 
 使用__bridge_transfer标记可以将 Core Foundation框架数据类型对象转换为 Foundation框
 架数据类型对象,并且会将对象的所有权交给ARC管理。这样就会由ACR管理对象的生
 命周期。
 */

/**
 __bridge_transfer 位于桥接对象之前，这样cstr的所有权会交给ARC
 */
- (void)explicitConversion{
    CFStringRef cstr = CFStringCreateWithCString(NULL, " Hello, World! ", kCFStringEncodingASCII);
    NSArray *data = [NSArray arrayWithObject:(__bridge_transfer NSString * )cstr];
    NSLog(@"%@",[[data firstObject] class]);
}

@end
