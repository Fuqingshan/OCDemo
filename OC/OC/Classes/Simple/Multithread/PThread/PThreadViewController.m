//
//  PThreadViewController.m
//  OC
//
//  Created by yier on 2021/3/18.
//  Copyright © 2021 yier. All rights reserved.
//

#import "PThreadViewController.h"
#import <objc/message.h>

@interface PThreadViewController()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;


@end

@implementation PThreadViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)setupUI{
    self.navigationItem.title = @"PThread";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    [self getDataSource];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = @"PThread";
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":@"打印当前线程"
                            ,@"sel":@"printCurrentThread"
                            }
                        ,@{
                            @"content":@"pthread"
                            ,@"sel":@"pthreadSelector"
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

- (void)printCurrentThread{
    NSLog(@"当前线程：%@", [NSThread currentThread]);
}

#pragma mark - pthread
- (void)pthreadSelector{
    //0: pthread
    
    /**
     pthread_create 创建线程
     参数：
     1. pthread_t：要创建线程的结构体指针，通常开发的时候，如果遇到 C 语言的结构体，类型后缀 `_t / Ref` 结尾
     同时不需要 `*`
     2. 线程的属性，nil(空对象 - OC 使用的) / NULL(空地址，0 C 使用的)
     3. 线程要执行的`函数地址`
     void *: 返回类型，表示指向任意对象的指针，和 OC 中的 id 类似
     (*): 函数名
     (void *): 参数类型，void *
     4. 传递给第三个参数(函数)的`参数`
     
     返回值：C 语言框架中非常常见
     int
     0          创建线程成功！成功只有一种可能
     非 0       创建线程失败的错误码，失败有多种可能！
     */
    
    // 1: pthread
    pthread_t threadId = NULL;
    //c字符串
    char *cString = "HelloCode";
//    NSString *ocString = @"Good";
    //延伸到: OC--C的混编 尤其在智能家居,SDK封装
    //抛出一个问题: 在ARC需要这样操作,在MRC不需要
    // OC prethread -- 跨平台
    // 锁
    int result = pthread_create(&threadId, NULL, pthreadTest, cString);
    if (result == 0) {
        NSLog(@"成功");
    } else {
        NSLog(@"失败");
    }
}

void *pthreadTest(void *para){
    // 接 C 语言的字符串
    //    NSLog(@"===> %@ %s", [NSThread currentThread], para);
    // __bridge 将 C 语言的类型桥接到 OC 的类型
    NSString *name = [NSString stringWithCString:para encoding:NSUTF8StringEncoding];

    NSLog(@"===>%@ %@", [NSThread currentThread], name);
        
    return NULL;
}


@end
