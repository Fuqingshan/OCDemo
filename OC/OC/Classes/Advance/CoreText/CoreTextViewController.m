//
//  CoreTextViewController.m
//  OC
//
//  Created by yier on 2020/1/13.
//  Copyright © 2020 yier. All rights reserved.
//

#import "CoreTextViewController.h"
#import "CTContentView.h"
#import "CTFrameParserConfig.h"
#import "CTFrameParser.h"
#import "UIView+frameAdjust.h"
#import "CoreTextData.h"

@interface CoreTextViewController ()
@property(nonatomic, strong)  CTContentView *contentView;

@end

@implementation CoreTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        [self setupUI];
        [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"CoreText");
    
    self.contentView = [[CTContentView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 600)];
    [self.view addSubview:self.contentView];
    
    CTFrameParserConfig *config = [[CTFrameParserConfig alloc] init];
//    config.textColor = [UIColor redColor];
    config.width = self.contentView.width;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"layout" ofType:@"json"];
    
    CoreTextData *data = [CTFrameParser parseTemplateFile:path config:config];
    self.contentView.data = data;
    self.contentView.height = data.height;
    self.contentView.backgroundColor = [UIColor orangeColor];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"CoreText");
}

- (void)initData{
   
}
@end
