//
//  VideoPlayerViewController.m
//  OC
//
//  Created by yier on 2021/4/1.
//  Copyright © 2021 yier. All rights reserved.
//

#import "VideoPlayerViewController.h"

#import "VideoPlayerModel.h"
#import "VideoPlayerCollectionViewCell.h"

#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
#import <KTVHTTPCache/KTVHTTPCache.h>

@interface VideoPlayerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property(nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) ZFPlayerController *player;

@property(nonatomic, strong) NSMutableArray<VideoPlayerModel *> *dataSource;
@end

@implementation VideoPlayerViewController

- (void)dealloc{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    @weakify(self);
    [self.player zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
        @strongify(self);
        [self playTheVideoAtIndexPath:indexPath];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)initData{
    [self configHttpCache];
    [self loadData];
}

- (void)loadData{
    self.dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSInteger i = 0; i < 10; i++) {
        VideoPlayerModel *model = [VideoPlayerModel yy_modelWithDictionary:@{
            @"videoURL":@"https://free-video.boxueio.com/thinking-in-rx-31a4db4eeb27f1bd9ceb9d57533bf233.mp4"
            ,@"thumbnailURL":@"https://tva1.sinaimg.cn/large/008eGmZEly1gous3dvbpfj30dw0afjxy.jpg"
            ,@"content":[NSString stringWithFormat:@"这是第%zd个视频",i]
        }];
        [self.dataSource addObject:model];
    }
}

#pragma mark - 唱吧缓存组件，注意：因为内部生成的本地代理URL用的是http，因此要修改App Transport Security
- (void)configHttpCache{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
#if DEBUG
        [KTVHTTPCache logSetConsoleLogEnable:YES];
        [KTVHTTPCache logSetRecordLogEnable:YES];
#else
        [KTVHTTPCache logSetConsoleLogEnable:NO];
        [KTVHTTPCache logSetRecordLogEnable:YES];
#endif

        NSURL *logFileURL = [KTVHTTPCache logRecordLogFileURL];
        NSLog(@"log地址：%@",logFileURL);
        
        NSError *error;
        [KTVHTTPCache proxyStart:&error];
        if (!error) {
            NSLog(@"缓存初始化异常!");
        }
    });
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"短视频");
    [self configCollectionView];
    [self configPlayer];
}

- (void)configCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.bounces = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.view insertSubview:self.collectionView belowSubview:self.backBtn];
    
    [self.collectionView registerNib:[UINib nibWithNibName:[VideoPlayerCollectionViewCell cellReuseIdentifier] bundle:nil] forCellWithReuseIdentifier:[VideoPlayerCollectionViewCell cellReuseIdentifier]];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top);
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
}

- (IBAction)backEvent:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configPlayer{
    /// playerManager
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    
    /// player的tag值必须在cell里设置
    self.player = [ZFPlayerController playerWithScrollView:self.collectionView playerManager:playerManager containerViewTag:kPlayerViewTag];
    self.player.shouldAutoPlay = YES;
    self.player.controlView.hidden = YES;
    self.player.allowOrentitaionRotation = NO;
    self.player.disablePanMovingDirection = ZFPlayerDisablePanMovingDirectionAll;
    /// 1.0是消失100%时候
    self.player.playerDisapperaPercent = 1.0;
    
    @weakify(self);
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self);
        [self.player.currentPlayerManager replay];
    };
    
    /// 停止的时候找出最合适的播放
    self.player.zf_scrollViewDidEndScrollingCallback = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self);
        [self playTheVideoAtIndexPath:indexPath];
    };
    
}

- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath{
    VideoPlayerModel *model = self.dataSource[indexPath.row];
    //使用唱吧缓存组件
    NSURL *cacheURL = [KTVHTTPCache proxyURLWithOriginalURL:model.videoURL];
    [self.player playTheIndexPath:indexPath assetURL:cacheURL];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"短视频");
    //更改样式之后刷新UI可以写在这儿
}

#pragma mark - UIScrollViewDelegate  列表播放必须实现

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidEndDecelerating];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView zf_scrollViewDidEndDraggingWillDecelerate:decelerate];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScrollToTop];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewWillBeginDragging];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoPlayerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VideoPlayerCollectionViewCell cellReuseIdentifier] forIndexPath:indexPath];
    VideoPlayerModel *model = self.dataSource[indexPath.row];
    [cell fillCellWithModel:model indexPath:indexPath];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 这个打开了之后，随便碰一下就重新播放了，体验不好
//    [self playTheVideoAtIndexPath:indexPath];
}

#pragma mark  - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(kMainScreenWidth, kMainScreenHeight);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

@end
