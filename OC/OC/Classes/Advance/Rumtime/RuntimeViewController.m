//
//  RuntimeViewController.m
//  OC
//
//  Created by yier on 2019/4/7.
//  Copyright © 2019 yier. All rights reserved.
//

#import "RuntimeViewController.h"
#import "Person.h"
#import "Person+addProperty.h"
#import "Student.h"

#import <objc/runtime.h>
#import <objc/message.h>

@interface RuntimeViewController ()<personDelegate,NSCoding,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic,strong) Person *student;

@end

@implementation RuntimeViewController

- (void)dealloc{
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

#pragma mark - setupUI
- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"Runloop");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

#pragma mark - initData
- (void)initData{
/*
 runtime是一套底层的C语言API，包含很多强大实用的C语言数据类型和C语言函数，平时我们编写的OC代码，底层都是基于runtime实现的。
 */
    self.student = [[Person alloc] init];
    [self getDataSource];
}


- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":@"获取类的全部成员变量"
                            ,@"sel":@"function1"
                            }
                        ,@{
                            @"content":@"获取类的全部属性名"
                            ,@"sel":@"function2"
                            }
                        ,@{
                            @"content":@"获取类的全部方法"
                            ,@"sel":@"function3"
                            }
                        ,@{
                            @"content":@"获取类的遵循的全部协议"
                            ,@"sel":@"function4"
                            }
                        ,@{
                            @"content":@"动态改变成员变量"
                            ,@"sel":@"function5"
                            }
                        ,@{
                            @"content":@"动态交换类2个方法"
                            ,@"sel":@"function6"
                            }
                        ,@{
                            @"content":@"动态添加方法"
                            ,@"sel":@"function7"
                            }
                        ,@{
                            @"content":@"动态为category扩展添加属性"
                            ,@"sel":@"function8"
                            }
                        ,@{
                            @"content":@"更便捷的归档/解档"
                            ,@"sel":@"function9"
                            }
                        ,@{
                            @"content":@"动态调用类里的方法"
                            ,@"sel":@"function10"
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


-(void)personPayForFun:(NSInteger)money
{
    NSLog(@"Have fun!");
}

#pragma mark - 获取类的全部成员变量
- (void)function1 {
    unsigned int count;
    
    //获取成员变量的数组的指针
    Ivar *ivars = class_copyIvarList([Person class], &count);
    
    for (int i=0 ; i<count; i++) {
        Ivar ivar = ivars[i];
        //根据ivar获得其成员变量的名称
        const char *name = ivar_getName(ivar);
        //C的字符串转OC的字符串
        NSString *key = [NSString stringWithUTF8String:name];
        NSLog(@"%d == %@",i,key);
    }
    // 记得释放
    free(ivars);
    
    //如果你的成员私有,也可以获取到 比如_education
}

#pragma mark - 获取类的全部属性名
- (void)function2 {
    unsigned int count;
    
    //获得指向该类所有属性的指针
    objc_property_t *properties = class_copyPropertyList([Person class], &count);
    
    for (int i=0 ; i<count; i++) {
        //获得该类的一个属性的指针
        objc_property_t property = properties[i];
        //获取属性的名称
        const char *name = property_getName(property);
        //将C的字符串转为OC字符串
        NSString *key = [NSString stringWithUTF8String:name];
        
        NSLog(@"%d == %@",i,key);
    }
    // 记得释放
    free(properties);
}

#pragma mark - 获取类的全部方法
- (void)function3 {
    unsigned int count;
    
    //获取指向该类的所有方法的数组指针
    Method *methods = class_copyMethodList([Person class], &count);
    
    for (int i = 0; i < count; i++) {
        //获取该类的一个方法的指针
        Method method = methods[i];
        //获取方法
        SEL methodSEL = method_getName(method);
        //将方法转换为C字符串
        const char *name = sel_getName(methodSEL);
        //将C字符串转为OC字符串
        NSString *methodName = [NSString stringWithUTF8String:name];
        
        //获取方法参数个数
        int arguments = method_getNumberOfArguments(method);
        
        NSLog(@"%d == %@ %d",i,methodName,arguments);
    }
    //记得释放
    free(methods);
    
}

#pragma mark - 获取类遵循的全部协议
- (void)function4 {
    unsigned int count;
    
    //获取指向该类遵循的所有协议的数组指针
    __unsafe_unretained Protocol **protocols = class_copyProtocolList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        //获取该类遵循的一个协议指针
        Protocol *protocol = protocols[i];
        //获取C字符串协议名
        const char *name = protocol_getName(protocol);
        //C字符串转OC字符串
        NSString *protocolName = [NSString stringWithUTF8String:name];
        NSLog(@"%d == %@",i,protocolName);
    }
    //记得释放
    free(protocols);
}

#pragma mark - 动态改变成员变量
- (void)function5 {
    self.student.name = @"张三";
    
    unsigned int count = 0;
    Ivar *ivar = class_copyIvarList([self.student class], &count);
    for (int i = 0; i<count; i++) {
        Ivar var = ivar[i];
        const char *varName = ivar_getName(var);
        NSString *name = [NSString stringWithUTF8String:varName];
        
        if ([name isEqualToString:@"_name"]) {
            object_setIvar(self.student, var, @"李四");
            break;
        }
    }
    free(ivar);
    
    // 结果变成了 李四
    NSLog(@"student name %@",self.student.name);
    
}

