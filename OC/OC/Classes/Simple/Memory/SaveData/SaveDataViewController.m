//
//  SaveDataViewController.m
//  OC
//
//  Created by yier on 2019/3/7.
//  Copyright © 2019 yier. All rights reserved.
//

#import "SaveDataViewController.h"
#import <objc/message.h>

@interface SaveDataViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation SaveDataViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = @"常规数据存储";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    [self getDataSource];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = @"常规数据存储";
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":@"保存图片到桌面"
                            ,@"sel":@"SaveImgSelector"
                            }
                        ,@{
                            @"content":@"复制图片到另一个文件夹"
                            ,@"sel":@"CopyImgSelector"
                            }
                        ,@{
                            @"content":@"保存文本"
                            ,@"sel":@"SaveTextSelector"
                            }
                        ,@{
                            @"content":@"追加文本"
                            ,@"sel":@"writeToEndSelector"
                            }
                        ,@{
                            @"content":@"读取文本"
                            ,@"sel":@"readTextSelector"
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
    @try {
        ((void(*)(id,SEL))objc_msgSend)(self,sel);
        //有返回值
        //    ((NSString *(*)(id,SEL))objc_msgSend)(self,sel);
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.reason);
    } @finally {
        
    }
}

- (void)SaveImgSelector{
    NSString *path = [NSString stringWithFormat:@"/Users/yier/Desktop/OCDocument"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"SaveImgSelector --- 图片文件夹创建失败:\n%@",error);
            return;
        }
    }
    
    NSString *imgPath = [path stringByAppendingPathComponent:@"ios开发知识体系.png"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
        NSLog(@"SaveImgSelector --- 图片文件已存在");
        return;
    }
    
    NSData * imageData  = UIImageJPEGRepresentation([UIImage imageNamed:@"ios开发知识体系.png"], 1.0);
    BOOL saveImage = [[NSFileManager defaultManager] createFileAtPath:imgPath contents:imageData attributes:[NSDictionary dictionary]];
    if (saveImage) {
        NSLog(@"SaveImgSelector --- 图片保存成功");
    }else{
        NSLog(@"SaveImgSelector --- 图片保存失败");
    }
}

- (void)CopyImgSelector{
    NSString *originalPath = [NSString stringWithFormat:@"/Users/yier/Desktop/OCDocument"];
    NSString *toPath = [NSString stringWithFormat:@"/Users/yier/Desktop/CopyDocument"];
    NSString *originalImgPath = [originalPath stringByAppendingPathComponent:@"ios开发知识体系.png"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:originalImgPath]) {
        NSLog(@"CopyImgSelector --- 复制的原图片不存在");
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:toPath]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:toPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"CopyImgSelector --- 图片文件夹创建失败:\n%@",error);
            return;
        }
    }
    
    NSString *toImgPath = [toPath stringByAppendingPathComponent:@"ios开发知识体系.png"];

    if ([[NSFileManager defaultManager] fileExistsAtPath:toImgPath]) {
        NSLog(@"CopyImgSelector --- 图片文件已存在");
        return;
    }
    
    BOOL copyImage = [[NSFileManager defaultManager] copyItemAtPath:originalImgPath toPath:toImgPath error:nil];
    if (copyImage) {
        NSLog(@"CopyImgSelector --- 图片复制成功");
    }else{
        NSLog(@"CopyImgSelector --- 图片复制失败");
    }
}

- (void)SaveTextSelector{
    NSString *path = [NSString stringWithFormat:@"/Users/yier/Desktop/OCDocument"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"SaveTextSelector --- 文件夹创建失败:\n%@",error);
            return;
        }
    }
    
    NSString *saveTxtPath = [path stringByAppendingPathComponent:@"saveText.txt"];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:saveTxt]) {
//        NSLog(@"SaveTextSelector --- 文本文件已存在");
//        return;
//    }
    
    NSError *error;
    //此方法会覆盖已存在的文件，因此不用校验之前是否已存在
    [@"为天地立心，为生民立命，" writeToFile:saveTxtPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"SaveTextSelector --- 文本保存失败:%@",error);
    }else{
        NSLog(@"SaveTextSelector --- 文本保存成功");
    }
}

- (void)writeToEndSelector{
    NSString *path = [NSString stringWithFormat:@"/Users/yier/Desktop/OCDocument"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"readTextSelector --- 文件夹创建失败:\n%@",error);
            return;
        }
    }
    NSString *saveTxtPath = [path stringByAppendingPathComponent:@"saveText.txt"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:saveTxtPath]) {
        NSLog(@"readTextSelector --- 文件不存在");
        return;
    }
    NSFileHandle * txtHandle = [NSFileHandle fileHandleForUpdatingAtPath:saveTxtPath];
    [txtHandle seekToEndOfFile];//追加到末尾
    
    NSData * addData = [@"为往圣继绝学，为万世开太平" dataUsingEncoding:NSUTF8StringEncoding];
    [txtHandle writeData:addData];
    [txtHandle closeFile];
}

- (void)readTextSelector{
    NSString *path = [NSString stringWithFormat:@"/Users/yier/Desktop/OCDocument"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"readTextSelector --- 文件夹创建失败:\n%@",error);
            return;
        }
    }
    
    NSString *saveTxtPath = [path stringByAppendingPathComponent:@"saveText.txt"];
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:saveTxtPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"readTextSelector --- 文本读取失败:%@",error);
    }else{
        NSLog(@"readTextSelector --- 文本读取成功:%@",content);
    }
}

@end
