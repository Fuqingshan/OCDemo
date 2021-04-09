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

#import "OCVideoPlayer.h"
#import "OCVideoLoadingView.h"

#import <KTVHTTPCache/KTVHTTPCache.h>

@interface VideoPlayerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property(nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger currentPlayIndex;//当前要播放的index
@property (nonatomic, assign) NSInteger preloadIndex;//预加载的index

@property(nonatomic, strong) OCVideoPlayer *player;
@property (nonatomic, strong) OCVideoLoadingView *loadingView;

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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self videoPause];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)initData{
    [self configHttpCache];
    [self loadData];
    
    //设置预加载为第二个
    self.currentPlayIndex = 0;
    self.preloadIndex = 1;
}

- (void)loadData{
    self.dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"OCPlayList" ofType:@"plist"];
    NSArray *plistDic = [NSArray arrayWithContentsOfFile:path];
    
    for (NSDictionary *dic in plistDic) {
        VideoPlayerModel *model = [VideoPlayerModel yy_modelWithDictionary:dic];
        [self.dataSource addObject:model];
    }
}

#pragma mark - 唱吧缓存组件，注意：因为内部生成的本地代理URL用的是http，因此要修改App Transport Security
- (void)configHttpCache{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
#if DEBUG
//        [KTVHTTPCache cacheSetMaxCacheLength:500 * 1024 * 1024];//默认就是500M
        [KTVHTTPCache logSetConsoleLogEnable:NO];
        [KTVHTTPCache logSetRecordLogEnable:YES];
#else
        [KTVHTTPCache logSetConsoleLogEnable:NO];
        [KTVHTTPCache logSetRecordLogEnable:YES];
#endif

        NSURL *logFileURL = [KTVHTTPCache logRecordLogFileURL];
        NSLog(@"log地址：%@",logFileURL);
        
        NSError *error;
        [KTVHTTPCache proxyStart:&error];
        if (error) {
            NSLog(@"缓存初始化异常!");
        }
    });
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"短视频");
    
    [self configCollectionView];
    [self configPlayer];
    [self addEvent];
}

- (void)configCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.bounces = YES;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view insertSubview:self.collectionView belowSubview:self.backBtn];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top);
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    
    AdjustsScrollViewInsets(self, self.collectionView);
    [self.collectionView registerNib:[UINib nibWithNibName:[VideoPlayerCollectionViewCell cellReuseIdentifier] bundle:nil] forCellWithReuseIdentifier:[VideoPlayerCollectionViewCell cellReuseIdentifier]];

    [self.view layoutIfNeeded];
}

- (void)addEvent{
    self.backBtn.exclusiveTouch = YES;
    
    @weakify(self);
    [[self.backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)configPlayer{
    [self playTheVideoAtIndex:0];
    [self addObserver];
}

- (void)addObserver{
    @weakify(self);
    [[RACObserve(self.player, playProgress)
      takeUntil:[self.rac_willDeallocSignal merge:[self rac_signalForSelector:@selector(videoDestroy)]]]
     subscribeNext:^(NSNumber *x) {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (x.floatValue == 1.0) {
                //播放完成
            }
        });
    }];
    
    [[RACObserve(self.player, cacheProgress)
      takeUntil:[self.rac_willDeallocSignal merge:[self rac_signalForSelector:@selector(videoDestroy)]]]
     subscribeNext:^(NSNumber *x) {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (x.floatValue == 1.0) {
                //缓存完成，开启预加载
                [self preloadVideo];
            }
        });
    }];
    
    [[RACObserve(self.player, state)
      takeUntil:[self.rac_willDeallocSignal merge:[self rac_signalForSelector:@selector(videoDestroy)]]]
     subscribeNext:^(NSNumber * x) {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            switch (x.integerValue) {
                case OCVideoPlayerStateEndFailed:
                case OCVideoPlayerStateEndErrorUnknown:
                    NSLog(@"提示，网络错误，请检查网络连接");
                default:
                    break;
            }
            
            switch (x.integerValue) {
                case OCVideoPlayerStateWaiting:
                case OCVideoPlayerStateReadyToPlay:
                case OCVideoPlayerStateBuffering:
                    [self.loadingView startAnimation];
                    break;
                default:
                    [self.loadingView stopAnimation];
                    break;
            }
        });
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillResignActiveNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        [self videoPause];
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        [UIView animateWithDuration:0.05 animations:^{
            [self.view layoutIfNeeded];
         }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self videoPlay];
        });
    }];
}

