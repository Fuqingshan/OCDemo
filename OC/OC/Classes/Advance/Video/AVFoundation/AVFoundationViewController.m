//
//  AVFoundationViewController.m
//  OC
//
//  Created by yier on 2020/2/22.
//  Copyright © 2020 yier. All rights reserved.
//

//https://www.jianshu.com/p/6ff0e380f1d3
#import "AVFoundationViewController.h"

@interface AVFoundationViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AVFoundationViewController
- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"AVFoundation");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ideCell"];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"AVFoundation");
}

#pragma mark - setupUI

#pragma mark - initData
- (void)initData{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 24;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ideCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"AVFoundationVC%zd",indexPath.row+1];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *vcName =  [NSString stringWithFormat:@"AVFoundationVC%zd",indexPath.row+1];
    Class class = NSClassFromString(vcName);
    if (!class) {
        class = NSClassFromString([NSString stringWithFormat:@"%@.%@",[[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleName"],vcName]);
    }
    if(!class){
        return;
    }
    UIViewController *vc = [[class alloc] init];
    [self.navigationController pushViewController:vc animated:YES];

}


@end
