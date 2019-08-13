//
//  SearchBarViewController.m
//  OC
//
//  Created by yier on 2019/3/14.
//  Copyright © 2019 yier. All rights reserved.
//

#import "SearchBarViewController.h"
#import "SearchBarDetailViewController.h"

@interface SearchBarViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) UITableView * tableView;
@property (strong,nonatomic) NSMutableArray  *dataList;
@property (strong,nonatomic) NSMutableArray  *searchList;

@end

@implementation SearchBarViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = @"ios8以上searchBar用法";
}

- (void)initData{
    self.dataList=[NSMutableArray arrayWithCapacity:100];
    
    for (NSInteger i=0; i<100; i++) {
        [self.dataList addObject:[NSString stringWithFormat:@"测试searchBar --- %ld",(long)i]];
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //searchTextField第一次响应时还没有输入值的时候，searchResultTableView初始化并赋值给self.searchResultTableView
    if (!self.tableView) {
        self.tableView = tableView;
        self.tableView.tableFooterView = [UIView new];
        self.tableView.backgroundColor = [UIColor clearColor];
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.searchList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    [cell.textLabel setText:self.searchList[indexPath.row]];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor orangeColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"^^^%zd",indexPath.row);
    [self performSegueWithIdentifier:@"SearchBarDetail" sender:@"搜索详情页"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"SearchBarDetail"]) {
        NSString *detailStr = sender;
        SearchBarDetailViewController *searchBarDetialVC = segue.destinationViewController;
        searchBarDetialVC.des = detailStr;
    }
}

#pragma mark - SearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"搜索Begin");
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    NSLog(@"搜索End");
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *searchString = searchText;
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchString];
    if (!self.searchList) {
        [self.searchList removeAllObjects];
    }
    //过滤数据
    self.searchList= [NSMutableArray arrayWithArray:[_dataList filteredArrayUsingPredicate:preicate]];
}

@end
