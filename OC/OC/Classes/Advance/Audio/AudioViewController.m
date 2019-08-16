//
//  AudioViewController.m
//  OC
//
//  Created by yier on 2019/8/12.
//  Copyright © 2019 yier. All rights reserved.
//

#import "AudioViewController.h"
#import <objc/message.h>

#import "OCAudioPlayer.h"
#import "CustomAudioPlayer.h"
#import "CustomAudioRecord.h"

@interface AudioViewController ()<UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) OCAudioPlayer *audioPlay;//背景音乐
@property (nonatomic, strong) CustomAudioPlayer *customPlay;//自定义播放
@property (nonatomic, strong) CustomAudioRecord *customRecord;///<自定义录制

@end

@implementation AudioViewController

- (void)dealloc{
    [self stopPlay];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"音频");
    self.tableView.tableFooterView = [UIView new];
      self.tableView.backgroundColor = [UIColor clearColor];
      [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"音频");
}

- (void)initData{
    self.dataSource = @[
                        @{
                            @"content":@"开始播放"
                            ,@"sel":@"beginAudio"
                            }
                        ,@{
                            @"content":@"播放繁忙"
                            ,@"sel":@"playBusyAudio"
                            }
                        ,@{
                           @"content":@"播放挂断"
                           ,@"sel":@"playHangup"
                           }
                        ,@{
                           @"content":@"停止播放"
                           ,@"sel":@"stopPlay"
                           }
                        ,@{
                            @"content":@"自定义播放器"
                            ,@"sel":@"customerPlay"
                            }
                        ,@{
                            @"content":@"自定义录制"
                            ,@"sel":@"customRecordSelector"
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

#pragma mark - 开始播放音乐
- (void)beginAudio{
    @weakify(self);
    [[[self playAudioWithPlayType:FAAudioPlayTypePreWaiting] takeUntil:self.rac_willDeallocSignal] subscribeCompleted:^{
        @strongify(self);
        //AVAudioPlayer歇气需要时间，0.01秒也可以
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.audioPlay playRecord:FAAudioPlayTypeWaiting];
        });
    }];
}

#pragma mark - 播放繁忙
- (void)playBusyAudio{
    @weakify(self);
    [[[self playAudioWithPlayType:FAAudioPlayTypeBusy] takeUntil:self.rac_willDeallocSignal] subscribeCompleted:^{
        @strongify(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.audioPlay playRecord:FAAudioPlayTypeWaiting];
        });
    }];
}

#pragma mark - 播放挂断
- (void)playHangup{
    [self.audioPlay playRecord:FAAudioPlayTypeHangup];
}

#pragma mark - 停止播放音乐
- (void)stopPlay{
    [self.audioPlay stopCurrentPlayer];
}

- (RACSignal *)playAudioWithPlayType:(FAAudioPlayType)type{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        self.audioPlay.playCompleteBlock = ^(FAAudioPlayStatus status) {
            if (status == FAAudioPlayStatusNormal) {
                [subscriber sendCompleted];
            }else if(status == FAAudioPlayStatusSystemInterruption){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseEvent" object:@(YES)];
                [subscriber sendError:nil];
            }else{
                [subscriber sendError:nil];
            }
        };
        [self.audioPlay playRecord:type];
        return nil;
    }];
}

#pragma mark - 自定义播放器
- (void)customerPlay{
    self.customPlay.currentTime = 0;
    [self.customPlay play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"audioPlayerDidFinishPlaying");
}

#pragma mark - 自定义录制
- (void)customRecordSelector{
    self.customRecord.successBlock = ^(id model) {
        NSLog(@"successBlock:\n%@",model);
    };
    
    self.customRecord.failureBlock = ^(id model) {
        NSLog(@"failureBlock:\n%@",model);
    };
    
    [self.customRecord startRecordWithURL:[self recordURL]];
}

#pragma mark - lazy load
- (OCAudioPlayer *)audioPlay{
    if(!_audioPlay){
        _audioPlay = [[OCAudioPlayer alloc] init];
    }
    return _audioPlay;
}

- (CustomAudioPlayer *)customPlay{
    if (!_customPlay) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"live_busy" ofType:@"mp3"];
        _customPlay = [[CustomAudioPlayer alloc] init];
        [_customPlay playAudioWithURL:[NSURL URLWithString:path]];
        _customPlay.delegate = self;
    }
    
    return _customPlay;
}

- (CustomAudioRecord *)customRecord{
    if (!_customRecord) {
        _customRecord = [[CustomAudioRecord alloc] init];
        _customRecord.ignoreMixer = YES;
    }
    
    return _customRecord;
}

#pragma mark - lazy load
- (NSURL *)recordURL{
    NSString * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString * filePath = [path stringByAppendingPathComponent:@"record1.caf"];
    NSURL * url = [NSURL fileURLWithPath:filePath];
    return url;
}


@end
