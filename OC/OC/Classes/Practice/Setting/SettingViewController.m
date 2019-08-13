//
//  SettingViewController.m
//  OC
//
//  Created by yier on 2019/2/14.
//  Copyright © 2019 yier. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingLanguageCell.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation SettingViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    [self configBackBtn];
    self.navigationItem.title = LocalizedString(@"设置");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerNib:[UINib nibWithNibName:[SettingLanguageCell cellReuseIdentifier] bundle:nil] forCellReuseIdentifier:[SettingLanguageCell cellReuseIdentifier]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)configBackBtn{
    self.backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 32)];
    [self.backBtn setTitle:LocalizedString(@"返回") forState:UIControlStateNormal];
    [self.backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backEvent) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)backEvent{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initData{

}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"设置");
    [self.backBtn setTitle:LocalizedString(@"返回") forState:UIControlStateNormal];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = stringInArrayAtIndex(self.dataSource, indexPath.row);
    if ([identifier isEqualToString:[SettingLanguageCell cellReuseIdentifier]]) {
        return [SettingLanguageCell cellHeight];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = stringInArrayAtIndex(self.dataSource, indexPath.row);
    if ([identifier isEqualToString:[SettingLanguageCell cellReuseIdentifier]]) {
        SettingLanguageCell *cell = [tableView dequeueReusableCellWithIdentifier:[SettingLanguageCell cellReuseIdentifier] forIndexPath:indexPath];
        [cell fillCellWithModel:nil indexPath:indexPath];
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
        
        return cell;
    }
}

#pragma mark - lazy load
- (NSArray *)dataSource{
    if(!_dataSource){
        _dataSource = @[
                        [SettingLanguageCell cellReuseIdentifier]
                        ];
    }
    return _dataSource;
}

@end
