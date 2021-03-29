//
//  YYTextBindingExample.m
//  YYKitExample
//
//  Created by ibireme on 15/9/3.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "YYTextBindingExample.h"
#import "YYText.h"
#import "YYImage.h"
#import "UIImage+YYWebImage.h"
#import "UIView+YYAdd.h"
#import "NSBundle+YYAdd.h"
#import "NSString+YYAdd.h"


@interface YYTextExampleEmailBindingParser :NSObject <YYTextParser>
@property (nonatomic, strong) NSRegularExpression *regex;
@end

@implementation YYTextExampleEmailBindingParser

- (void)dealloc{
    
}

- (instancetype)init {
    self = [super init];
    NSString *pattern = @"[-_a-zA-Z@\\.]+[ ,\\n]";
    self.regex = [[NSRegularExpression alloc] initWithPattern:pattern options:kNilOptions error:nil];
    return self;
}
- (BOOL)parseText:(NSMutableAttributedString *)text selectedRange:(NSRangePointer)range {
    __block BOOL changed = NO;
    [self.regex enumerateMatchesInString:text.string options:NSMatchingWithoutAnchoringBounds range:text.yy_rangeOfAll usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (!result) return;
        NSRange range = result.range;
        if (range.location == NSNotFound || range.length < 1) return;
        if ([text attribute:YYTextBindingAttributeName atIndex:range.location effectiveRange:NULL]) return;
        
        NSRange bindlingLocRange = NSMakeRange(range.location, 1);
        NSRange bindlingRemainRange = NSMakeRange(range.location+1, range.length - 1);
        NSRange bindlingRange = NSMakeRange(range.location, range.length - 1);
        YYTextBinding *binding = [YYTextBinding bindingWithDeleteConfirm:YES];
        [text yy_setTextBinding:binding range:bindlingRange]; /// Text binding
        [text yy_setFont:[UIFont systemFontOfSize:15] range:bindlingLocRange];
        [text yy_setFont:[UIFont systemFontOfSize:15] range:bindlingRemainRange];
        [text yy_setColor:[UIColor brownColor] range:bindlingLocRange];
        [text yy_setColor:[UIColor colorWithRed:0.000 green:0.519 blue:1.000 alpha:1.000] range:bindlingRemainRange];
        changed = YES;
    }];
    return changed;
}

@end

@interface YYTextBindingExample () <YYTextViewDelegate>
@property (nonatomic, strong) YYTextView *textView;
@property (nonatomic, assign) BOOL isInEdit;
@end

@implementation YYTextBindingExample


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

//    YYTextView *textView = [YYTextView new];
//    textView.attributedText = text;
//    //textView.textParser = [YYTextExampleEmailBindingParser new];
//    textView.size = self.view.size;
//    textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
//    textView.delegate = self;
//    if (kiOS7Later) {
//        textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
//    }
//    textView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
//    textView.scrollIndicatorInsets = textView.contentInset;
//    [self.view addSubview:textView];
//    self.textView = textView;
//    [self.textView becomeFirstResponder];
    
    
    [self exampleVideoDesc];
}

- (NSMutableAttributedString *)tagAttrWithTagStrs:(NSArray<NSString *> *)tagStrs font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing {
    NSMutableAttributedString *tagAttrTotal = [[NSMutableAttributedString alloc] initWithString:@""];

    [tagStrs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSMutableAttributedString *bind0 = [[NSMutableAttributedString alloc] initWithData:[obj dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
            [bind0 yy_setFont:font range:bind0.yy_rangeOfAll];
            [bind0 yy_setColor:[UIColor orangeColor] range:NSMakeRange(0, 1)];
            [bind0 yy_setColor:LKHexColor(0xFE4070) range:NSMakeRange(1, bind0.length - 1)];
            //YYTextBinding *binding0 = [YYTextBinding bindingWithDeleteConfirm:NO];
            //[bind0 yy_setTextBinding:binding0 range:bind0.yy_rangeOfAll];
            //标签中插入透明的特殊字符，让每个标签不会一行显示不完，产生截断；英语不会有这个问题，中文才需要特殊处理
            NSMutableAttributedString *bind1 = [[NSMutableAttributedString alloc] initWithString:@"\u180E"];
            [bind1 yy_setColor:[UIColor clearColor] range:bind1.yy_rangeOfAll];
            NSString *total = bind0.string;
            NSInteger count = total.length * 2;
            for (NSInteger i = 0; i<count; i+=2) {
                NSLog(@"index: %zd , count : %zd",i,count);
                [bind0 insertAttributedString:bind1 atIndex:i];
            }
            
            if (idx != 0) {
                bind0.yy_lineSpacing = lineSpacing;
            }
            [tagAttrTotal appendAttributedString:bind0];
        }
    }];
    return tagAttrTotal;
}

