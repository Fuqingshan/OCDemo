//
//  SystemFontViewController.m
//  OC
//
//  Created by yier on 2019/4/2.
//  Copyright © 2019 yier. All rights reserved.
//

#import "SystemFontViewController.h"

@interface SystemFontViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *fontFamilyArray;
@property (nonatomic, strong) NSMutableArray *fontArray;
@end

@implementation SystemFontViewController

- (void)dealloc{
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

#pragma mark - setupUI
- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"系统字体");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

#pragma mark - initData
- (void)initData{
    _fontFamilyArray = [UIFont familyNames];
    _fontArray = [NSMutableArray array];
    for (NSString* familyName in _fontFamilyArray) {
        NSArray *fontArray = [UIFont fontNamesForFamilyName:familyName];
        [_fontArray addObject:fontArray];
    }
    [self.tableView reloadData];
}

#pragma mark - tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _fontArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* fontArr = [_fontArray objectAtIndex:section];
    return fontArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSString* fontName = [[_fontArray objectAtIndex:section] objectAtIndex:row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = @"系统字体展示ABCDefgh";
    cell.textLabel.font = [UIFont fontWithName:fontName size:15];
    NSString* fontFamilyName = [_fontFamilyArray objectAtIndex:section];
    fontFamilyName = [fontFamilyName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([fontFamilyName isEqualToString:@"Bodoni72Oldstyle"]) {
        fontFamilyName = @"BodoniSvtyTwoOSITCTT";
    }
    NSString* fontDetail = [fontName stringByReplacingOccurrencesOfString:fontFamilyName withString:@""];
    fontDetail = [fontDetail stringByReplacingOccurrencesOfString:@"-" withString:@""];
    cell.detailTextLabel.text = fontDetail;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_fontFamilyArray objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSString* fontName = [[_fontArray objectAtIndex:section] objectAtIndex:row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"字体名称" message:fontName preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    NSLog(@"字体名称为：%@",fontName);
}



@end