#pragma mark - videoControl
- (void)videoPlay {
    //隐藏播放按钮
    VideoPlayerCollectionViewCell *currentCell = (VideoPlayerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPlayIndex inSection:0]];

    currentCell.playView.hidden = YES;
    [self.player play];
}

- (void)videoPause {
    //展示出播放按钮
    VideoPlayerCollectionViewCell *currentCell = (VideoPlayerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPlayIndex inSection:0]];
    
    currentCell.playView.hidden = NO;
    [self.player pause];
}

- (void)videoDestroy{
    [self.player destroy];
    self.player = nil;
}

- (void)playTheVideoAtIndex:(NSInteger)index{
    VideoPlayerCollectionViewCell *currentCell = (VideoPlayerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    currentCell.playView.hidden = YES;
    currentCell.videoThumbnailImageView.image = nil;
    VideoPlayerModel *model = objectInArrayAtIndex(self.dataSource, index);
    
    //这个值表示视频实际内容的宽高比，由后端传过来的视频宽高计算出来
    CGFloat aspectRatio = model.width / model.height;
    AVLayerVideoGravity videoGravity = aspectRatio <= 0.57 ? AVLayerVideoGravityResizeAspectFill: AVLayerVideoGravityResizeAspect;
    
    //使用唱吧缓存组件
    NSURL *cacheURL = [KTVHTTPCache proxyURLWithOriginalURL:model.videoURL];
    [self.player changeCurrentPlayerItemWithURL:cacheURL];
    
    [self.player preparePlayInView:currentCell.videoThumbnailImageView videoGravity:videoGravity];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"短视频");
    //更改样式之后刷新UI可以写在这儿
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger currentIndex = round(self.collectionView.contentOffset.y / kMainScreenHeight);
    
    //当用户拖动的界面大于一个时，暂停播放器
    if(labs(currentIndex - self.currentPlayIndex)>1 && self.player.isPlaying) {
        NSLog(@"重置播放器");
        VideoPlayerModel *model = objectInArrayAtIndex(self.dataSource, self.currentPlayIndex);
        if (!model) {
            return;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentPlayIndex inSection:0];
        VideoPlayerCollectionViewCell *currentCell = (VideoPlayerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [currentCell fillCellWithModel:model indexPath:indexPath];
        
        [self.player reset];
    }
}

 //如果手一直拖着停在page移动的终点,然后不动，隔一会儿放开，这样就没有减速了，这个方法就不会调用，所以要把bounces打开，加上下拉刷新什么的更好
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentIndex = round(self.collectionView.contentOffset.y / kMainScreenHeight);
    
    NSLog(@"scrollViewDidEndDecelerating");
    
    //还在当前页面
    if (self.currentPlayIndex == currentIndex) {
        return;
    }
        
    //下拉
    if(self.currentPlayIndex > currentIndex) {
        NSLog(@"预加载上一个");
        self.preloadIndex = currentIndex - 1;
    }
   
    //上拉
    if(self.currentPlayIndex < currentIndex) {
        NSLog(@"预加载下一个");
        self.preloadIndex = currentIndex + 1;
    }
    self.currentPlayIndex = currentIndex;
    [self playTheVideoAtIndex:self.currentPlayIndex];
}

#pragma mark - 预加载
/*
 1、既然是预加载，那么肯定不能影响到当前的播放，因此要等当前播放完成才能开始预加载
 2、预加载，指的是提前缓存好用户将要播放的视频，那么模拟一个request，就可以让KTVHTTPCache提前缓存
 */
- (void)preloadVideo{
    VideoPlayerModel *model = objectInArrayAtIndex(self.dataSource, self.preloadIndex);
    if (!model) {
        return;
    }
    NSLog(@"开始预加载第%zd个视频",self.preloadIndex + 1);
    NSURL *cacheURL = [KTVHTTPCache proxyURLWithOriginalURL:model.videoURL];
    [[[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:cacheURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30]] resume];
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
    if (self.player.isPlaying) {
        [self videoPause];
    }else{
        [self videoPlay];
    }
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

#pragma mark - lazyload
- (OCVideoPlayer *)player{
    if(!_player){
        _player = [[OCVideoPlayer alloc] init];
        //设置自动重播
        _player.autoReplay = YES;
    }
    return _player;
}

- (OCVideoLoadingView *)loadingView{
    if(!_loadingView){
        _loadingView = [[OCVideoLoadingView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1)];
        [self.view addSubview:_loadingView];
        
        [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@1);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view.mas_bottom).offset(-83);
        }];
    }
    return _loadingView;
}

@end
