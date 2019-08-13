//
//  ChatEmojiViewController.m
//  OC
//
//  Created by yier on 2019/3/13.
//  Copyright © 2019 yier. All rights reserved.
//

#import "ChatEmojiViewController.h"
#import "PagingCollectionViewLayout.h"
#import "ChatEmojiCell.h"

@interface ChatEmojiViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ChatEmojiViewController

- (void)dealloc{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    [self setupCollectionView];
}

- (void)initData{
    self.dataSource = @[].mutableCopy;
    for (NSInteger i = 0; i< 99; i++) {
        [self.dataSource addObject:[NSString stringWithFormat:@"f0%@%zd.png",i<10?@"0":@"",i]];
    }
    [self.collectionView reloadData];
}

#pragma mark - setupUI
- (void)setupCollectionView{
    PagingCollectionViewLayout *layout = [[PagingCollectionViewLayout alloc] init];
    layout.collectionViewSize = CGSizeMake(kMainScreenWidth, 300);
    layout.itemSize = CGSizeMake(40, 40);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 300) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([ChatEmojiCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([ChatEmojiCell class])];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.mas_topLayoutGuideTop);
        }
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(300.0f);
    }];
}

#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ChatEmojiCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ChatEmojiCell class]) forIndexPath:indexPath];
    NSString *emojiName = objectInArrayAtIndex(self.dataSource, indexPath.row);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForAuxiliaryExecutable:emojiName]];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.img.image  = [UIImage imageWithData:data];
        });
    });
    return cell;
}

@end