- (void)exampleVideoDesc {
    
    NSArray<NSString *> *tags = @[@"<font color=\"#FE4070\">#</font><font color=\"#F04070\">测试新人指引  </font>", @"<font color=\"#FE4070\">#</font><font color=\"#F04070\">测试新人引  </font>",@"<font color=\"#FE4070\">#</font><font color=\"#F04070\">测试新人指引  </font>", @"<font color=\"#FE4070\">#</font><font color=\"#F04070\">测试新人引  </font>", @"<font color=\"#FE4070\">#</font><font color=\"#F04070\">话题标签话题标签话题标签话题标签话题标签标签标签话题标签话题标签话题标签标签  </font>"];
    NSMutableAttributedString *tagAttrs = [self tagAttrWithTagStrs:tags font:[UIFont systemFontOfSize:15] lineSpacing:3];
    
    NSMutableAttributedString *text01 = [[NSMutableAttributedString alloc] initWithString:@"我是描述文案我是描述文案我是描述文案我是描述文案我是描述文案我是描述文案我是描述文案我是描述文案我是描述文案我是描述文案我是描述文案我是描述文案我是描述文案我是描述文案我是描述文案我是描述文案我是描述文案我是描述文案"];
    text01.yy_font = [UIFont systemFontOfSize:12];
    text01.yy_lineSpacing = 6;
    text01.yy_color = [[UIColor greenColor] colorWithAlphaComponent:0.3];
    text01.yy_lineBreakMode = NSLineBreakByWordWrapping;
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@""];
    [text appendAttributedString:tagAttrs];
    [text appendAttributedString:text01];
    text.yy_lineBreakMode = NSLineBreakByWordWrapping;
    
    YYLabel *label = [[YYLabel alloc] initWithFrame:CGRectMake(0, 90, self.view.size.width, self.view.size.height)];
    label.displaysAsynchronously = YES;
    label.font = [UIFont systemFontOfSize:12];
    label.attributedText = text;
    label.numberOfLines = 4;
    label.textVerticalAlignment = YYTextVerticalAlignmentTop;
    label.textAlignment = NSTextAlignmentLeft;
    //label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.05];
    [self.view addSubview:label];
    [self addSeeMoreButtonAfter:label];
    [label sizeToFit];
    NSLog(@"label.frame=%@",NSStringFromCGRect(label.frame));
    
}

- (void)addSeeMoreButtonAfter:(YYLabel *)label {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"..."];
    text.yy_font = label.font;

    NSMutableAttributedString *more = [[NSMutableAttributedString alloc] init];
    UIImage *image = [UIImage imageNamed:@"link_icon"];
    NSMutableAttributedString *moreAttach = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:label.font alignment:YYTextVerticalAlignmentCenter];
    [more appendAttributedString:moreAttach];
    NSMutableAttributedString *moreText = [[NSMutableAttributedString alloc] initWithString:@"more"];
    moreText.yy_font = label.font;
    [more appendAttributedString:moreText];
    
    YYTextBorder *border = [YYTextBorder new];
    border.lineStyle = YYTextLineStyleSingle;
    border.fillColor = [UIColor colorWithWhite:0.184 alpha:0.090];
    border.strokeColor = [UIColor colorWithWhite:0.546 alpha:0.650];
    border.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
    border.cornerRadius = 2;
    //border.strokeWidth = YYTextCGFloatFromPixel(1);
    [more yy_setTextBackgroundBorder:border range:more.yy_rangeOfAll];

    YYTextHighlight *hi = [YYTextHighlight new];
    //[hi setColor:[UIColor colorWithRed:0.578 green:0.790 blue:1.000 alpha:1.000]];
    hi.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
        NSLog(@"you just tap me!");
    };
    //[text yy_setColor:[UIColor colorWithRed:0.000 green:0.449 blue:1.000 alpha:1.000] range:[text.string rangeOfString:@"more"]];
    [more yy_setTextHighlight:hi range:more.yy_rangeOfAll];
    [text appendAttributedString:more];
    
    YYLabel *seeMore = [YYLabel new];
    seeMore.attributedText = text;
    [seeMore sizeToFit];
    
    NSAttributedString *truncationToken = [NSAttributedString yy_attachmentStringWithContent:seeMore contentMode:UIViewContentModeCenter attachmentSize:seeMore.size alignToFont:text.yy_font alignment:YYTextVerticalAlignmentCenter];
    label.truncationToken = truncationToken;
}

- (void)edit:(UIBarButtonItem *)item {
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    } else {
        [_textView becomeFirstResponder];
    }
}

- (void)textViewDidChange:(YYTextView *)textView {
    if (textView.text.length == 0) {
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidBeginEditing:(YYTextView *)textView {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(edit:)];
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void)textViewDidEndEditing:(YYTextView *)textView {
    self.navigationItem.rightBarButtonItem = nil;
}


@end
