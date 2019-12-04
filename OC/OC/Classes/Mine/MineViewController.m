//
//  MineViewController.m
//  OC
//
//  Created by yier on 2019/3/19.
//  Copyright © 2019 yier. All rights reserved.
//

#import "MineViewController.h"

@interface MineViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation MineViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.photo.layer.cornerRadius = 35.0f;
    self.photo.layer.masksToBounds = YES;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    self.dataSource = @[
                        @"我的收藏"
                        ,@"我的相册"
                        ,@"我的文件"
                        ,@"系统字体"
                        ,@"约束优先级"
                        ,@"响应链"
                        ];
    [self.tableView reloadData];
}

- (void)changeLanguageEvent{
    self.background.image = [UIImage imageNamed:@"mineBG.png"];
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
    NSString *content = stringInArrayAtIndex(self.dataSource, indexPath.row);
    cell.textLabel.text = [NSString stringWithFormat:@"%@",content];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[OCRouter shareInstance].rootViewController hiddenMine];
    NSString *title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    if ([title isEqualToString:@"系统字体"]) {
        [OCRouter openURL:[NSURL URLWithString:@"sumup://mine/font"]];
    }else if ([title isEqualToString:@"约束优先级"]){
        [OCRouter openURL:[NSURL URLWithString:@"sumup://mine/constraintpriority"]];
    }else if ([title isEqualToString:@"响应链"]){
        [OCRouter openURL:[NSURL URLWithString:@"sumup://mine/hittest"]];
    }
}

@end