#pragma mark - 动态交换类两个方法
- (void)function6 {
    
    Method m1 = class_getInstanceMethod([Person class], @selector(doSomeThing));
    Method m2 = class_getInstanceMethod([Person class], @selector(doSomeOtherThing));
    
    method_exchangeImplementations(m1, m2);
    
    // 发现两个方交换了
    NSLog(@"student do something:%@",[self.student doSomeThing]);
    NSLog(@"student do doSomeOtherThing:%@",[self.student doSomeOtherThing]);
    
    // 运行时修改的是类，不是单一对象 一次修改 在下次编译前一直有效。
    Person *student2 = [Person new];
    NSLog(@"student do something:%@",[student2 doSomeThing]);
    NSLog(@"student do doSomeOtherThing:%@",[student2 doSomeOtherThing]);
    
    
    // 也可以在类目中添加自己方法去替换 类 或者系统类的方法
    
    [self.student sleep];
    
}

#pragma mark - 动态添加方法
- (void)function7 {
    
    /*
     *方法一：
     */
    //    class_addMethod([self.student class], @selector(fromCity:), (IMP)fromCityAnswer, "v@:@");
    //    if ([self.student respondsToSelector:@selector(fromCity:)]) {
    //        Method method = class_getInstanceMethod([self.xiaoMing class], @selector(guess));
    //        [self.student performSelector:@selector(fromCity:) withObject:@"广州"];
    //
    //    } else{
    //        NSLog(@"无法告诉你我从哪儿来");
    //    }
    
    ///方法二:
    [self autoAddMethod];
}

- (void)autoAddMethod{
    Class cls = objc_getClass("Student");
    SEL sel = sel_registerName("autoAddMethod");
    //    if ([cls resolveInstanceMethod:sel]) {
    Method method = class_getInstanceMethod(cls, sel);
    IMP imp = method_getImplementation(method);
    void(*func)(id,SEL) = (void(*)(id,SEL))imp;
    func(objc_getMetaClass("Student"),sel);
    //2:        ((void(*)(id,SEL))objc_msgSend)(cls,sel);
    
    //    }
    
    float a[] = {1.0, 2.0, 3.0};
    NSLog(@"array encoding type: %s", @encode(typeof(a)));
    
    const char *strNum = [[NSNumber valueWithCGSize:CGSizeMake(100, 100)] objCType];
    if (strcmp(strNum, @encode(CGSize)) == 0) {
        NSLog(@"cgsize:%s",@encode(CGSize));
    }
}


void fromCityAnswer(id self,SEL _cmd,NSString *str){
    
    NSLog(@"我来自:%@",str);
}

#pragma mark - 动态为category扩展添加属性
- (void)function8 {
    /*
     Category提供了一种比继承（inheritance）更为简洁的方法来对class进行扩展，无需创建对象类的子类就能为现有的类添加新方法，可以为任何已经存在的class添加方法，包括那些没有源代码的类（如某些框架类）。
     类别的局限性
     (1)无法向类中添加新的实例变量，类别没有位置容纳实例变量。
     (2)名称冲突，即当类别中的方法与原始类方法名称冲突时，类别具有更高的优先级。类别方法将完全取代初始方法从而无法再使用初始方法。
     */
    
    // 通过runtime 可以让category添加属性
    
    self.student.englishName = @"xiaoMu Wang";
    NSLog(@"Student English name is %@",self.student.englishName);
    
}

#pragma mark - 更便捷的归档/解档
- (void)function9 {
    Person *person = [[Person alloc] init];
    person.name = @"小木—boy";
    person.sex = @"男";
    person.age = 25;
    person.height = 180;
    person.job = @"iOS工程师";
    person.native = @"北京";
    person.photoData = UIImageJPEGRepresentation( [UIImage imageNamed:@"003.jpg"], 0.5);
    
    [person saveModel];
    
    Person *unarchiverPerson = [Person getModel];
    
    NSLog(@"unarchiverPerson == %@ \n ",unarchiverPerson);
        
    Student * student = [[Student alloc] init];
    student.age=  1;
    student.name = @"huoche";
    student.height = 111;
    [student saveModel];
    
    Student *unarchiverStudent = [Student getModel];
    
    NSLog(@"unarchiverStudent == %@",unarchiverStudent);
    
    
}

#pragma mark -  动态调用类里的方法
- (void)function10 {
    Class class = NSClassFromString(@"RuntimeViewController");
    id viewController = [[class alloc] init];
    SEL selector = NSSelectorFromString(@"test:");
    if ([viewController respondsToSelector:selector]) {
        [viewController performSelector:selector withObject:@"aaaa" afterDelay:0.5];
    }
}

- (void)test:(NSString *)a
{
    NSLog(@"dsadsa:%p",@"😢");
}

@end
